/**
 * API de Login de Usuarios
 * Integra con el sistema de criptografía existente y genera JWT
 */

//Importamos las funciones necesarias
const sql = require('mssql');
const jwt = require('jsonwebtoken');
const { decryptWithPassword } = require('../../src/utils/encrypvotesgenerator');

// Configuración de la conexión a la base de datos
const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

// Clave secreta para firmar los JWT
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_firmar_tokens';

module.exports = async (req, res) => {
  // Solo permitimos el método POST para login
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  // Obtenemos los datos del usuario
  const { email, password } = req.body;

  // Validación básica
  if (!email || !password) {
    return res.status(400).json({ 
      error: 'Email y contraseña son requeridos' 
    });
  }

  try {
    await sql.connect(config);    
    //Obtenemos el usuario por email y con sus claves criptográficas
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

    // Verificamos si tiene claves criptográficas
    if (!user.encryptedpublickey || !user.encryptedprivatekey) {
      return res.status(500).json({ 
        error: 'Usuario sin claves criptográficas configuradas' 
      });
    }

    // Intentamos descifrar las claves con la contraseña proporcionada
    let publicKeyPem, privateKeyPem;
    try {
      publicKeyPem = decryptWithPassword(user.encryptedpublickey, password);
      privateKeyPem = decryptWithPassword(user.encryptedprivatekey, password);
    } catch (decryptError) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas' 
      });
    }

    //Como la contrasela es correcta, generamos un token para la sesión
    const token = jwt.sign(
      {
        userId: user.userid,
        email: user.email,
        nombres: user.firstname,
        apellidos: user.lastname,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60) 
      },
      JWT_SECRET //Firmamos el token con la clave secreta
    );

    // Respondemos con mensaje de éxito
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
