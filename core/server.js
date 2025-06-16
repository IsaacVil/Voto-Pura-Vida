/**
 * Servidor de desarrollo local para la API de Voto Pura Vida
 * Este archivo simula el comportamiento de Vercel para desarrollo local
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const path = require('path');

// Importar configuración
const { config, showConfig } = require('./src/config/app');

// Crear aplicación Express
const app = express();

// Middlewares de seguridad
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));

// CORS
app.use(cors(config.cors));

// Compresión
app.use(compression());

// Logging
app.use(morgan(config.logging.format));

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.max,
  message: {
    error: 'Demasiadas solicitudes desde esta IP',
    retryAfter: Math.ceil(config.rateLimit.windowMs / 1000)
  }
});
app.use(limiter);

// Parser de JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Servir archivos estáticos de testing
app.use('/testing', express.static(path.join(__dirname, 'testing')));

// Ruta principal para redireccionar al testing
app.get('/', (req, res) => {
  res.redirect('/testing/index.html');
});

// Ruta de salud
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: config.server.env,
    version: require('./package.json').version
  });
});

// Simular las rutas de Vercel para desarrollo local
// Importar rutas específicas del ORM
const votarHandler = require('./api/orm/votar');

// Importar rutas específicas de Stored Procedures
const invertirEnPropuestaHandler = require('./api/stored-procedures/invertirEnPropuesta');
const repartirDividendosHandler = require('./api/stored-procedures/repartirDividendos');

const crearActualizarPropuestaHandler = require('./api/stored-procedures/crearActualizarPropuesta'); 
const revisarPropuestaHandler = require('./api/stored-procedures/revisarPropuesta'); 


// Ruta específica para el ORM de votación
app.use('/api/orm/votar', votarHandler);

// Rutas específicas para Stored Procedures
app.use('/api/stored-procedures/invertirEnPropuesta', invertirEnPropuestaHandler);
app.use('/api/stored-procedures/repartirDividendos', repartirDividendosHandler);
app.use('/api/stored-procedures/crearActualizarPropuesta', crearActualizarPropuestaHandler); 
app.use('/api/stored-procedures/revisarPropuesta', revisarPropuestaHandler); 

// Ruta de health check para ORM
app.get('/api/orm/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'ORM Voting API',
    timestamp: new Date().toISOString(),
    database: 'connected'
  });
});

// Ruta de health check para Stored Procedures
app.get('/api/stored-procedures/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Stored Procedures API',
    timestamp: new Date().toISOString(),
    endpoints: [
      'POST /api/stored-procedures/invertirEnPropuesta',
      'GET /api/stored-procedures/invertirEnPropuesta',
      'POST /api/stored-procedures/repartirDividendos',
      'GET /api/stored-procedures/repartirDividendos',
      'POST /api/stored-procedures/crearActualizarPropuesta',
      'PUT /api/stored-procedures/crearActualizarPropuesta',  

      'GET /api/stored-procedures/crearActualizarPropuesta',
      'POST /api/stored-procedures/revisarPropuesta',         
      'GET /api/stored-procedures/revisarPropuesta'           
   
    ]
  });
});

// Manejador genérico para otras rutas
app.use('/api', (req, res, next) => {
  // Intentar cargar el archivo de función correspondiente
  const functionPath = req.path.replace('/api/', '');
  const possiblePaths = [
    path.join(__dirname, 'api', functionPath + '.js'),
    path.join(__dirname, 'api', functionPath + '.ts'),
    path.join(__dirname, 'api', functionPath, 'index.js'),
    path.join(__dirname, 'api', functionPath, 'index.ts')
  ];

  let handler = null;
  for (const filePath of possiblePaths) {
    try {
      if (require('fs').existsSync(filePath)) {
        // Limpiar caché para desarrollo
        delete require.cache[require.resolve(filePath)];
        handler = require(filePath);
        break;
      }
    } catch (error) {
      console.warn(`Error cargando ${filePath}:`, error.message);
    }
  }

  if (handler && typeof handler === 'function') {
    handler(req, res);
  } else if (handler && handler.default && typeof handler.default === 'function') {
    handler.default(req, res);
  } else {
    res.status(404).json({
      error: 'Endpoint no encontrado',
      path: req.path,
      method: req.method
    });
  }
});

// Middleware de manejo de errores
app.use((error, req, res, next) => {
  console.error('Error no manejado:', error);
  
  res.status(error.status || 500).json({
    error: config.server.isDevelopment ? error.message : 'Error interno del servidor',
    stack: config.server.isDevelopment ? error.stack : undefined,
    timestamp: new Date().toISOString()
  });
});

// Ruta catch-all
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    path: req.originalUrl,
    method: req.method,
    available: [
      'GET /',
      'GET /testing/',
      'GET /api/health',
      'GET /api/orm/health',
      'POST /api/orm/votar',
      'GET /api/stored-procedures/health',
      'POST /api/stored-procedures/invertirEnPropuesta',
      'GET /api/stored-procedures/invertirEnPropuesta',
      'POST /api/stored-procedures/repartirDividendos',
      'GET /api/stored-procedures/repartirDividendos',

      'POST /api/stored-procedures/crearActualizarPropuesta',
      'PUT /api/stored-procedures/crearActualizarPropuesta',
      'GET /api/stored-procedures/crearActualizarPropuesta',
      'POST /api/stored-procedures/revisarPropuesta',
      'GET /api/stored-procedures/revisarPropuesta'
   
    ]
  });
});

// Iniciar servidor
const PORT = config.server.port;

app.listen(PORT, () => {
  console.log('\n🚀 Servidor de desarrollo iniciado');
  console.log(`📍 URL Principal: http://localhost:${PORT}`);
  console.log(`🧪 Testing UI: http://localhost:${PORT}/testing/`);
  console.log(`📍 API Health: http://localhost:${PORT}/api/health`);
  console.log('');
  console.log('📋 Endpoints ORM:');
  console.log(`   🗳️ ORM Health: http://localhost:${PORT}/api/orm/health`);
  console.log(`   🗳️ Votación: POST http://localhost:${PORT}/api/orm/votar`);
  console.log('');
  console.log('⚙️ Endpoints Stored Procedures:');
  console.log(`   🏥 SP Health: http://localhost:${PORT}/api/stored-procedures/health`);
  console.log(`   💰 Inversión: POST http://localhost:${PORT}/api/stored-procedures/invertirEnPropuesta`);
  console.log(`   📊 Info Inversión: GET http://localhost:${PORT}/api/stored-procedures/invertirEnPropuesta`);
  console.log(`   💎 Dividendos: POST http://localhost:${PORT}/api/stored-procedures/repartirDividendos`);
  console.log(`   📈 Info Dividendos: GET http://localhost:${PORT}/api/stored-procedures/repartirDividendos`);
  
  
console.log('⚙️ Endpoints Stored Procedures:');
console.log(`   🏥 SP Health: http://localhost:${PORT}/api/stored-procedures/health`);
console.log(`   💰 Inversión: POST http://localhost:${PORT}/api/stored-procedures/invertirEnPropuesta`);
console.log(`   📊 Info Inversión: GET http://localhost:${PORT}/api/stored-procedures/invertirEnPropuesta`);
console.log(`   💎 Dividendos: POST http://localhost:${PORT}/api/stored-procedures/repartirDividendos`);
console.log(`   📈 Info Dividendos: GET http://localhost:${PORT}/api/stored-procedures/repartirDividendos`);

console.log(`   📝 Crear Propuesta: POST http://localhost:${PORT}/api/stored-procedures/crearActualizarPropuesta`);     
console.log(`   ✏️ Actualizar Propuesta: PUT http://localhost:${PORT}/api/stored-procedures/crearActualizarPropuesta`); 
console.log(`   📋 Info Propuesta: GET http://localhost:${PORT}/api/stored-procedures/crearActualizarPropuesta`);       
console.log(`   🔍 Revisar Propuesta: POST http://localhost:${PORT}/api/stored-procedures/revisarPropuesta`);    
console.log(`   📄 Info Revisión: GET http://localhost:${PORT}/api/stored-procedures/revisarPropuesta`);        


  console.log('');
  showConfig();
  console.log('\n✅ Listo para recibir solicitudes');
  console.log('💡 Abre http://localhost:3001 en tu navegador para testing\n');
});

// Manejo de señales
process.on('SIGTERM', () => {
  console.log('\n🛑 Cerrando servidor...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('\n🛑 Cerrando servidor...');
  process.exit(0);
});

module.exports = app;
