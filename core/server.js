/**
 * Servidor de desarrollo local - Simulación serverless
 * Compatible con Azure Functions y Vercel
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

// Configuración básica
const app = express();

// Middlewares esenciales
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Importar handlers serverless
const votarHandler = require('./api/orm/votar');
const comentarHandler = require('./api/orm/comentar');
const configurarVotacionHandler = require('./api/orm/configurarVotacion');
const listarVotosHandler = require('./api/orm/listarvotos');
const registerHandler = require('./api/orm/register');
const loginHandler = require('./api/orm/login');
const profileHandler = require('./api/orm/profile');
const verifyHandler = require('./api/orm/verify');

const invertirEnPropuestaHandler = require('./api/stored-procedures/invertirEnPropuesta');
const repartirDividendosHandler = require('./api/stored-procedures/repartirDividendos');
const crearActualizarPropuestaHandler = require('./api/stored-procedures/crearActualizarPropuesta');
const revisarPropuestaHandler = require('./api/stored-procedures/revisarPropuesta');

// Rutas ORM
app.use('/api/orm/votar', votarHandler);
app.use('/api/orm/comentar', comentarHandler);
app.use('/api/orm/configurarVotacion', configurarVotacionHandler);
app.use('/api/orm/listarvotos', listarVotosHandler);
app.use('/api/orm/register', registerHandler);
app.use('/api/orm/login', loginHandler);
app.use('/api/orm/profile', profileHandler);
app.use('/api/orm/verify', verifyHandler);

// Rutas Stored Procedures
app.use('/api/stored-procedures/invertirEnPropuesta', invertirEnPropuestaHandler);
app.use('/api/stored-procedures/repartirDividendos', repartirDividendosHandler);
app.use('/api/stored-procedures/crearActualizarPropuesta', crearActualizarPropuestaHandler);
app.use('/api/stored-procedures/revisarPropuesta', revisarPropuestaHandler);

// Manejador de errores serverless
app.use((error, req, res, next) => {
  console.error('Error:', error.message);
  res.status(error.status || 500).json({
    error: error.message || 'Error interno del servidor',
    timestamp: new Date().toISOString()
  });
});

// Catch-all para rutas no encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint no encontrado',
    path: req.originalUrl,
    method: req.method
  });
});

// Servidor de desarrollo
const PORT = process.env.PORT || 3000;

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀 Servidor local iniciado en http://localhost:${PORT}`);    console.log('📍 Endpoints disponibles:');    console.log('   • POST /api/orm/register');
    console.log('   • POST /api/orm/login');
    console.log('   • GET  /api/orm/profile (🔒 Auth required)');
    console.log('   • POST /api/orm/verify/send-code');
    console.log('   • POST /api/orm/verify/verify-code');
    console.log('   • POST /api/orm/votar');
    console.log('   • POST /api/orm/comentar');
    console.log('   • POST /api/orm/configurarVotacion');
    console.log('   • GET  /api/orm/listarvotos');
    console.log('   • POST /api/stored-procedures/invertirEnPropuesta');
    console.log('   • POST /api/stored-procedures/repartirDividendos');
    console.log('   • POST /api/stored-procedures/crearActualizarPropuesta');
    console.log('   • POST /api/stored-procedures/revisarPropuesta');
  });
}

module.exports = app;
