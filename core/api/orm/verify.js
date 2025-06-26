/**
 * API de Verificación de Usuarios
 * Usa códigos calculados (determinísticos) en lugar de almacenados
 */

const { generateVerificationCode, validateVerificationCode, sendVerificationEmail } = require('../../src/utils/emailService');
const { executeQuery, getPool, sql } = require('../../src/config/database');

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
    const pool = await getPool();

    // Buscar usuario por email
    const userResult = await pool.request()
      .input('email', sql.VarChar, email)
      .query(`
        SELECT userid, firstname, lastname, userStatusId 
        FROM [dbo].[PV_Users] 
        WHERE email = @email
      `);

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
    const pool = await getPool();

    // Buscar usuario por email
    const userResult = await pool.request()
      .input('email', sql.VarChar, email)
      .query(`
        SELECT userid, firstname, lastname, userStatusId 
        FROM [dbo].[PV_Users] 
        WHERE email = @email
      `);

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
    console.log(`🔍 Validando código para ${email}: ${code}`);
    const isValidCode = validateVerificationCode(email, code, 15); // 15 minutos de validez
    console.log(`📊 Resultado de validación: ${isValidCode}`);

    if (!isValidCode) {
      // Debug: generar código actual para comparar
      const currentCode = generateVerificationCode(email);
      console.log(`❌ Código inválido para ${email}: recibido="${code}", esperado="${currentCode}"`);
      return res.status(400).json({ 
        error: 'Código inválido o expirado' 
      });
    }

    // Activar usuario (userStatusId = 1: active + verified)
    await pool.request()
      .input('userid', sql.Int, user.userid)
      .query(`
        UPDATE [dbo].[PV_Users] 
        SET userStatusId = 1, lastupdate = GETDATE()
        WHERE userid = @userid
      `);    // Verificar si ya tiene MFA activado
    const existingMFA = await pool.request()
      .input('userid', sql.Int, user.userid)
      .query(`
        SELECT MFAid FROM [dbo].[PV_MFA] 
        WHERE userid = @userid AND enabled = 1
      `);

    // Activar MFA automáticamente (método 3 = Email) si no existe
    if (existingMFA.recordset.length === 0) {
      await pool.request()
        .input('userid', sql.Int, user.userid)
        .input('secret', sql.VarBinary, Buffer.from('email-verification-enabled'))
        .query(`
          INSERT INTO [dbo].[PV_MFA] (MFAmethodid, MFA_secret, createdAt, enabled, userid)
          VALUES (3, @secret, GETDATE(), 1, @userid)
        `);
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
  }
};

module.exports = {
  sendVerificationCode,
  verifyCode
};
