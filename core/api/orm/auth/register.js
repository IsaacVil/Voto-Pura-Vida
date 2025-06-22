/**
 * Endpoint: /api/orm/auth/register
 * Registro de nuevos usuarios en el sistema de voto electrónico
 * 
 * Validaciones implementadas:
 * - Datos básicos del usuario
 * - Validación de email único
 * - Validación de DNI único
 * - Generación de llaves criptográficas
 * - Configuración inicial de MFA
 * - Creación de sesión inicial
 * - Trazabilidad completa
 */

const { prisma, handlePrismaError, executeTransaction } = require('../../../src/config/prisma');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const speakeasy = require('speakeasy');
const { v4: uuidv4 } = require('uuid');
const { hashPassword, validatePasswordStrength, generateSalt } = require('./utils');

// Función para generar par de llaves criptográficas
function generateUserKeys(userPassword) {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: {
      type: 'spki',
      format: 'pem'
    },
    privateKeyEncoding: {
      type: 'pkcs8',
      format: 'pem'
    }
  });

  // Cifrar las llaves con la contraseña del usuario
  const algorithm = 'aes-256-cbc';
  const key = crypto.scryptSync(userPassword, 'voto-pura-vida-salt', 32);
  
  // Cifrar llave privada
  const ivPrivate = crypto.randomBytes(16);
  const cipherPrivate = crypto.createCipher(algorithm, key);
  const encryptedPrivateKey = Buffer.concat([
    ivPrivate,
    cipherPrivate.update(privateKey, 'utf8'),
    cipherPrivate.final()
  ]);

  // Cifrar llave pública
  const ivPublic = crypto.randomBytes(16);
  const cipherPublic = crypto.createCipher(algorithm, key);
  const encryptedPublicKey = Buffer.concat([
    ivPublic,
    cipherPublic.update(publicKey, 'utf8'),
    cipherPublic.final()
  ]);

  return {
    encryptedPrivateKey,
    encryptedPublicKey,
    publicKeyPem: publicKey // Para verificaciones futuras
  };
}

// Función para validar formato de email
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Función para validar DNI costarricense
function isValidDNI(dni) {
  const dniStr = dni.toString();
  return dniStr.length >= 9 && dniStr.length <= 12 && /^\d+$/.test(dniStr);
}

