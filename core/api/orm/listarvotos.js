// Librerías necesarias: npm install @prisma/client
const { createHash, createDecipheriv, privateDecrypt } = require('crypto');
const os = require('os');
const { PrismaClient } = require('../../src/generated/prisma'); // Ajusta la ruta si es necesario

const prisma = new PrismaClient();

// Desencripta la clave privada/pública
// En este caso seria la privada del usuario pues con esa desencriptamos los votos
// Se usa AES-256-CBC para la desencriptacion de la clave privada 
function decryptWithPassword(encrypted, password) {
  // Si 'encrypted' ya es un Buffer, lo usa tal cual; si no, lo decodifica desde base64 a Buffer.
  const buf = Buffer.isBuffer(encrypted) ? encrypted : Buffer.from(encrypted, 'base64');

  // Extrae los primeros 16 bytes del buffer como el IV (vector de inicialización). (Ya que los metimos al cifrar los votos, esto le da aleatoriedad al cifrado)
  // El IV es necesario para la desencriptación AES en modo CBC y añade aleatoriedad.
  // Aunque tengan la misma contraseña, el IV asegura que el resultado sea diferente cada vez.
  const iv = buf.slice(0, 16);

  // Si el IV no tiene exactamente 16 bytes, lanza un error. Pues no se encontro en el Encrypted.
  // El IV no es necesario que sea secreto, pero debe ser único para cada cifrado con la misma clave.
  // El IV no da informacion util ni permite aleatorizar otras claves para encontrar una que pudiese coincidir (o sea el que sea publica no afecta la seguridad).
  if (iv.length !== 16) throw new Error('IV inválido'); 

  // El resto del buffer (después de los primeros 16 bytes) es el dato cifrado real. Que vamos a desencriptar.
  const data = buf.slice(16);

  // Se crea un hash SHA-512 de la contraseña para generar una seed de 32 bytes (256 bits) para AES-256-CBC. La misma que teniamos al cifrar entonces nos permite desencriptar.
  const seed = createHash('sha512').update(password).digest().slice(0, 32);

  // Manda los parametros a desencriptar el dato cifrado.
  const decipher = createDecipheriv('aes-256-cbc', seed, iv);

  // Desencripta los datos y los concatena, devolviendo el resultado como string UTF-8.
  return Buffer.concat([
    decipher.update(data), // Aca desencriptamos la parte importante (encrypted) con la funcion de decipher
    decipher.final() // Esta parte finaliza el proceso de desencriptación y devuelve cualquier dato restante, si da error devolvera el error.
  ]).toString('utf8');
}

// Obtener usuarios verificados con MFA y validación de identidad
// Los usaremos para verificar si el userid esta entre ellos.
async function obtenerUsuariosVerificados() {
  return await prisma.pV_Users.findMany({
    where: {
      PV_UserStatus: { verified: true, active: true },
      PV_MFA: { some: { enabled: true } },
      PV_IdentityUserValidation: {
        some: {
          PV_IdentityValidations: { verified: true }
        }
      }
    },
    select: {
      userid: true,
      PV_Genders: { select: { name: true } }
    }
  });
}

// Obtener TODOS los votos del usuario (los decifraremos).
async function obtenerTodosLosVotosDelUsuario(userid) {
  return await prisma.pV_Votes.findMany({
    where: { userId: userid },
    orderBy: { votedate: 'desc' },
    take: 5,
    select: {
      PV_VotingConfigurations: {
        select: {
          PV_Proposals: {
            select: { proposalid: true, title: true, createdon: true }
          }
        }
      },
      publicResult: true,
      votedate: true,
      encryptedvote: true
    }
  });
}

// Obtener las cryptokeys del usuario
async function obtenerClavePrivadaCifrada(userid) {
  const key = await prisma.pV_CryptoKeys.findFirst({
    where: { userid },
    select: { encryptedprivatekey: true }
  });
  return key ? key.encryptedprivatekey : null;
}

// Crear un log en la tabla PV_Logs
async function crearLogVoto(log) {
  await prisma.pV_Logs.create({
    data: {
      description: log.description,
      name: log.name,
      posttime: log.posttime,
      computer: log.computer,
      trace: log.trace,
      referenceid1: log.referenceid1,
      referenceid2: log.referenceid2,
      checksum: log.checksum,
      logtypeid: log.logtypeid,
      logsourceid: log.logsourceid,
      logseverityid: log.logseverityid,
      value1: log.value1,
      value2: log.value2
    }
  });
}

