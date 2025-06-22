/**
 * Endpoint: /api/orm/auth/profile
 * Gestión del perfil de usuario en el sistema de voto electrónico
 * 
 * Funcionalidades:
 * - Obtener información del perfil
 * - Actualizar datos del usuario
 * - Configurar MFA
 * - Gestionar preferencias
 */

const { prisma, handlePrismaError, executeTransaction } = require('../../../src/config/prisma');
const { authenticate } = require('./middleware');
const bcrypt = require('bcryptjs');
const speakeasy = require('speakeasy');

module.exports = async (req, res) => {
  try {
    const { method } = req;

    // Aplicar autenticación a todas las rutas
    await new Promise((resolve, reject) => {
      authenticate(req, res, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    if (method === 'GET') {
      // Obtener perfil completo del usuario
      const userProfile = await prisma.PV_Users.findUnique({
        where: { userid: req.user.userid },
        include: {
          PV_Genders: true,
          PV_UserStatus: true,
          PV_UserAddresses: {
            include: {
              PV_Addresses: {
                include: {
                  PV_Cities: {
                    include: {
                      PV_States: {
                        include: {
                          PV_Countries: true
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          PV_UserRoles: {
            include: {
              PV_Roles: true
            }
          },
          PV_MFA: {
            include: {
              PV_MFAMethods: true
            }
          },
          PV_NotificationSettings: {
            include: {
              PV_NotificationMethods: true
            }
          },
          PV_UserSegments: {
            include: {
              PV_Segments: true
            }
          }
        }
      });

      if (!userProfile) {
        return res.status(404).json({
          error: 'Perfil de usuario no encontrado',
          timestamp: new Date().toISOString()
        });
      }

      // Formatear respuesta
      const profile = {
        personal: {
          userid: userProfile.userid,
          email: userProfile.email,
          firstname: userProfile.firstname,
          lastname: userProfile.lastname,
          birthdate: userProfile.birthdate,
          dni: userProfile.dni.toString(),
          gender: userProfile.PV_Genders?.gendername,
          status: userProfile.PV_UserStatus?.statusname,
          createdAt: userProfile.createdAt,
          lastUpdate: userProfile.lastupdate
        },
        addresses: userProfile.PV_UserAddresses.map(ua => ({
          type: ua.addresstype,
          line1: ua.PV_Addresses.line1,
          line2: ua.PV_Addresses.line2,
          zipcode: ua.PV_Addresses.zipcode,
          city: ua.PV_Addresses.PV_Cities.cityname,
          state: ua.PV_Addresses.PV_Cities.PV_States.statename,
          country: ua.PV_Addresses.PV_Cities.PV_States.PV_Countries.countryname
        })),
        roles: userProfile.PV_UserRoles.map(ur => ur.PV_Roles.rolename),
        segments: userProfile.PV_UserSegments.map(us => us.PV_Segments.segmentname),
        security: {
          mfaEnabled: userProfile.PV_MFA.some(mfa => mfa.enabled),
          mfaMethods: userProfile.PV_MFA.map(mfa => ({
            method: mfa.PV_MFAMethods.name,
            enabled: mfa.enabled,
            createdAt: mfa.createdAt
          }))
        },
        notifications: userProfile.PV_NotificationSettings.map(ns => ({
          method: ns.PV_NotificationMethods.name,
          enabled: ns.enabled
        }))
      };

      return res.status(200).json({
        success: true,
        data: profile,
        timestamp: new Date().toISOString()
      });

    } else if (method === 'PUT') {
      // Actualizar perfil del usuario
      const {
        firstname,
        lastname,
        email,
        currentPassword,
        newPassword,
        notificationSettings
      } = req.body;

      const result = await executeTransaction(async (tx) => {
        const updates = {};

        // Validar y actualizar campos básicos
        if (firstname) {
          updates.firstname = firstname.trim();
        }

        if (lastname) {
          updates.lastname = lastname.trim();
        }

        if (email) {
          // Verificar que el nuevo email no esté en uso
          const existingEmail = await tx.PV_Users.findFirst({
            where: { 
              email: email.toLowerCase().trim(),
              userid: { not: req.user.userid }
            }
          });

          if (existingEmail) {
            throw new Error('El email ya está en uso por otro usuario');
          }

          updates.email = email.toLowerCase().trim();
        }

        // Cambio de contraseña
        if (currentPassword && newPassword) {
          // En un sistema real, verificaríamos la contraseña actual hasheada
          // Por ahora, solo validamos que la nueva contraseña sea fuerte
          if (newPassword.length < 8) {
            throw new Error('La nueva contraseña debe tener al menos 8 caracteres');
          }

          // Aquí se hasearía y guardaría la nueva contraseña
          // updates.password_hash = await bcrypt.hash(newPassword, 12);
        }

        if (Object.keys(updates).length > 0) {
          updates.lastupdate = new Date();
          
          await tx.PV_Users.update({
            where: { userid: req.user.userid },
            data: updates
          });
        }

        // Actualizar configuraciones de notificación
        if (notificationSettings && Array.isArray(notificationSettings)) {
          for (const setting of notificationSettings) {
            await tx.PV_NotificationSettings.upsert({
              where: {
                userid_notificationmethodid: {
                  userid: req.user.userid,
                  notificationmethodid: setting.methodId
                }
              },
              update: {
                enabled: setting.enabled
              },
              create: {
                userid: req.user.userid,
                notificationmethodid: setting.methodId,
                enabled: setting.enabled,
                createddate: new Date()
              }
            });
          }
        }

        return { updated: true };
      });

      return res.status(200).json({
        success: true,
        message: 'Perfil actualizado exitosamente',
        data: result,
        timestamp: new Date().toISOString()
      });

    } else if (method === 'POST') {
      // Configurar o activar MFA
      const { action, mfaToken } = req.body;

      if (action === 'setup-totp') {
        // Generar secreto TOTP para configuración
        const secret = speakeasy.generateSecret({
          name: `Voto Pura Vida (${req.user.email})`,
          issuer: 'Voto Pura Vida'
        });

        // Guardar secreto temporal (no activado aún)
        await prisma.PV_MFA.upsert({
          where: {
            userid_MFAmethodid: {
              userid: req.user.userid,
              MFAmethodid: 1 // TOTP
            }
          },
          update: {
            MFA_secret: Buffer.from(secret.base32, 'base64'),
            enabled: false
          },
          create: {
            userid: req.user.userid,
            MFAmethodid: 1,
            MFA_secret: Buffer.from(secret.base32, 'base64'),
            createdAt: new Date(),
            enabled: false
          }
        });

        return res.status(200).json({
          success: true,
          data: {
            secret: secret.base32,
            qrCode: secret.otpauth_url,
            manualEntry: secret.base32
          },
          message: 'Escanee el código QR con su aplicación de autenticación',
          timestamp: new Date().toISOString()
        });

      } else if (action === 'verify-totp') {
        // Verificar y activar TOTP
        if (!mfaToken) {
          return res.status(400).json({
            error: 'Código MFA requerido para verificación',
            timestamp: new Date().toISOString()
          });
        }

        const mfaConfig = await prisma.PV_MFA.findFirst({
          where: {
            userid: req.user.userid,
            MFAmethodid: 1
          }
        });

        if (!mfaConfig) {
          return res.status(400).json({
            error: 'Configuración MFA no encontrada. Configure primero con setup-totp',
            timestamp: new Date().toISOString()
          });
        }

        const secretBase32 = mfaConfig.MFA_secret.toString('base64');
        const isValid = speakeasy.totp.verify({
          secret: secretBase32,
          encoding: 'base32',
          token: mfaToken,
          window: 2
        });

        if (!isValid) {
          return res.status(400).json({
            error: 'Código MFA inválido',
            timestamp: new Date().toISOString()
          });
        }

        // Activar MFA
        await prisma.PV_MFA.update({
          where: { MFAid: mfaConfig.MFAid },
          data: { enabled: true }
        });

        return res.status(200).json({
          success: true,
          message: 'MFA activado exitosamente',
          timestamp: new Date().toISOString()
        });

      } else if (action === 'disable-mfa') {
        // Desactivar MFA (requiere verificación)
        if (!mfaToken) {
          return res.status(400).json({
            error: 'Código MFA requerido para desactivar',
            timestamp: new Date().toISOString()
          });
        }

        const mfaConfig = await prisma.PV_MFA.findFirst({
          where: {
            userid: req.user.userid,
            enabled: true
          }
        });

        if (!mfaConfig) {
          return res.status(400).json({
            error: 'MFA no está activado',
            timestamp: new Date().toISOString()
          });
        }

        const secretBase32 = mfaConfig.MFA_secret.toString('base64');
        const isValid = speakeasy.totp.verify({
          secret: secretBase32,
          encoding: 'base32',
          token: mfaToken,
          window: 2
        });

        if (!isValid) {
          return res.status(400).json({
            error: 'Código MFA inválido',
            timestamp: new Date().toISOString()
          });
        }

        await prisma.PV_MFA.update({
          where: { MFAid: mfaConfig.MFAid },
          data: { enabled: false }
        });

        return res.status(200).json({
          success: true,
          message: 'MFA desactivado exitosamente',
          timestamp: new Date().toISOString()
        });

      } else {
        return res.status(400).json({
          error: 'Acción no válida',
          allowed: ['setup-totp', 'verify-totp', 'disable-mfa'],
          timestamp: new Date().toISOString()
        });
      }

    } else {
      return res.status(405).json({
        error: 'Método no permitido',
        allowed: ['GET', 'PUT', 'POST'],
        timestamp: new Date().toISOString()
      });
    }

  } catch (error) {
    console.error('Error en profile:', error);
    
    const prismaError = handlePrismaError(error);
    if (prismaError) {
      return res.status(400).json({
        error: prismaError,
        timestamp: new Date().toISOString()
      });
    }

    return res.status(500).json({
      error: error.message || 'Error interno del servidor',
      timestamp: new Date().toISOString()
    });
  }
};
