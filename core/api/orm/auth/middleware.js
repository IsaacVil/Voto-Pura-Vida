/**
 * Middleware de autenticación para el sistema Voto Pura Vida
 * Valida tokens JWT y verifica permisos de usuario
 */

const jwt = require('jsonwebtoken');
const { prisma } = require('../../../src/config/prisma');

/**
 * Middleware de autenticación básica
 * Verifica que el usuario esté autenticado con un token válido
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Token de autorización requerido',
        message: 'Incluya "Authorization: Bearer <token>" en los headers',
        timestamp: new Date().toISOString()
      });
    }

    const token = authHeader.substring(7);

    // Verificar token JWT
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'voto-pura-vida-secret-key'
    );

    // Verificar que la sesión exista en la base de datos
    const session = await prisma.PV_authSession.findFirst({
      where: {
        userId: decoded.userId,
        token: Buffer.from(token)
      },
      include: {
        PV_Users: {
          include: {
            PV_UserStatus: true,
            PV_UserRoles: {
              include: {
                PV_Roles: true
              }
            }
          }
        }
      }
    });

    if (!session) {
      return res.status(401).json({
        error: 'Sesión inválida o expirada',
        message: 'Por favor, inicie sesión nuevamente',
        timestamp: new Date().toISOString()
      });
    }

    // Verificar que el usuario esté activo
    if (!session.PV_Users.PV_UserStatus || session.PV_Users.PV_UserStatus.statusname !== 'Activo') {
      return res.status(403).json({
        error: 'Usuario inactivo',
        message: 'Su cuenta ha sido desactivada. Contacte al administrador.',
        timestamp: new Date().toISOString()
      });
    }

    // Agregar información del usuario al request
    req.user = {
      userid: session.PV_Users.userid,
      email: session.PV_Users.email,
      firstname: session.PV_Users.firstname,
      lastname: session.PV_Users.lastname,
      dni: session.PV_Users.dni,
      sessionId: decoded.sessionId,
      roles: session.PV_Users.PV_UserRoles.map(ur => ur.PV_Roles.rolename)
    };

    // Actualizar última actividad (opcional, puede ser costoso en alta concurrencia)
    // await prisma.PV_Users.update({
    //   where: { userid: session.PV_Users.userid },
    //   data: { lastupdate: new Date() }
    // });

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Token inválido',
        message: 'El token de autorización no es válido',
        timestamp: new Date().toISOString()
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token expirado',
        message: 'Su sesión ha expirado. Por favor, inicie sesión nuevamente',
        timestamp: new Date().toISOString()
      });
    }

    console.error('Error en middleware de autenticación:', error);
    return res.status(500).json({
      error: 'Error interno del servidor',
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Middleware para verificar permisos específicos
 * @param {string|Array} requiredPermissions - Permisos requeridos
 */
const authorize = (requiredPermissions) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          error: 'Usuario no autenticado',
          timestamp: new Date().toISOString()
        });
      }

      // Obtener permisos del usuario
      const userPermissions = await prisma.PV_UserPermissions.findMany({
        where: { userid: req.user.userid },
        include: {
          PV_Permissions: true
        }
      });

      const userPermissionNames = userPermissions.map(up => up.PV_Permissions.permissionname);

      // Verificar permisos
      const permissions = Array.isArray(requiredPermissions) ? requiredPermissions : [requiredPermissions];
      const hasPermission = permissions.some(permission => userPermissionNames.includes(permission));

      if (!hasPermission) {
        return res.status(403).json({
          error: 'Permisos insuficientes',
          required: permissions,
          current: userPermissionNames,
          timestamp: new Date().toISOString()
        });
      }

      next();
    } catch (error) {
      console.error('Error en middleware de autorización:', error);
      return res.status(500).json({
        error: 'Error interno del servidor',
        timestamp: new Date().toISOString()
      });
    }
  };
};

/**
 * Middleware para verificar roles específicos
 * @param {string|Array} requiredRoles - Roles requeridos
 */
const requireRole = (requiredRoles) => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          error: 'Usuario no autenticado',
          timestamp: new Date().toISOString()
        });
      }

      const roles = Array.isArray(requiredRoles) ? requiredRoles : [requiredRoles];
      const hasRole = roles.some(role => req.user.roles.includes(role));

      if (!hasRole) {
        return res.status(403).json({
          error: 'Rol insuficiente',
          required: roles,
          current: req.user.roles,
          timestamp: new Date().toISOString()
        });
      }

      next();
    } catch (error) {
      console.error('Error en middleware de roles:', error);
      return res.status(500).json({
        error: 'Error interno del servidor',
        timestamp: new Date().toISOString()
      });
    }
  };
};

/**
 * Middleware opcional de autenticación
 * Agrega información del usuario si está autenticado, pero no bloquea si no lo está
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      req.user = null;
      return next();
    }

    const token = authHeader.substring(7);

    try {
      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || 'voto-pura-vida-secret-key'
      );

      const session = await prisma.PV_authSession.findFirst({
        where: {
          userId: decoded.userId,
          token: Buffer.from(token)
        },
        include: {
          PV_Users: {
            include: {
              PV_UserStatus: true,
              PV_UserRoles: {
                include: {
                  PV_Roles: true
                }
              }
            }
          }
        }
      });

      if (session && session.PV_Users.PV_UserStatus?.statusname === 'Activo') {
        req.user = {
          userid: session.PV_Users.userid,
          email: session.PV_Users.email,
          firstname: session.PV_Users.firstname,
          lastname: session.PV_Users.lastname,
          dni: session.PV_Users.dni,
          sessionId: decoded.sessionId,
          roles: session.PV_Users.PV_UserRoles.map(ur => ur.PV_Roles.rolename)
        };
      } else {
        req.user = null;
      }
    } catch (error) {
      req.user = null;
    }

    next();
  } catch (error) {
    console.error('Error en middleware de autenticación opcional:', error);
    req.user = null;
    next();
  }
};

module.exports = {
  authenticate,
  authorize,
  requireRole,
  optionalAuth
};
