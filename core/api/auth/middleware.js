/**
 * Middleware de Autenticación JWT
 * Valida tokens y proporciona acceso a las claves del usuario
 */

const jwt = require('jsonwebtoken');
const sql = require('mssql');
const { decryptWithPassword } = require('../../src/utils/encrypvotesgenerator');

const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_firmar_tokens';

// Middleware de autenticación
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token de acceso requerido' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Token inválido o expirado' });
    }
    req.user = user;
    next();
  });
};

// Función para obtener las claves del usuario descifradas (requiere contraseña)
const getUserKeys = async (userId, password) => {
  try {
    await sql.connect(config);
    
    const result = await sql.query`
      SELECT encryptedpublickey, encryptedprivatekey, status
      FROM [dbo].[PV_CryptoKeys]
      WHERE userid = ${userId} AND status = 'active'
    `;

    if (result.recordset.length === 0) {
      throw new Error('No se encontraron claves activas para el usuario');
    }

    const keys = result.recordset[0];
    
    const publicKeyPem = decryptWithPassword(keys.encryptedpublickey, password);
    const privateKeyPem = decryptWithPassword(keys.encryptedprivatekey, password);

    return {
      publicKey: publicKeyPem,
      privateKey: privateKeyPem
    };

  } finally {
    try {
      await sql.close();
    } catch (closeError) {
      console.error('Error cerrando conexión:', closeError);
    }
  }
};

module.exports = {
  authenticateToken,
  getUserKeys
};
