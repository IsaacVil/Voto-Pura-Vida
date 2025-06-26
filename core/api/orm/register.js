/**
 * API de Registro de Usuarios
 * Integra con el sistema de criptografía existente
 */

//Importamos las funciones necesarias
const sql = require('mssql');
const { executeQuery, getPool } = require('../../src/config/database');
const { generateAndEncryptKeys } = require('../../src/utils/cryptopripubgenerator');
const { generateVerificationCode, sendVerificationEmail } = require('../../src/utils/emailService');
const { PROFESSIONAL_TEMPLATE } = require('../../src/utils/emailTemplates');

module.exports = async (req, res) => {
  //Solo permitimos el método POST para registro
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }  
  //Obtenemos los datos del usuario
  const { firstName, lastName, dni, email, password, birthdate, gender } = req.body;

  //Asociamos el género elegido a un ID 
  const genderMap = {
    'male': 1,          
    'female': 2,        
    'non-binary': 3,     
    'prefer-not-to-say': 4 
  };

  // Validación básica
  if (!firstName || !lastName || !dni || !email || !password) {
    return res.status(400).json({ 
      error: 'Campos requeridos: firstName, lastName, dni, email, password' 
    });
  }

  // Validamos el género
  let genderId;
  //Si gender viene vacio se le asigna el ID 4
  if (!gender) {
    genderId = 4; 
  } else if (typeof gender === 'number') {
    // Si ya es un número, validar que esté en el rango válido
    genderId = (gender >= 1 && gender <= 4) ? gender : 4;
  } else if (typeof gender === 'string') {
    // Si es string, usamos el mapeo para asignar el ID
    genderId = genderMap[gender.toLowerCase()] || 4;
  } else {
    //Para cualquier otro tipo de datos, asignamos el ID 4
    genderId = 4; 
  }
 
  // Validamos el formato de email 
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ error: 'Formato de email inválido' });
  }

  // Validamos el largo de contraseña 
  if (password.length < 8) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 8 caracteres' });
  }

  // Validamos la fecha de nacimiento y le damos el formato correcto
  let birthdateFormatted = null;
  if (birthdate) {
    const dateObj = new Date(birthdate);
    // Validamos que la fecha sea válida
    if (isNaN(dateObj.getTime())) {
      return res.status(400).json({ error: 'Formato de fecha de nacimiento inválido. Use YYYY-MM-DD' });
    }
    // Formateamos para SQL Server
    birthdateFormatted = dateObj.toISOString().split('T')[0]; 
  }

  try {
    // Verificamos si el usuario ya existe 
    const existingUser = await executeQuery(`
      SELECT userid FROM [dbo].[PV_Users] 
      WHERE email = @email OR dni = @dni
    `, { email, dni });

    if (existingUser.recordset.length > 0) {
      return res.status(409).json({ 
        error: 'Usuario ya existe con ese email o cédula' 
      });
    }

    // Creamos el usuario con el status 4
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

    // Obtenemos el ID del usuario recién creado
    const userId = userResult.recordset[0].userid;

    // Generamos y ciframos las claves criptográficas con la contraseña
    const keys = generateAndEncryptKeys(password);

    // Guardamos las claves cifradas
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

    // Asignamos permisos básicos de un usuario
    const permisosBasicos = [
      2,  // Ver propuestas
      3,  // Ver votaciones 
      9,  // Ver propuestas públicas 
      11, // Crear propuestas 
      16, // Ver votaciones públicas 
      18, // Participar en votaciones
      22, // Ver inversiones públicas 
      23  // Realizar inversiones
    ];

    console.log(`Asignando ${permisosBasicos.length} permisos básicos al usuario ${userId}`);

    // Iteramos sobre cada permiso y lo asignamos al usuario
    for (const permisoId of permisosBasicos) {
      try {
        // Generamos un checksum simple basado en userId y permisoId
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

    console.log(`Usuario ${userId} registrado con permisos básicos asignados`);   

    // Generamos y enviamos un código de verificación automáticamente
    const verificationCode = generateVerificationCode(email);
    const emailResult = await sendVerificationEmail(email, firstName, verificationCode, PROFESSIONAL_TEMPLATE);
    
    if (!emailResult.success) {
      console.warn(`Error enviando email a ${email}:`, emailResult.error);
    } 

    // Respondemos con éxito e informamos sobre el codigo de verificación
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
