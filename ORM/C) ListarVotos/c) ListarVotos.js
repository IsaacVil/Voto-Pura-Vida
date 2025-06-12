// Librerías necesarias: npm install mssql
// holasoylapasswordquenoseguardarianormalmente contraseña de prueba
const { createHash, createDecipheriv, privateDecrypt } = require('crypto');
const sql = require('mssql');
const os = require('os');
const readline = require('readline');

// Configuración de conexión a SQL Server
const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',   
  port: 14333,             
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};
// Desencripta la clave privada/pública (igual que en encrypvotesgenerator.js)
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

// Función para obtener los usuarios verificados con MFA y validación de identidad
async function obtenerUsuariosVerificados() {
  const pool = await sql.connect(config);
  const result = await pool.request().query(`
    SELECT u.userid, g.name as gender
    FROM PV_Users u
    JOIN PV_UserStatus us ON u.userStatusId = us.userStatusId
    JOIN PV_Genders g ON u.genderId = g.genderId
    JOIN PV_MFA mfa ON u.userid = mfa.userid
    WHERE us.verified = 1 AND us.active = 1 AND mfa.enabled = 1
      AND EXISTS (
        SELECT 1 FROM PV_IdentityUserValidation iuv
        JOIN PV_IdentityValidations iv ON iuv.validationid = iv.validationid
        WHERE iuv.userid = u.userid AND iv.verified = 1
      )
  `);
  return result.recordset;
}

// Función para obtener TODOS los votos del usuario (públicos y privados)
async function obtenerTodosLosVotosDelUsuario(userid) {
  const pool = await sql.connect(config);
  const result = await pool.request()
    .input('userid', sql.Int, userid)
    .query(`
      SELECT p.proposalid, p.title, p.createdon, v.publicResult, v.votedate, v.encryptedvote
      FROM PV_Proposals p
      JOIN PV_VotingConfigurations vc ON p.proposalid = vc.proposalid
      JOIN PV_Votes v ON vc.votingconfigid = v.votingconfigid
      WHERE v.userId = @userid
      ORDER BY v.votedate DESC
    `);
  return result.recordset;
}

// Función para obtener la clave privada cifrada del usuario
async function obtenerClavePrivadaCifrada(userid) {
  const pool = await sql.connect(config);
  const result = await pool.request()
    .input('userid', sql.Int, userid)
    .query(`
      SELECT encryptedprivatekey FROM PV_CryptoKeys WHERE userid = @userid
    `);
  if (result.recordset.length === 0) return null;
  return result.recordset[0].encryptedprivatekey;
}

// Función para crear un log en la tabla PV_Logs
async function crearLogVoto(pool, log) {
  await pool.request()
    .input('description', sql.NVarChar(120), log.description)
    .input('name', sql.NVarChar(50), log.name)
    .input('posttime', sql.DateTime, log.posttime)
    .input('computer', sql.NVarChar(45), log.computer)
    .input('trace', sql.NVarChar(200), log.trace)
    .input('referenceid1', sql.BigInt, log.referenceid1)
    .input('referenceid2', sql.BigInt, log.referenceid2)
    .input('checksum', sql.VarBinary(250), log.checksum)
    .input('logtypeid', sql.Int, log.logtypeid)
    .input('logsourceid', sql.Int, log.logsourceid)
    .input('logseverityid', sql.Int, log.logseverityid)
    .input('value1', sql.NVarChar(250), log.value1)
    .input('value2', sql.NVarChar(250), log.value2)
    .query(`
      INSERT INTO PV_Logs
      (description, name, posttime, computer, trace, referenceid1, referenceid2, checksum, logtypeid, logsourceid, logseverityid, value1, value2)
      VALUES (@description, @name, @posttime, @computer, @trace, @referenceid1, @referenceid2, @checksum, @logtypeid, @logsourceid, @logseverityid, @value1, @value2)
    `);
}

// Función para desencriptar el voto con la clave privada PEM
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

