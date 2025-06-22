# API de Autenticación - Voto Pura Vida

## Descripción

Sistema de autenticación completo para la plataforma de voto electrónico y crowdfunding. Incluye registro de usuarios, login con MFA opcional, gestión de sesiones y perfiles.

## Endpoints Disponibles

### 🔐 Autenticación

#### 1. Registro de Usuario
**POST** `/api/orm/auth/register`

Registra un nuevo usuario en el sistema con validaciones completas y generación de llaves criptográficas.

**Request Body:**
```json
{
  "email": "usuario@example.com",
  "password": "MiPassword123!",
  "firstname": "Juan",
  "lastname": "Pérez",
  "birthdate": "1990-05-15",
  "dni": "123456789012",
  "genderId": 1
}
```

**Response (201 - Success):**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "data": {
    "user": {
      "userid": 123,
      "email": "usuario@example.com",
      "firstname": "Juan",
      "lastname": "Pérez",
      "createdAt": "2025-06-19T10:30:00.000Z"
    },
    "authentication": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": "24h"
    },
    "mfa": {
      "secret": "JBSWY3DPEHPK3PXP",
      "qrCode": "otpauth://totp/Voto%20Pura%20Vida...",
      "enabled": false
    }
  },
  "timestamp": "2025-06-19T10:30:00.000Z"
}
```

#### 2. Verificar Disponibilidad
**GET** `/api/orm/auth/register?email=test@example.com`
**GET** `/api/orm/auth/register?dni=123456789`

Verifica si un email o DNI ya está registrado.

**Response:**
```json
{
  "available": true,
  "type": "email",
  "timestamp": "2025-06-19T10:30:00.000Z"
}
```

#### 3. Iniciar Sesión
**POST** `/api/orm/auth/login`

Autentica un usuario y genera tokens de sesión.

**Request Body:**
```json
{
  "email": "usuario@example.com",
  "password": "MiPassword123!",
  "mfaToken": "123456",
  "rememberDevice": false
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "user": {
      "userid": 123,
      "email": "usuario@example.com",
      "firstname": "Juan",
      "lastname": "Pérez",
      "lastLogin": "2025-06-19T10:30:00.000Z"
    },
    "authentication": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": "24h",
      "sessionId": "abc123def456"
    },
    "security": {
      "mfaEnabled": true,
      "hasKeys": true
    }
  },
  "timestamp": "2025-06-19T10:30:00.000Z"
}
```

#### 4. Renovar Token
**PUT** `/api/orm/auth/login`

Renueva el token de acceso usando el refresh token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### 5. Cerrar Sesión
**DELETE** `/api/orm/auth/login`

Cierra la sesión actual invalidando los tokens.

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 👤 Gestión de Perfil

#### 6. Obtener Perfil
**GET** `/api/orm/auth/profile`

Obtiene la información completa del perfil del usuario autenticado.

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "data": {
    "personal": {
      "userid": 123,
      "email": "usuario@example.com",
      "firstname": "Juan",
      "lastname": "Pérez",
      "birthdate": "1990-05-15T00:00:00.000Z",
      "dni": "123456789012",
      "gender": "Masculino",
      "status": "Activo",
      "createdAt": "2025-06-19T10:30:00.000Z",
      "lastUpdate": "2025-06-19T10:30:00.000Z"
    },
    "addresses": [],
    "roles": ["Usuario"],
    "segments": ["Ciudadano"],
    "security": {
      "mfaEnabled": true,
      "mfaMethods": [
        {
          "method": "TOTP",
          "enabled": true,
          "createdAt": "2025-06-19T10:30:00.000Z"
        }
      ]
    },
    "notifications": [
      {
        "method": "Email",
        "enabled": true
      }
    ]
  },
  "timestamp": "2025-06-19T10:30:00.000Z"
}
```

#### 7. Actualizar Perfil
**PUT** `/api/orm/auth/profile`

Actualiza información del perfil del usuario.

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Request Body:**
```json
{
  "firstname": "Juan Carlos",
  "lastname": "Pérez González",
  "email": "nuevo@example.com",
  "currentPassword": "MiPassword123!",
  "newPassword": "NuevoPassword456!",
  "notificationSettings": [
    {
      "methodId": 1,
      "enabled": true
    }
  ]
}
```

#### 8. Configurar MFA
**POST** `/api/orm/auth/profile`

Configura o gestiona la autenticación de múltiples factores.

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Configurar TOTP:**
```json
{
  "action": "setup-totp"
}
```

**Verificar TOTP:**
```json
{
  "action": "verify-totp",
  "mfaToken": "123456"
}
```

**Desactivar MFA:**
```json
{
  "action": "disable-mfa",
  "mfaToken": "123456"
}
```

## Códigos de Error

| Código | Descripción |
|--------|-------------|
| 400 | Datos inválidos o incompletos |
| 401 | No autenticado o token inválido |
| 403 | Sin permisos suficientes |
| 404 | Recurso no encontrado |
| 405 | Método HTTP no permitido |
| 409 | Conflicto (email/DNI ya existe) |
| 500 | Error interno del servidor |

## Ejemplos de Uso

### Flujo Completo de Registro y Login

```bash
# 1. Verificar disponibilidad de email
curl -X GET "http://localhost:3000/api/orm/auth/register?email=test@example.com"

# 2. Registrar usuario
curl -X POST http://localhost:3000/api/orm/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!",
    "firstname": "Test",
    "lastname": "User",
    "birthdate": "1990-01-01",
    "dni": "123456789012",
    "genderId": 1
  }'

# 3. Iniciar sesión
curl -X POST http://localhost:3000/api/orm/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!"
  }'

# 4. Obtener perfil (usar token del login)
curl -X GET http://localhost:3000/api/orm/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# 5. Configurar MFA
curl -X POST http://localhost:3000/api/orm/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "setup-totp"
  }'
```

## Integración con Endpoints Existentes

Los nuevos endpoints de autenticación están integrados con el sistema existente:

- **Middleware de autenticación**: Disponible en `./auth/middleware.js`
- **Compatibilidad**: Los endpoints existentes pueden usar el middleware para requerir autenticación
- **Base de datos**: Compatible con el esquema Prisma existente
- **Criptografía**: Integrado con el sistema de llaves existente

### Uso del Middleware

```javascript
const { authenticate, requireRole } = require('./api/orm/auth/middleware');

// Aplicar autenticación a un endpoint existente
app.use('/api/orm/votar', authenticate, votarHandler);

// Requerir rol específico
app.use('/api/admin/*', authenticate, requireRole(['Administrador']), adminHandler);
```

## Variables de Entorno

Asegúrese de configurar estas variables en su archivo `.env`:

```env
JWT_SECRET=tu-secreto-jwt-muy-seguro
JWT_REFRESH_SECRET=tu-secreto-refresh-muy-seguro
PRISMA_DATABASE_URL=tu-conexion-base-datos
```

## Notas de Seguridad

1. **Contraseñas**: Se hashean usando bcrypt con 12 rondas
2. **Tokens JWT**: Incluyen información mínima y tienen expiración
3. **MFA**: Implementado con TOTP (Google Authenticator compatible)
4. **Sesiones**: Se almacenan en base de datos para control granular
5. **Llaves criptográficas**: Se generan automáticamente en el registro
6. **Auditoría**: Todos los intentos de login se registran

## Próximos Pasos

1. Ejecutar la migración SQL para crear las nuevas tablas
2. Configurar variables de entorno
3. Iniciar el servidor con `npm run dev`
4. Probar los endpoints con los ejemplos proporcionados
5. Integrar autenticación en endpoints existentes según necesidad
