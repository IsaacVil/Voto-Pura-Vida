// Cargar variables de entorno
require('dotenv').config();

const sql = require('mssql');

/**
 * Configuración de base de datos para diferentes entornos
 */
const dbConfigs = {
  // Configuración para desarrollo local (Docker)
  development: {
    server: process.env.DB_SERVER || 'localhost',
    port: parseInt(process.env.DB_PORT) || 14333,
    database: process.env.DB_NAME || 'VotoPuraVida',
    // Usar autenticación Windows si está habilitada, sino SQL Server Auth
    ...(process.env.DB_USE_WINDOWS_AUTH === 'true' ? {
      options: {
        trustedConnection: true,
        encrypt: process.env.DB_ENCRYPT === 'true',
        trustServerCertificate: process.env.DB_TRUST_CERTIFICATE === 'true',
        enableArithAbort: true,
        connectTimeout: 30000,
        requestTimeout: 30000,
      }
    } : {
      user: process.env.DB_USER || 'sa',
      password: process.env.DB_PASSWORD,
      options: {
        encrypt: process.env.DB_ENCRYPT === 'true',
        trustServerCertificate: process.env.DB_TRUST_CERTIFICATE === 'true',
        enableArithAbort: true,
        connectTimeout: 30000,
        requestTimeout: 30000,
      }
    }),
    pool: {
      max: 10,
      min: 0,
      idleTimeoutMillis: 30000
    }
  },

  // Configuración para producción (Azure SQL)
  production: {
    server: process.env.AZURE_SQL_SERVER,
    database: process.env.AZURE_SQL_DATABASE,
    user: process.env.AZURE_SQL_USER,
    password: process.env.AZURE_SQL_PASSWORD,
    options: {
      encrypt: true,
      trustServerCertificate: false,
      enableArithAbort: true,
      connectTimeout: 30000,
      requestTimeout: 30000,
    },
    pool: {
      max: 20,
      min: 0,
      idleTimeoutMillis: 30000
    }
  },

  // Configuración para testing
  test: {
    server: process.env.TEST_DB_SERVER || 'localhost',
    port: parseInt(process.env.TEST_DB_PORT) || 14333,
    database: process.env.TEST_DB_NAME || 'voto_pura_vida_test',
    user: process.env.TEST_DB_USER || 'sa',
    password: process.env.TEST_DB_PASSWORD,
    options: {
      encrypt: false,
      trustServerCertificate: true,
      enableArithAbort: true,
    },
    pool: {
      max: 5,
      min: 0,
      idleTimeoutMillis: 10000
    }
  }
};

/**
 * Obtiene la configuración según el entorno actual
 */
function getDbConfig() {
  const env = process.env.NODE_ENV || 'development';
  const config = dbConfigs[env];
  
  if (!config) {
    throw new Error(`Configuración de base de datos no encontrada para el entorno: ${env}`);
  }

  // Validar que las variables críticas estén definidas
  if (!config.password) {
    throw new Error(`DB_PASSWORD no está definida para el entorno: ${env}`);
  }

  return config;
}

/**
 * Pool de conexiones global
 */
let poolPromise;

/**
 * Inicializa la conexión a la base de datos
 */
async function initializeDatabase() {  try {
    const config = getDbConfig();
    
    console.log(`Conectando a la base de datos en ${config.server}:${config.port || 14333}...`);
    
    poolPromise = new sql.ConnectionPool(config).connect();
    
    const pool = await poolPromise;
    
    console.log(`Conexión exitosa a la base de datos: ${config.database}`);
    console.log(`Entorno: ${process.env.NODE_ENV || 'development'}`);
    
    return pool;
  } catch (error) {
    console.error('Error conectando a la base de datos:', error.message);
    throw error;
  }
}

/**
 * Obtiene el pool de conexiones
 */
async function getPool() {
  if (!poolPromise) {
    await initializeDatabase();
  }
  return poolPromise;
}

/**
 * Ejecuta una consulta SQL
 */
async function executeQuery(query, params = {}) {
  try {
    const pool = await getPool();
    const request = pool.request();
    
    // Agregar parámetros si existen
    Object.keys(params).forEach(key => {
      request.input(key, params[key]);
    });
    
    const result = await request.query(query);
    return result;
  } catch (error) {
    console.error('Error ejecutando consulta:', error.message);
    throw error;
  }
}

/**
 * Ejecuta un stored procedure
 */
async function executeStoredProcedure(procedureName, params = {}) {
  try {
    const pool = await getPool();
    const request = pool.request();
    
    // Agregar parámetros de entrada
    Object.keys(params).forEach(key => {
      const param = params[key];
      if (param.type && param.value !== undefined) {
        request.input(key, param.type, param.value);
      } else {
        request.input(key, param);
      }
    });
    
    const result = await request.execute(procedureName);
    return result;
  } catch (error) {
    console.error(`Error ejecutando SP ${procedureName}:`, error.message);
    throw error;
  }
}

/**
 * Cierra la conexión a la base de datos
 */
async function closeDatabase() {
  try {
    if (poolPromise) {
      const pool = await poolPromise;
      await pool.close();
      poolPromise = null;
      console.log('Conexión a la base de datos cerrada');
    }
  } catch (error) {
    console.error('Error cerrando la base de datos:', error.message);
  }
}

module.exports = {
  getDbConfig,
  initializeDatabase,
  getPool,
  executeQuery,
  executeStoredProcedure,
  closeDatabase,
  sql 
};
