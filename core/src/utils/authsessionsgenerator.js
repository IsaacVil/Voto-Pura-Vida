const { createHash, createDecipheriv, randomBytes } = require('crypto');
const sql = require('mssql');
const jwt = require('jsonwebtoken');
const JWT_SECRET = 'supersecreto_para_firmar_tokens';

const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',
  port: 14333,
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

let sessionCache = null; // Inicialmente null aca quedaran las llaves cuando se llame al lazy cache (no cambia el cache hasta que forcemos a regenerarlo)

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

async function generateAuthSessions() {
  if (sessionCache) return sessionCache; // Ya está inicializada la cache entonces se retorna directamente

  sessionCache = {};
  await sql.connect(config);

  const users = await sql.query`
    SELECT u.userid, u.email, k.encryptedpublickey, k.encryptedprivatekey
    FROM [dbo].[PV_Users] u
    JOIN [dbo].[PV_CryptoKeys] k ON u.userid = k.userid
    WHERE u.userid <> 13
  `;

  for (const user of users.recordset) {
    const password = 'holasoylapasswordquenoseguardarianormalmente'; // Aca simulamos que la gente esta dando su contraseña para desencriptar las llaves, en un caso real esto vendría de un input del usuario
    let publicKeyPem, privateKeyPem;
    try {
      publicKeyPem = decryptWithPassword(user.encryptedpublickey, password); // Desencriptamos las llaves con la contraseña
      privateKeyPem = decryptWithPassword(user.encryptedprivatekey, password);
    } catch (err) {
      continue;
    }
    const sessionId = randomBytes(16);
    const externalUser = randomBytes(16);
    //generamos el token y el refresh token
    // Usamos JWT (Json Web Token) para generar los tokens de acceso y refresh
    const token = jwt.sign(
      {
        sub: user.userid,
        email: user.email,
        sessionId: sessionId.toString('hex'),
        type: 'access'
      },
      JWT_SECRET,
      { expiresIn: '1h' }
    );
    const refreshToken = jwt.sign(
      {
        sub: user.userid,
        sessionId: sessionId.toString('hex'),
        type: 'refresh'
      },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Guardamos la sesión en la base de datos
    await sql.query`
      INSERT INTO [dbo].[PV_authSession] (
        sessionId, externalUser, token, refreshToken, userId, authPlatformId
      ) VALUES (
        ${sessionId},
        ${externalUser},
        ${Buffer.from(token, 'utf8')},
        ${Buffer.from(refreshToken, 'utf8')},
        ${user.userid},
        1
      )
    `;

    // Agregamos la sesión al cache
    // Guardamos las llaves y tokens en la cache
    // Asi las conseguiremos con el userid de manera rapida
    sessionCache[user.userid] = {
      publicKey: publicKeyPem,
      privateKey: privateKeyPem,
      sessionId: sessionId.toString('hex'),
      token,
      refreshToken
    };
  }
  await sql.close();
  return sessionCache;
}

// Función para obtener la cache, inicializándola si es necesario
async function getSessionCache() {
  if (!sessionCache) {
    await generateAuthSessions();
  }
  return sessionCache;
}

// Función para forzar la regeneración de las sesiones de autenticación
async function forceRegenerateAuthSessions() {
  sessionCache = null;
  return await generateAuthSessions();
}

module.exports = { getSessionCache, forceRegenerateAuthSessions };