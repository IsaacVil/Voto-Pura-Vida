/**
 * Configuración de Prisma Client
 * Para operaciones ORM avanzadas
 */

const { PrismaClient } = require('./generated/prisma');

// Crear instancia de Prisma
const prisma = new PrismaClient({
  log: [
    {
      emit: 'event',
      level: 'query',
    },
    {
      emit: 'stdout',
      level: 'error',
    },
    {
      emit: 'stdout',
      level: 'info',
    },
    {
      emit: 'stdout',
      level: 'warn',
    },
  ],
  errorFormat: 'pretty',
});

// Configurar logging de queries en desarrollo
if (process.env.NODE_ENV === 'development') {
  prisma.$on('query', (e) => {
    console.log('\n🔍 Prisma Query:');
    console.log('Query:', e.query);
    console.log('Params:', e.params);
    console.log('Duration:', e.duration + 'ms');
    console.log('---');
  });
}

// Manejo de errores global
prisma.$on('beforeExit', async () => {
  console.log('🔌 Cerrando conexión Prisma...');
});

// Función helper para manejo de errores Prisma
const handlePrismaError = (error) => {
  console.error('Error Prisma:', error);
  
  if (error.code === 'P2002') {
    return {
      error: 'Violación de restricción única',
      field: error.meta?.target,
      code: 'DUPLICATE_ERROR'
    };
  }
  
  if (error.code === 'P2025') {
    return {
      error: 'Registro no encontrado',
      code: 'NOT_FOUND'
    };
  }
  
  if (error.code === 'P2003') {
    return {
      error: 'Violación de llave foránea',
      field: error.meta?.field_name,
      code: 'FOREIGN_KEY_ERROR'
    };
  }
  
  return {
    error: 'Error de base de datos',
    message: error.message,
    code: error.code || 'DATABASE_ERROR'
  };
};

// Función para ejecutar transacciones
const executeTransaction = async (operations) => {
  try {
    return await prisma.$transaction(operations);
  } catch (error) {
    throw handlePrismaError(error);
  }
};

// Función para raw queries (incluyendo SP)
const executeRawQuery = async (query, params = []) => {
  try {
    return await prisma.$queryRaw`${query}`;
  } catch (error) {
    throw handlePrismaError(error);
  }
};

// Función para SP usando Prisma
const executeStoredProcedureWithPrisma = async (procedureName, params = {}) => {
  try {
    const paramString = Object.keys(params)
      .map(key => `@${key} = ${typeof params[key] === 'string' ? `'${params[key]}'` : params[key]}`)
      .join(', ');
    
    const query = `EXEC ${procedureName} ${paramString}`;
    return await prisma.$queryRawUnsafe(query);
  } catch (error) {
    throw handlePrismaError(error);
  }
};

module.exports = {
  prisma,
  handlePrismaError,
  executeTransaction,
  executeRawQuery,
  executeStoredProcedureWithPrisma
};
