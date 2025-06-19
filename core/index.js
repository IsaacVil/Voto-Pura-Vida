
if (process.env.NODE_ENV === 'development') {
  require('./server.js');
} else {
  console.log('Aplicación configurada para funciones serverless');
}

module.exports = {
  config: require('./src/config/app').config
};
