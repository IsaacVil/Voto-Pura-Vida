// Librerías necesarias: npm install @prisma/client
const { createHash, createDecipheriv, privateDecrypt } = require('crypto');
const os = require('os');
const { PrismaClient } = require('../../src/generated/prisma'); // Ajusta la ruta si es necesario

const prisma = new PrismaClient();

// Desencripta la clave privada/pública
function decryptWithPassword(encrypted, password) {
  const buf = Buffer.isBuffer(encrypted) ? encrypted : Buffer.from(encrypted, 'base64');
  const iv = buf.slice(0, 16);
  if (iv.length !== 16) throw new Error('IV inválido');
  const data = buf.slice(16);
  const seed = createHash('sha512').update(password).digest().slice(0, 32);
  const decipher = createDecipheriv('aes-256-cbc', seed, iv);
  return Buffer.concat([
    decipher.update(data),
    decipher.final()
  ]).toString('utf8');
}

// Obtener usuarios verificados con MFA y validación de identidad
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

// Obtener TODOS los votos del usuario
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

// Obtener la clave privada cifrada del usuario
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

// Desencriptar el voto con la clave privada PEM
function desencriptarVotoConClavePrivada(encryptedVote, privateKeyPem) {
  try {
    const bufferVote = Buffer.isBuffer(encryptedVote) ? encryptedVote : Buffer.from(encryptedVote);
    const decrypted = privateDecrypt(
      {
        key: privateKeyPem,
        padding: require('crypto').constants.RSA_PKCS1_OAEP_PADDING
      },
      bufferVote
    );
    return decrypted.toString('utf8');
  } catch (e) {
    return `[Error al desencriptar: ${e.message}]`;
  }
}

// Handler para API REST (Express, Next.js API, etc.)
module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido, solo POST' });
  }

  const { userid, password } = req.body || {};

  if (!userid || !password) {
    return res.status(400).json({ error: 'Debe enviar userid y password en el body.' });
  }

  // Parámetros fijos para los logs (ajusta según tus tablas)
  const logtypeid = 1;
  const logsourceid = 1;
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