module.exports = async (req, res) => {
  try {
    const { method } = req;

    if (method === 'POST') {
      const {
        email,
        password,
        firstname,
        lastname,
        birthdate,
        dni,
        genderId = 1 // Masculino por defecto, debería venir del frontend
      } = req.body;

      // Validaciones básicas
      if (!email || !password || !firstname || !lastname || !birthdate || !dni) {
        return res.status(400).json({
          error: 'Todos los campos son obligatorios',
          required: ['email', 'password', 'firstname', 'lastname', 'birthdate', 'dni'],
          timestamp: new Date().toISOString()
        });
      }

      // Validaciones de formato
      if (!isValidEmail(email)) {
        return res.status(400).json({
          error: 'Formato de email inválido',
          timestamp: new Date().toISOString()
        });
      }

      if (!isValidDNI(dni)) {
        return res.status(400).json({
          error: 'DNI debe tener entre 9 y 12 dígitos',
          timestamp: new Date().toISOString()
        });
      }      if (password.length < 8) {
        return res.status(400).json({
          error: 'La contraseña debe tener al menos 8 caracteres',
          timestamp: new Date().toISOString()
        });
      }

      // Validar fortaleza de contraseña
      const passwordValidation = validatePasswordStrength(password);
      if (!passwordValidation.isValid) {
        return res.status(400).json({
          error: 'Contraseña no cumple con los requisitos de seguridad',
          details: passwordValidation.errors,
          timestamp: new Date().toISOString()
        });
      }

      // Validar fecha de nacimiento
      const birthDate = new Date(birthdate);
      const today = new Date();
      const age = today.getFullYear() - birthDate.getFullYear();
      
      if (age < 18) {
        return res.status(400).json({
          error: 'Debe ser mayor de 18 años para registrarse',
          timestamp: new Date().toISOString()
        });
      }

      const result = await executeTransaction(async (tx) => {
        // Verificar que email no exista
        const existingEmail = await tx.PV_Users.findFirst({
          where: { email: email.toLowerCase().trim() }
        });

        if (existingEmail) {
          throw new Error('El email ya está registrado en el sistema');
        }

        // Verificar que DNI no exista
        const existingDNI = await tx.PV_Users.findFirst({
          where: { dni: BigInt(dni) }
        });

        if (existingDNI) {
          throw new Error('El DNI ya está registrado en el sistema');
        }        // Hash de la contraseña
        const passwordHash = await hashPassword(password);
        const salt = generateSalt();

        // Generar llaves criptográficas
        const userKeys = generateUserKeys(password);

        // Crear el usuario
        const newUser = await tx.PV_Users.create({
          data: {
            email: email.toLowerCase().trim(),
            firstname: firstname.trim(),
            lastname: lastname.trim(),
            birthdate: new Date(birthdate),
            dni: BigInt(dni),
            genderId: parseInt(genderId),
            createdAt: new Date(),
            lastupdate: new Date(),
            userStatusId: 1 // Activo por defecto
          }
        });

        // Guardar contraseña
        await tx.PV_UserPasswords.create({
          data: {
            userId: newUser.userid,
            passwordHash: passwordHash,
            salt: salt,
            algorithm: 'bcrypt',
            iterations: 12,
            createdDate: new Date(),
            isActive: true
          }
        });

        // Guardar llaves criptográficas
        await tx.PV_CryptoKeys.create({
          data: {
            userid: newUser.userid,
            publickey: userKeys.encryptedPublicKey,
            privatekey: userKeys.encryptedPrivateKey,
            keytype: 'RSA-2048',
            createddate: new Date(),
            isactive: true
          }
        });

        // Configurar MFA inicial (TOTP)
        const mfaSecret = speakeasy.generateSecret({
          name: `Voto Pura Vida (${email})`,
          issuer: 'Voto Pura Vida'
        });

        await tx.PV_MFA.create({
          data: {
            userid: newUser.userid,
            MFAmethodid: 1, // TOTP method
            MFA_secret: Buffer.from(mfaSecret.base32, 'base64'),
            createdAt: new Date(),
            enabled: false // Se habilitará cuando el usuario verifique el TOTP
          }
        });

        // Crear sesión inicial (almacenar hash de contraseña para autenticación)
        const sessionId = crypto.randomBytes(16);
        const token = jwt.sign(
          { 
            userId: newUser.userid, 
            email: newUser.email,
            sessionId: sessionId.toString('hex')
          },
          process.env.JWT_SECRET || 'voto-pura-vida-secret-key',
          { expiresIn: '24h' }
        );

        const refreshToken = jwt.sign(
          { 
            userId: newUser.userid,
            type: 'refresh' 
          },
          process.env.JWT_REFRESH_SECRET || 'voto-pura-vida-refresh-secret',
          { expiresIn: '7d' }
        );

        await tx.PV_authSession.create({
          data: {
            sessionId: sessionId,
            externalUser: crypto.randomBytes(16),
            token: Buffer.from(token),
            refreshToken: Buffer.from(refreshToken),
            userId: newUser.userid
          }
        });

        // Crear configuración de notificaciones por defecto
        await tx.PV_NotificationSettings.create({
          data: {
            userid: newUser.userid,
            notificationmethodid: 1, // Email por defecto
            enabled: true,
            createddate: new Date()
          }
        });

        return {
          user: {
            userid: newUser.userid,
            email: newUser.email,
            firstname: newUser.firstname,
            lastname: newUser.lastname,
            createdAt: newUser.createdAt
          },
          authentication: {
            token,
            refreshToken,
            expiresIn: '24h'
          },
          mfa: {
            secret: mfaSecret.base32,
            qrCode: mfaSecret.otpauth_url,
            enabled: false
          }
        };
      });

      return res.status(201).json({
        success: true,
        message: 'Usuario registrado exitosamente',
        data: result,
        timestamp: new Date().toISOString()
      });

    } else if (method === 'GET') {
      // Endpoint para verificar disponibilidad de email/DNI
      const { email, dni } = req.query;

      if (email) {
        const existingEmail = await prisma.PV_Users.findFirst({
          where: { email: email.toLowerCase().trim() }
        });

        return res.status(200).json({
          available: !existingEmail,
          type: 'email',
          timestamp: new Date().toISOString()
        });
      }

      if (dni) {
        const existingDNI = await prisma.PV_Users.findFirst({
          where: { dni: BigInt(dni) }
        });

        return res.status(200).json({
          available: !existingDNI,
          type: 'dni',
          timestamp: new Date().toISOString()
        });
      }

      return res.status(400).json({
        error: 'Debe proporcionar email o dni para verificar disponibilidad',
        timestamp: new Date().toISOString()
      });

    } else {
      return res.status(405).json({
        error: 'Método no permitido',
        allowed: ['POST', 'GET'],
        timestamp: new Date().toISOString()
      });
    }

  } catch (error) {
    console.error('Error en registro:', error);
    
    const prismaError = handlePrismaError(error);
    if (prismaError) {
      return res.status(400).json({
        error: prismaError,
        timestamp: new Date().toISOString()
      });
    }

    return res.status(500).json({
      error: error.message || 'Error interno del servidor durante el registro',
      timestamp: new Date().toISOString()
    });
  }
};