// Desencriptar el voto con la clave privada desencriptada
// Usamos la clave privada del usuario para desencriptar el voto.
function desencriptarVotoConClavePrivada(encryptedVote, privateKeyPem) {
  try {
    // Si 'encryptedVote' ya es un Buffer, lo usa tal cual; si no, lo convierte a Buffer.
    const bufferVote = Buffer.isBuffer(encryptedVote) ? encryptedVote : Buffer.from(encryptedVote);

    // Usa la función 'privateDecrypt' de Node.js para descifrar el voto.
    // key es la privatekey que desencriptamos con la contraseña del usuario.
    // 'padding' especifica el esquema de relleno OAEP, que es más seguro que el relleno PKCS#1 v1.5.
    // Se usa ese padding para que coincida con el que se usó al cifrar el voto. OAEP añade seguridad y aleatoridad al proceso de cifrado.
    const decrypted = privateDecrypt(
      {
        key: privateKeyPem,
        padding: require('crypto').constants.RSA_PKCS1_OAEP_PADDING
      },
      bufferVote // Este es el voto a desencriptar.
    );
    // Convierte el resultado descifrado a string UTF-8 y lo retorna.
    return decrypted.toString('utf8');
  } catch (e) {
    // Si ocurre un error (por ejemplo, clave incorrecta o datos corruptos), retorna un mensaje de error.
    return `[Error al desencriptar: ${e.message}]`;
  }
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido, solo POST' });
  }

  const { userid, password } = req.body || {};

  if (!userid || !password) {
    return res.status(400).json({ error: 'Debe enviar userid y password en el body.' });
  }

  const logtypeid = await prisma.pV_LogTypes.findFirst({ where: { name: 'Lectura Votos' } });
  const logsourceid = 2;
  const logseverityid = 1;

  try {
    const usuarios = await obtenerUsuariosVerificados();
    const usuarioVerificado = usuarios.some(u => u.userid === userid);

    if (!usuarioVerificado) {
      return res.status(403).json({
        error: `El usuario ${userid} no cumple las condiciones, puede que no tenga MFA, no esté habilitado, esté inactivo o sin verificar`
      });
    }

    const votos = await obtenerTodosLosVotosDelUsuario(userid);
    if (votos.length === 0) {
      return res.status(200).json({ message: "Este Usuario no tiene votos válidos para la lectura" });
    }

    // Obtener la clave privada cifrada y desencriptarla
    const encryptedPrivateKey = await obtenerClavePrivadaCifrada(userid);
    if (!encryptedPrivateKey) {
      return res.status(404).json({ error: "No se encontró la clave privada cifrada para este usuario." });
    }

    let privateKeyPem;
    try {
      privateKeyPem = decryptWithPassword(encryptedPrivateKey, password);
    } catch (err) {
      return res.status(401).json({ error: "Error al desencriptar la clave privada: " + err.message });
    }

    // Procesar votos
    const resultados = [];
    for (const voto of votos) {
      // Extraer info de la propuesta
      const proposal = voto.PV_VotingConfigurations?.PV_Proposals || {};
      let resultado;
      if (voto.publicResult) {
        resultado = voto.publicResult;
      } else {
        resultado = desencriptarVotoConClavePrivada(voto.encryptedvote, privateKeyPem);
      }

      // Crear el string para el checksum con todos los datos relevantes del log
      const checksum_str = [
        userid,
        proposal.proposalid,
        resultado,
        proposal.createdon,
        "LecturaVotoUsuario",
        os.hostname(),
        new Date().toISOString(),
        resultado,
        voto.votedate
      ].join('|');
      const checksum_bytes = createHash('sha512').update(checksum_str, 'utf8').digest();

      // Recortar trace si es necesario (por límite de columna)
      let trace_text = `Voto: ${resultado}, Fecha del Voto: ${voto.votedate},Fecha de creacion de la Propuesta: ${proposal.createdon}`;
      if (trace_text.length > 200) trace_text = trace_text.slice(0, 200);

      // Guardar log por cada voto mostrado
      await crearLogVoto({
        description: `Lectura voto usuario ${userid} propuesta ${proposal.proposalid}`,
        name: "LecturaVotoUsuario",
        posttime: new Date(),
        computer: os.hostname(),
        trace: trace_text,
        referenceid1: userid,
        referenceid2: proposal.proposalid,
        checksum: checksum_bytes,
        logtypeid,
        logsourceid,
        logseverityid,
        value1: String(resultado),
        value2: String(voto.votedate)
      });

      resultados.push({
        propuesta: {
          id: proposal.proposalid,
          titulo: proposal.title,
          fechaCreacion: proposal.createdon
        },
        voto: resultado,
        fechaVoto: voto.votedate
      });
    }

    return res.status(200).json({
      success: true,
      votos: resultados
    });

  } catch (err) {
    console.error("Error:", err);
    return res.status(500).json({ error: "Error interno del servidor", details: err.message });
  } finally {
    await prisma.$disconnect();
  }
};