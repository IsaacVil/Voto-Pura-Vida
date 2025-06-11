# Voto Pura Vida - API Core

Sistema de votación electrónica y crowdfunding con validaciones de seguridad avanzadas.

## Configuración Rápida

### 1. Instalar dependencias
```bash
npm install
```

### 2. Configurar base de datos
```bash
# Copiar configuración de ejemplo
cp .env.example .env

# Probar conexión a la base de datos
npm run db:test
```

### 3. Iniciar servidor de desarrollo
```bash
npm run dev
```

El servidor estará disponible en: `http://localhost:3000`

## Endpoints Disponibles

### 🗳️ Sistema de Votación

#### POST /api/orm/votar
Permite a un ciudadano emitir un voto sobre una propuesta activa.

**URL:** `POST /api/orm/votar`

**Parámetros requeridos:**
```json
{
  "userid": 1,                           // ID del usuario (number)
  "proposalid": 1,                       // ID de la propuesta (number)
  "voteDecision": "yes",                 // Decisión: "yes", "no", "abstain"
  "mfaToken": "token_123",               // Token de autenticación multifactor
  "mfaCode": "123456",                   // Código MFA de 6 dígitos
  "biometricData": "sample_data",        // Datos biométricos para verificación
  "clientIP": "192.168.1.100",          // IP del cliente (opcional)
  "userAgent": "Browser/1.0"            // User Agent (opcional)
}
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "message": "Voto registrado exitosamente",
  "data": {
    "voteId": 1001,
    "proposalId": 1,
    "userId": 1,
    "decision": "yes",
    "timestamp": "2025-06-11T06:00:00.000Z",
    "hash": "a1b2c3d4e5f6...",
    "encrypted": true
  },
  "timestamp": "2025-06-11T06:00:00.000Z"
}
```

**Errores comunes:**
- `400` - Campos requeridos faltantes
- `401` - MFA inválido o expirado
- `404` - Usuario o propuesta no encontrada
- `409` - Usuario ya ha votado en esta propuesta
- `403` - Usuario no tiene permisos para votar

**Validaciones implementadas:**
- ✅ Verificación de credenciales de usuario
- ✅ Autenticación multifactor (MFA)
- ✅ Comprobación biométrica de vida
- ✅ Estado activo del ciudadano
- ✅ Permisos de votación en la propuesta
- ✅ Propuesta dentro de fechas válidas
- ✅ Prevención de doble votación
- ✅ Cifrado del voto
- ✅ Trazabilidad completa

### 🏥 Health Checks

#### GET /api/health
Estado general del sistema.

**Respuesta:**
```json
{
  "status": "ok",
  "timestamp": "2025-06-11T06:00:00.000Z",
  "environment": "development",
  "version": "1.0.0"
}
```

#### GET /api/orm/health
Estado específico del módulo ORM de votación.

**Respuesta:**
```json
{
  "status": "ok",
  "service": "ORM Voting API",
  "timestamp": "2025-06-11T06:00:00.000Z",
  "database": "connected"
}
```

## Scripts de Desarrollo

| Comando | Descripción |
|---------|-------------|
| `npm run dev` | Inicia servidor de desarrollo con recarga automática |
| `npm run start` | Inicia servidor de producción |
| `npm run dev:vercel` | Simula el entorno Vercel localmente |
| `npm run db:test` | Prueba la conexión a la base de datos |
| `npm test` | Ejecuta tests con Jest |
| `npm run test:watch` | Ejecuta tests en modo watch |

## Scripts de Testing

| Comando | Descripción |
|---------|-------------|
| `npm run test:votar-orm` | Pruebas básicas del endpoint de votación |
| `npm run test:real-orm` | Suite completa de testing real |
| `npm run test:all` | Ejecuta todos los tests disponibles |

## Interfaz de Testing

Para probar los endpoints de forma interactiva:

1. Inicia el servidor: `npm run dev`
2. Abre el navegador en: `http://localhost:3000`
3. Usa la interfaz web para probar los endpoints

**Funcionalidades de la interfaz:**
- ✅ Test de conexión
- ✅ Formulario de votación
- ✅ Tests automatizados
- ✅ Pruebas de validación
- ✅ Visualización de resultados en tiempo real

## Prisma ORM

### Comandos útiles:
```bash
# Generar cliente Prisma
npm run prisma:generate

# Sincronizar esquema desde BD
npm run prisma:db:pull

# Abrir Prisma Studio
npm run prisma:studio
```

## Estructura del Proyecto

```
core/
├── api/
│   └── orm/
│       └── votar.js              # Endpoint de votación
├── src/
│   ├── config/
│   │   ├── app.js               # Configuración general
│   │   ├── database.js          # Configuración de BD
│   │   └── prisma.js            # Cliente Prisma
│   ├── scripts/
│   │   ├── testConnection.js    # Test de conexión BD
│   │   ├── test-votar-orm.js    # Tests básicos
│   │   └── test-real-orm.js     # Suite completa de tests
│   └── utils/                   # Utilidades
├── testing/
│   └── index.html               # Interfaz web de testing
├── prisma/
│   └── schema.prisma            # Esquema de base de datos
├── server.js                    # Servidor Express de desarrollo
├── index.js                     # Entrada para Vercel
└── package.json                 # Dependencias y scripts
```

## Variables de Entorno

Crear archivo `.env` en la raíz con:

```env
# Base de datos
DATABASE_URL="sqlserver://localhost:1433;database=VotoPuraVida;username=sa;password=tu_password"

# Seguridad
JWT_SECRET="tu_jwt_secret_aqui"
ENCRYPTION_KEY="tu_clave_de_32_caracteres_aqui"

# Servidor
PORT=3000
NODE_ENV=development
```

## Seguridad

### Variables críticas:
- `JWT_SECRET` - Clave para tokens de autenticación
- `ENCRYPTION_KEY` - Clave para cifrado de votos
- `DATABASE_URL` - Conexión a base de datos

### Recomendaciones:
- Usa contraseñas fuertes en producción
- Rota las claves periódicamente
- Nunca subas archivos `.env` al repositorio
- Habilita HTTPS en producción

## Deploy

### Vercel
```bash
# Configurar variables de entorno
vercel env add DATABASE_URL
vercel env add JWT_SECRET
vercel env add ENCRYPTION_KEY

# Deploy
npm run deploy
```

## Troubleshooting

### Error de conexión a BD
```bash
# Verificar que Docker esté corriendo
docker ps

# Probar conexión
npm run db:test
```

### Puerto ocupado
Si el puerto 3000 está ocupado, el sistema usará automáticamente el puerto disponible más cercano.

### Tests fallan
```bash
# Verificar que el servidor esté corriendo
npm run dev

# Ejecutar tests individuales
npm run test:votar-orm
```

## Soporte

- **Ejemplos de uso:** Ver `EJEMPLOS.md` para casos prácticos
- Para problemas de base de datos: Ver `../documentation/README_FLYWAY_DOCKER.md`
- Para configuración general: Ver `../README.md` en la raíz del proyecto
