/**
 * Configuración básica de la aplicación
 */

require('dotenv').config();

const config = {
  // Configuración del servidor
  server: {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development',
    isProduction: process.env.NODE_ENV === 'production',
    isDevelopment: process.env.NODE_ENV === 'development'
  }
};

const express = require('express');
const app = express();

app.use(express.json());

// Endpoints básicos para ORM
app.post('/api/orm/comentar', (req, res) => {
  // Lógica para comentar
  res.json({ message: 'Comentario recibido', body: req.body });
});

app.post('/api/orm', (req, res) => {
  // Lógica para crear
  res.json({ message: 'Creado', body: req.body });
});

app.get('/api/orm', (req, res) => {
  // Lógica para leer
  res.json({ message: 'Listado de elementos' });
});

app.put('/api/orm/:id', (req, res) => {
  // Lógica para actualizar
  res.json({ message: `Actualizado el elemento ${req.params.id}`, body: req.body });
});

app.delete('/api/orm/:id', (req, res) => {
  // Lógica para eliminar
  res.json({ message: `Eliminado el elemento ${req.params.id}` });
});

// ...existing code...
const { config } = require('./src/config/app');
app.listen(config.server.port, () => {
  console.log(`Servidor escuchando en el puerto ${config.server.port}`);
});

module.exports = {
  config
};