// Librerías necesarias: npm install @prisma/client
const { createHash, createDecipheriv, privateDecrypt } = require('crypto');
const os = require('os');
const { PrismaClient } = require('../../src/generated/prisma'); // Ajusta la ruta si es necesario
const { getSessionCache } = require('../../src/utils/authsessionsgenerator');
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

  const { userid } = req.body || {}; 

  if (!userid) {
    return res.status(400).json({ error: 'Debe enviar userid en el body.' });
  }

  // Obtiene la clave privada desencriptada desde la cache que hicimos con authsessionsgenerator.js
  // Cache que se genera con los inicios de sesion y las contraseñas de los usuarios.
  const sessionCache = await getSessionCache();
  const userKeys = sessionCache[userid] || sessionCache[String(userid)] || sessionCache[Number(userid)];
  if (!userKeys || !userKeys.privateKey) {
    return res.status(403).json({ error: 'No hay claves desencriptadas en cache para este usuario. Debe iniciar sesión debido al token de sesion es invalido o expiró.' });
  }
  const privateKeyPem = userKeys.privateKey; // La clave privada desencriptada del usuario que nos trajimos del cache de usuarios que iniciaron sesion.

  

  const logtype = await prisma.pV_LogTypes.findFirst({ where: { name: 'Lectura Votos' } });
  const logtypeid = logtype?.logtypeid;
  const logsourceid = 2;
  const logseverityid = 1;

  try {
    const usuarios = await obtenerUsuariosVerificados();
    const usuarioVerificado = usuarios.some(u => u.userid === userid);

    // Verificar si el usuario esta en esa tabla de verificados que sacamos (users con MFA, verificados y activos)
    if (!usuarioVerificado) {
      return res.status(403).json({
        error: `El usuario ${userid} no cumple las condiciones, puede que no tenga MFA, no esté habilitado, esté inactivo o sin verificar`
      });
    }

    const jwt = require('jsonwebtoken');
    const JWT_SECRET = 'supersecreto_para_firmar_tokens'; // Usa el mismo secreto que al firmar


    // Verificar si el token y refreshToken son válidos y no han expirado.
    try {
      jwt.verify(userKeys.token, JWT_SECRET);
      jwt.verify(userKeys.refreshToken, JWT_SECRET);
    } catch (err) {
      return res.status(401).json({
        error: 'El token de sesión del usuario es inválido o ha expirado. Debe iniciar sesión nuevamente.'
      });
    }

    // Obtener todos los votos del usuario
    // Si no tiene votos, devolvemos un mensaje indicando que no hay votos válidos para la lectura.
    const votos = await obtenerTodosLosVotosDelUsuario(userid);
    if (votos.length === 0) {
      return res.status(200).json({ message: "Este Usuario no tiene votos válidos para la lectura" });
    }

    // Procesar cada voto
    const resultados = [];
    for (const voto of votos) {
      // Extraer info de la propuesta
      const proposal = voto.PV_VotingConfigurations?.PV_Proposals || {};
      let resultado;
      if (voto.publicResult) {
        resultado = voto.publicResult;
      } else {
        resultado = desencriptarVotoConClavePrivada(voto.encryptedvote, privateKeyPem); //Si no es publico el voto lo desencriptamos con la clave privada del usuario
      }

      // Creamos un checksum para el log
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

      //Hacemos un trace para el log
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

      // Agregar el resultado al array de resultados que devolveremos
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