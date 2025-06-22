/**
 * API de Login de Usuarios
 * Integra con el sistema de criptografía existente y genera JWT
 */

const sql = require('mssql');
const jwt = require('jsonwebtoken');
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

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  const { email, password } = req.body;

  // Validación básica
  if (!email || !password) {
    return res.status(400).json({ 
      error: 'Email y contraseña son requeridos' 
    });
  }

  try {
    await sql.connect(config);    // Buscar usuario y sus claves
    const userResult = await sql.query`
      SELECT 
        u.userid, u.firstname, u.lastname, u.email,
        k.encryptedpublickey, k.encryptedprivatekey, k.status as keystatus
      FROM [dbo].[PV_Users] u
      LEFT JOIN [dbo].[PV_CryptoKeys] k ON u.userid = k.userid
      WHERE u.email = ${email}
    `;

    if (userResult.recordset.length === 0) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas' 
      });
    }    const user = userResult.recordset[0];

    // Verificar si tiene claves criptográficas
    if (!user.encryptedpublickey || !user.encryptedprivatekey) {
      return res.status(500).json({ 
        error: 'Usuario sin claves criptográficas configuradas' 
      });
    }

    // Intentar descifrar las claves con la contraseña proporcionada
    let publicKeyPem, privateKeyPem;
    try {
      publicKeyPem = decryptWithPassword(user.encryptedpublickey, password);
      privateKeyPem = decryptWithPassword(user.encryptedprivatekey, password);
    } catch (decryptError) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas' 
      });
    }

    // Si llegamos aquí, la contraseña es correcta (pudo descifrar las claves)
    const token = jwt.sign(
      {
        userId: user.userid,
        email: user.email,
        nombres: user.firstname,
        apellidos: user.lastname,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60) 
      },
      JWT_SECRET
    );


    res.status(200).json({
      success: true,
      message: 'Login exitoso',
      token: token,
      expiresIn: '24h'
    });

  } catch (error) {
    res.status(500).json({ 
      error: 'Error interno del servidor',
      details: error.message 
    });
  } finally {
    try {
      await sql.close();
    } catch (closeError) {
      console.error('Error cerrando conexión:', closeError);
    }
  }
};
