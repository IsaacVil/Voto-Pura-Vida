/**
 * API de Verificación de Usuarios
 * Usa códigos calculados (determinísticos) en lugar de almacenados
 */

const sql = require('mssql');
const { generateVerificationCode, validateVerificationCode, sendVerificationEmail } = require('../../src/utils/emailService');

const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

module.exports = async (req, res) => {
  if (req.method === 'POST' && req.url?.includes('/send-code')) {
    return await sendVerificationCode(req, res);
  }
  
  if (req.method === 'POST' && req.url?.includes('/verify-code')) {
    return await verifyCode(req, res);
  }

  return res.status(405).json({ error: 'Método no permitido' });
};

// Enviar código de verificación calculado
const sendVerificationCode = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ 
      error: 'Email es requerido' 
    });
  }

  try {
    await sql.connect(config);

    // Buscar usuario por email
    const userResult = await sql.query`
      SELECT userid, firstname, lastname, userStatusId 
      FROM [dbo].[PV_Users] 
      WHERE email = ${email}
    `;

    if (userResult.recordset.length === 0) {
      return res.status(404).json({ 
        error: 'Usuario no encontrado' 
      });
    }

    const user = userResult.recordset[0];

    // Verificar si ya está verificado
    if (user.userStatusId === 1) {
      return res.status(400).json({ 
        error: 'Usuario ya está verificado' 
      });
    }

    // Generar código de verificación determinístico (calculado, no almacenado)
    const verificationCode = generateVerificationCode(email);

    // Enviar email con el código
    const emailResult = await sendVerificationEmail(email, user.firstname, verificationCode);

    if (!emailResult.success) {
      return res.status(500).json({ 
        error: 'Error enviando email de verificación',
        details: emailResult.error 
      });
    }

    res.status(200).json({
      success: true,
      message: 'Código de verificación enviado',
      email: email,
      expiresIn: '15 minutos'
    });

  } catch (error) {
    console.error('❌ Error enviando código:', error);
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

// Verificar código calculado y activar usuario
const verifyCode = async (req, res) => {
  const { email, code } = req.body;

  if (!email || !code) {
    return res.status(400).json({ 
      error: 'Email y código son requeridos' 
    });
  }

  try {
    await sql.connect(config);

    // Buscar usuario por email
    const userResult = await sql.query`
      SELECT userid, firstname, lastname, userStatusId 
      FROM [dbo].[PV_Users] 
      WHERE email = ${email}
    `;

    if (userResult.recordset.length === 0) {
      return res.status(404).json({ 
        error: 'Usuario no encontrado' 
      });
    }

    const user = userResult.recordset[0];

    // Verificar si ya está verificado
    if (user.userStatusId === 1) {
      return res.status(400).json({ 
        error: 'Usuario ya está verificado' 
      });
    }

    // Validar código usando la función determinística
    const isValidCode = validateVerificationCode(email, code, 15); // 15 minutos de validez

    if (!isValidCode) {
      console.log(`❌ Código inválido para ${email}: ${code}`);
      return res.status(400).json({ 
        error: 'Código inválido o expirado' 
      });
    }

    // Activar usuario (userStatusId = 1: active + verified)
    await sql.query`
      UPDATE [dbo].[PV_Users] 
      SET userStatusId = 1, lastupdate = GETDATE()
      WHERE userid = ${user.userid}
    `;    // Verificar si ya tiene MFA activado
    const existingMFA = await sql.query`
      SELECT MFAid FROM [dbo].[PV_MFA] 
      WHERE userid = ${user.userid} AND enabled = 1
    `;

    // Activar MFA automáticamente (método 3 = Email) si no existe
    if (existingMFA.recordset.length === 0) {
      await sql.query`
        INSERT INTO [dbo].[PV_MFA] (MFAmethodid, MFA_secret, createdAt, enabled, userid)
        VALUES (3, ${Buffer.from('email-verification-enabled')}, GETDATE(), 1, ${user.userid})
      `;
    }

    res.status(200).json({
      success: true,
      message: 'Usuario verificado y activado exitosamente',
      userId: user.userid,
      email: email,
      status: 'verified',
      mfaEnabled: true
    });

  } catch (error) {
    console.error('❌ Error verificando código:', error);
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
