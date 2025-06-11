/**
 * Configuración general de la aplicación
 */

// Cargar variables de entorno
require('dotenv').config();

const config = {
  // Configuración del servidor
  server: {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development',
    isProduction: process.env.NODE_ENV === 'production',
    isDevelopment: process.env.NODE_ENV === 'development',
    isTest: process.env.NODE_ENV === 'test'
  },

  // Configuración de JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'default-secret-change-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '24h'
  },

  // Configuración de encriptación
  encryption: {
    key: process.env.ENCRYPTION_KEY || 'default-32-character-key-change!!!'
  },

  // Configuración de archivos
  files: {
    maxSize: parseInt(process.env.MAX_FILE_SIZE) || 10485760, // 10MB
    allowedTypes: process.env.ALLOWED_FILE_TYPES?.split(',') || ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
    uploadDir: './uploads'
  },

  // Configuración de CORS
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000', 'http://localhost:3001'],
    credentials: true
  },

  // Configuración de IA
  ai: {
    openaiApiKey: process.env.OPENAI_API_KEY,
    enabled: process.env.AI_VALIDATION_ENABLED === 'true' || false
  },

  // Configuración de logs
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    format: process.env.NODE_ENV === 'production' ? 'json' : 'dev'
  },

  // Configuración de rate limiting
  rateLimit: {
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: process.env.NODE_ENV === 'production' ? 100 : 1000 // 100 requests en prod, 1000 en dev
  },

  // Configuración de validación
  validation: {
    strictMode: process.env.NODE_ENV === 'production',
    allowUnknown: process.env.NODE_ENV !== 'production'
  },

  // URLs y endpoints
  urls: {
    frontend: process.env.FRONTEND_URL || 'http://localhost:3000',
    api: process.env.API_URL || 'http://localhost:3000/api'
  }
};

/**
 * Valida que todas las configuraciones críticas estén presentes
 */
function validateConfig() {
  const required = [
    'JWT_SECRET',
    'ENCRYPTION_KEY'
  ];

  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0 && config.server.isProduction) {
    throw new Error(`Variables de entorno faltantes en producción: ${missing.join(', ')}`);
  }

  if (missing.length > 0) {
    console.warn(`⚠️  Variables de entorno faltantes (usando valores por defecto): ${missing.join(', ')}`);
  }
}

/**
 * Muestra la configuración actual (sin datos sensibles)
 */
function showConfig() {
  console.log('Configuración de la aplicación:');
  console.log(`   • Entorno: ${config.server.env}`);
  console.log(`   • Puerto: ${config.server.port}`);
  console.log(`   • CORS: ${config.cors.origin.join(', ')}`);
  console.log(`   • Archivos max: ${(config.files.maxSize / 1024 / 1024).toFixed(1)}MB`);
  console.log(`   • IA habilitada: ${config.ai.enabled ? '✅' : '❌'}`);
  console.log(`   • Rate limit: ${config.rateLimit.max} req/15min`);
}

// Validar configuración al cargar
validateConfig();

module.exports = {
  config,
  validateConfig,
  showConfig
};