// Función para pedir la contraseña por consola de forma segura
function pedirPassword(promptText) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    rl.stdoutMuted = true;
    rl.question(promptText, (password) => {
      rl.close();
      console.log('');
      resolve(password);
    });
    rl._writeToOutput = function _writeToOutput(stringToWrite) {
      if (rl.stdoutMuted) rl.output.write("*");
      else rl.output.write(stringToWrite);
    };
  });
}

// Función principal
async function main() {
  const pool = await sql.connect(config);

  // Parámetros fijos para los logs (ajusta según tus tablas)
  const logtypeid = 1;
  const logsourceid = 1;
  const logseverityid = 1;

  const useridunitario = 1;
  const usuarios = await obtenerUsuariosVerificados();
  const usuarioVerificado = usuarios.some(u => u.userid === useridunitario);

  if (usuarioVerificado) {
    const votos = await obtenerTodosLosVotosDelUsuario(useridunitario);
    if (votos.length > 0) {
      // Pedir la contraseña al usuario
      const password = await pedirPassword("Contraseña del usuario a consultar: ");

      // Obtener la clave privada cifrada y desencriptarla
      const encryptedPrivateKey = await obtenerClavePrivadaCifrada(useridunitario);
      if (!encryptedPrivateKey) {
        console.log("No se encontró la clave privada cifrada para este usuario.");
        await pool.close();
        return;
      }
      let privateKeyPem;
      try {
        privateKeyPem = decryptWithPassword(encryptedPrivateKey, password);
      } catch (err) {
        console.log("Error al desencriptar la clave privada:", err.message);
        await pool.close();
        return;
      }

      console.log("");
      console.log(`Top Votos del Usuario Verificado: ${useridunitario}-----------------------------------------------------------------------------------------------------------`);
      for (const voto of votos) {
        let resultado;
        if (voto.publicResult) {
          resultado = voto.publicResult;
        } else {
          resultado = desencriptarVotoConClavePrivada(voto.encryptedvote, privateKeyPem);
        }
        console.log(`ID de la propuesta: ${voto.proposalid}, Título: ${voto.title}, Fecha creación: ${voto.createdon}`);
        console.log(`Voto del usuario: ${resultado}`);
        console.log(`Fecha del voto: ${voto.votedate}`);

        // Crear el string para el checksum con todos los datos relevantes del log
        const checksum_str = [
          useridunitario,
          voto.proposalid,
          resultado,
          voto.createdon,
          "LecturaVotoUsuario",
          os.hostname(),
          new Date().toISOString(),
          resultado,
          voto.votedate
        ].join('|');
        const checksum_bytes = createHash('sha512').update(checksum_str, 'utf8').digest();

        // Recortar trace si es necesario (por límite de columna)
        let trace_text = `Voto: ${resultado}, Fecha del Voto: ${voto.votedate},Fecha de creacion de la Propuesta: ${voto.createdon}`;
        if (trace_text.length > 200) trace_text = trace_text.slice(0, 200);

        // Guardar log por cada voto mostrado
        await crearLogVoto(pool, {
          description: `Lectura voto usuario ${useridunitario} propuesta ${voto.proposalid}`,
          name: "LecturaVotoUsuario",
          posttime: new Date(),
          computer: os.hostname(),
          trace: trace_text,
          referenceid1: useridunitario,
          referenceid2: voto.proposalid,
          checksum: checksum_bytes,
          logtypeid,
          logsourceid,
          logseverityid,
          value1: String(resultado),
          value2: String(voto.votedate)
        });
      }
      console.log("------------------------------------------------------------------------------------------------------------------------------------------------------");
      console.log(" ");
    } else {
      console.log(" ");
      console.log("Este Usuario no tiene votos validos para la lectura");
      console.log(" ");
    }
  } else {
    console.log(" ");
    console.log(`El usuario ${useridunitario} no cumple las condiciones, puede que no tenga MFA, no este habilitado, este inactivo o sin verificar`);
    console.log(" ");
  }

  await pool.close();
}

main().catch(err => {
  console.error("Error:", err);
});