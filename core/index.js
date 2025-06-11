/**
 * Punto de entrada principal para la aplicación Voto Pura Vida
 * Este archivo se usa cuando se ejecuta la aplicación en producción
 */

// Para Vercel, exportamos las funciones individuales
// En desarrollo local, usamos server.js

if (process.env.NODE_ENV === 'development') {
  // En desarrollo, ejecutar el servidor local
  require('./server.js');
} else {
  // En producción (Vercel), no necesitamos un servidor persistente
  // Las funciones serverless se manejan individualmente
  console.log('Aplicación configurada para funciones serverless');
}

module.exports = {
  // Exportar configuración para uso externo
  config: require('./src/config/app').config
};
