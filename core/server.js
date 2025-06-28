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
const verifyHandler = require('./api/orm/verify');

const invertirEnPropuestaHandler = require('./api/stored-procedures/invertirEnPropuesta');
const repartirDividendosHandler = require('./api/orm/repartirDividendos');
const crearActualizarPropuestaHandler = require('./api/stored-procedures/crearActualizarPropuesta');
const revisarPropuestaHandler = require('./api/stored-procedures/revisarPropuesta');
const crearReporteFinancieroHandler = require('./api/stored-procedures/crearReporteFinanciero');
// Endpoint utilitario para crear reportes financieros de prueba (sin autenticación, solo desarrollo)
app.use('/api/crearReporteFinanciero', crearReporteFinancieroHandler);

// Importar middleware de autenticación
const { authenticateToken } = require('./api/auth/middleware');

// Rutas ORM - Públicas (sin autenticación)
app.use('/api/register', registerHandler);
app.use('/api/login', loginHandler);
app.use('/api/send-verification-code', (req, res) => verifyHandler.sendCode(req, res));
app.use('/api/verify-code', (req, res) => verifyHandler.verifyCode(req, res));

// Rutas ORM - Protegidas (requieren autenticación JWT)
app.use('/api/votar', authenticateToken, votarHandler);
app.use('/api/comentar', authenticateToken, comentarHandler);
app.use('/api/configurarVotacion', authenticateToken, configurarVotacionHandler);
app.use('/api/listarvotos', authenticateToken, listarVotosHandler);
// Endpoint para enviar MFA de voto (GET, requiere JWT)
app.use('/api/send-vote-mfa', require('./api/orm/send-vote-mfa'));
// Endpoint para asignar segmentos a un usuario (POST, requiere JWT)
app.use('/api/asignar-segmentos', authenticateToken, require('./api/orm/asignar-segmentos'));

// Rutas Stored Procedures - Protegidas (requieren autenticación JWT)
app.use('/api/invertirEnPropuesta', authenticateToken, invertirEnPropuestaHandler);
app.use('/api/repartirDividendos', authenticateToken, repartirDividendosHandler);
app.use('/api/crearActualizarPropuesta', authenticateToken, crearActualizarPropuestaHandler);
app.use('/api/revisarPropuesta', authenticateToken, revisarPropuestaHandler);

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
    console.log(`🚀 Servidor local iniciado en http://localhost:${PORT}`);    console.log('📍 Endpoints disponibles:');
    console.log('🔓 PÚBLICOS:');
    console.log('   • POST /api/register');
    console.log('   • POST /api/login');
    console.log('   • POST /api/send-verification-code');
    console.log('   • POST /api/verify-code');
    console.log('🔒 PROTEGIDOS (requieren Bearer token):');
    console.log('   • POST /api/votar');
    console.log('   • POST /api/comentar');
    console.log('   • POST /api/configurarVotacion');
    console.log('   • GET  /api/listarvotos');
    console.log('   • POST /api/invertirEnPropuesta');
    console.log('   • POST /api/repartirDividendos');
    console.log('   • POST /api/crearActualizarPropuesta');
    console.log('   • POST /api/revisarPropuesta');
  });
}

module.exports = app;
