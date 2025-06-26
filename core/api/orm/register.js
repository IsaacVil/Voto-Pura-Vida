/**
 * API de Registro de Usuarios
 * Integra con el sistema de criptografía existente
 */

const sql = require('mssql');
const { executeQuery, getPool } = require('../../src/config/database');
const { generateAndEncryptKeys } = require('../../src/utils/cryptopripubgenerator');
const { generateVerificationCode, sendVerificationEmail } = require('../../src/utils/emailService');
const { PROFESSIONAL_TEMPLATE } = require('../../src/utils/emailTemplates');

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
  let genderId;
  if (!gender) {
    genderId = 4; // Default: prefer-not-to-say
  } else if (typeof gender === 'number') {
    // Si ya es un número, validar que esté en el rango válido
    genderId = (gender >= 1 && gender <= 4) ? gender : 4;
  } else if (typeof gender === 'string') {
    // Si es string, usar el mapeo
    genderId = genderMap[gender.toLowerCase()] || 4;
  } else {
    genderId = 4; // Default para cualquier otro tipo
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
    // Verificar si el usuario ya existe
    const existingUser = await executeQuery(`
      SELECT userid FROM [dbo].[PV_Users] 
      WHERE email = @email OR dni = @dni
    `, { email, dni });

    if (existingUser.recordset.length > 0) {
      return res.status(409).json({ 
        error: 'Usuario ya existe con ese email o cédula' 
      });
    }

    // Crear el usuario con status 4 (inactive + unverified)
    const userResult = await executeQuery(`
      INSERT INTO [dbo].[PV_Users] (
        firstname, lastname, dni, email, 
        birthdate, createdAt, genderId, lastupdate, userStatusId
      ) 
      OUTPUT INSERTED.userid
      VALUES (
        @firstName, @lastName, @dni, @email,
        @birthdateFormatted, GETDATE(), @genderId, GETDATE(), 4
      )
    `, { 
      firstName, 
      lastName, 
      dni, 
      email, 
      birthdateFormatted, 
      genderId 
    });

    const userId = userResult.recordset[0].userid;

    // Generar y cifrar las claves criptográficas
    const keys = generateAndEncryptKeys(password);

    // Guardar las claves cifradas
    await executeQuery(`
      INSERT INTO [dbo].[PV_CryptoKeys] (
        encryptedpublickey, encryptedprivatekey, createdAt,
        userid, organizationid, expirationdate, status
      ) VALUES (
        @encryptedPublicKey, @encryptedPrivateKey, GETDATE(),
        @userId, NULL, DATEADD(year, 1, GETDATE()), 'active'
      )
    `, {
      encryptedPublicKey: keys.encryptedPublicKey,
      encryptedPrivateKey: keys.encryptedPrivateKey,
      userId
    });

    // 🔑 ASIGNAR PERMISOS BÁSICOS DE USUARIO
    const permisosBasicos = [
      2,  // Ver propuestas (PROP_VIEW)
      3,  // Ver votaciones (VOTE_VIEW)
      9,  // Ver propuestas públicas (PROP_PUB)
      11, // Crear propuestas (PROP_CRT) - ¡CLAVE!
      16, // Ver votaciones públicas (VOTE_PUB)
      18, // Participar en votaciones (VOTE_PART)
      22, // Ver inversiones públicas (INV_VIEW)
      23  // Realizar inversiones (INV_CRT)
    ];

    console.log(`Asignando ${permisosBasicos.length} permisos básicos al usuario ${userId}`);

    for (const permisoId of permisosBasicos) {
      try {
        // Generar un checksum simple basado en userId y permisoId
        const checksumData = `${userId}-${permisoId}-${Date.now()}`;
        await executeQuery(`
          INSERT INTO [dbo].[PV_UserPermissions] (userid, permissionid, enabled, deleted, lastupdate, checksum)
          VALUES (@userId, @permisoId, 1, 0, GETDATE(), HASHBYTES('SHA2_256', @checksumData))
        `, {
          userId,
          permisoId,
          checksumData
        });
      } catch (permError) {
        console.warn(`No se pudo asignar permiso ${permisoId}:`, permError.message);
      }
    }

    console.log(`✅ Usuario ${userId} registrado con permisos básicos asignados`);   

    // Generar y enviar código de verificación automáticamente
    const verificationCode = generateVerificationCode(email);
    const emailResult = await sendVerificationEmail(email, firstName, verificationCode, PROFESSIONAL_TEMPLATE);
    
    if (!emailResult.success) {
      console.warn(`❌ Error enviando email a ${email}:`, emailResult.error);
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
      details: process.env.NODE_ENV === 'development' ? error.message : 'Error durante el registro',
      sqlErrorNumber: error.number || undefined
    });
  }
};
