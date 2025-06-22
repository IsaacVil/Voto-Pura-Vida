/**
 * API de Registro de Usuarios
 * Integra con el sistema de criptografía existente
 */

const sql = require('mssql');
const { generateAndEncryptKeys } = require('../../src/utils/cryptopripubgenerator');
const { generateVerificationCode, sendVerificationEmail } = require('../../src/utils/emailService');
const { PROFESSIONAL_TEMPLATE } = require('../../src/utils/emailTemplates');

const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',  options: { encrypt: true, trustServerCertificate: true }
};

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }  const { firstName, lastName, dni, email, password, birthdate, gender } = req.body;

  // Mapeo de géneros en inglés a IDs
  const genderMap = {
    'male': 1,           // Masculino
    'female': 2,         // Femenino
    'non-binary': 3,     // No binario
    'prefer-not-to-say': 4  // Prefiero no decir
  };

  // Validación básica
  if (!firstName || !lastName || !dni || !email || !password) {
    return res.status(400).json({ 
      error: 'Campos requeridos: firstName, lastName, dni, email, password' 
    });
  }

  // Validar género
  const genderId = gender ? genderMap[gender.toLowerCase()] : 4; 
  if (gender && !genderId) {
    return res.status(400).json({ 
      error: 'Género inválido. Valores permitidos: male, female, non-binary, prefer-not-to-say' 
    });
  }

  // Validar formato de email básico
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ error: 'Formato de email inválido' });
  }

  // Validar contraseña mínima
  if (password.length < 8) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 8 caracteres' });
  }

  // Validar y formatear fecha de nacimiento
  let birthdateFormatted = null;
  if (birthdate) {
    const dateObj = new Date(birthdate);
    if (isNaN(dateObj.getTime())) {
      return res.status(400).json({ error: 'Formato de fecha de nacimiento inválido. Use YYYY-MM-DD' });
    }
    // Formatear para SQL Server
    birthdateFormatted = dateObj.toISOString().split('T')[0]; 
  }

  try {
    await sql.connect(config);
    // Verificar si el usuario ya existe
    const existingUser = await sql.query`
      SELECT userid FROM [dbo].[PV_Users] 
      WHERE email = ${email} OR dni = ${dni}
    `;

    if (existingUser.recordset.length > 0) {
      return res.status(409).json({ 
        error: 'Usuario ya existe con ese email o cédula' 
      });
    }    // Crear el usuario con status 4 (inactive + unverified)
    const userResult = await sql.query`
      INSERT INTO [dbo].[PV_Users] (
        firstname, lastname, dni, email, 
        birthdate, createdAt, genderId, lastupdate, userStatusId
      ) 
      OUTPUT INSERTED.userid
      VALUES (
        ${firstName}, ${lastName}, ${dni}, ${email},
        ${birthdateFormatted}, GETDATE(), ${genderId}, GETDATE(), 4
      )
    `;

    const userId = userResult.recordset[0].userid;

    // Generar y cifrar las claves criptográficas
    const keys = generateAndEncryptKeys(password);

    // Guardar las claves cifradas
    await sql.query`
      INSERT INTO [dbo].[PV_CryptoKeys] (
        encryptedpublickey, encryptedprivatekey, createdAt,
        userid, organizationid, expirationdate, status
      ) VALUES (
        ${keys.encryptedPublicKey}, ${keys.encryptedPrivateKey}, GETDATE(),
        ${userId}, NULL, DATEADD(year, 1, GETDATE()), 'active'
      )
    `;   

    // Generar y enviar código de verificación automáticamente
    const verificationCode = generateVerificationCode(email);
    const emailResult = await sendVerificationEmail(email, firstName, verificationCode, PROFESSIONAL_TEMPLATE);
    
    if (!emailResult.success) {
      console.warn(`Error enviando email a ${email}:`, emailResult.error);
    } 

    res.status(201).json({
      success: true,
      message: 'Usuario registrado exitosamente. Revisa tu email para verificar tu cuenta.',
      userId: userId,
      email: email,
      verificationSent: emailResult.success,
      nextStep: 'Revisa tu email y usa el código de 6 dígitos para verificar tu cuenta'
    });
  } catch (error) {
    console.error('Error en registro:', error);
    console.error('Stack trace:', error.stack);
    
    
    res.status(500).json({ 
      error: 'Error interno del servidor',
      details: error.message,
      sqlErrorNumber: error.number || undefined
    });
  } finally {
    try {
      await sql.close();
    } catch (closeError) {
      console.error('Error cerrando conexión:', closeError);
    }
  }
};
