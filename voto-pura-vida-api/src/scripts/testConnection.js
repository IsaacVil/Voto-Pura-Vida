/**
 * Script para probar la conexión a la base de datos
 */

// Cargar variables de entorno antes que nada
require('dotenv').config();

const { initializeDatabase, executeQuery, closeDatabase } = require('../config/database');
const { showConfig } = require('../config/app');

async function testConnection() {  console.log('Probando conexión a la base de datos...\n');
  
  // Mostrar configuración actual
  showConfig();
  console.log('');

  try {
    // Intentar conectar
    await initializeDatabase();
      // Probar una consulta simple
    console.log('Ejecutando consulta de prueba...');
    const result = await executeQuery('SELECT @@VERSION as version, GETDATE() as fecha_actual');
    
    console.log('Consulta exitosa:');
    console.log(' • Versión SQL Server:', result.recordset[0].version.split('\n')[0]);
    console.log(' • Fecha/Hora actual:', result.recordset[0].fecha_actual);
    
    // Probar listado de tablas
    console.log('\nVerificando estructura de la base de datos...');
    const tablesResult = await executeQuery(`
      SELECT 
        TABLE_SCHEMA as schema_name,
        TABLE_NAME as table_name,
        TABLE_TYPE as table_type
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_TYPE = 'BASE TABLE'
      ORDER BY TABLE_SCHEMA, TABLE_NAME
    `);
    
    if (tablesResult.recordset.length > 0) {
      console.log('Tablas encontradas:');
      tablesResult.recordset.forEach(table => {
        console.log(`   • ${table.schema_name}.${table.table_name}`);
      });
    } else {
      console.log('No se encontraron tablas en la base de datos');
    }

    // Probar stored procedures
    console.log('\n Verificando stored procedures...');
    const spResult = await executeQuery(`
      SELECT 
        ROUTINE_SCHEMA as schema_name,
        ROUTINE_NAME as procedure_name,
        CREATED as created_date
      FROM INFORMATION_SCHEMA.ROUTINES 
      WHERE ROUTINE_TYPE = 'PROCEDURE'
      ORDER BY ROUTINE_SCHEMA, ROUTINE_NAME
    `);

    if (spResult.recordset.length > 0) {
      console.log('Stored Procedures encontrados:');
      spResult.recordset.forEach(sp => {
        console.log(`   • ${sp.schema_name}.${sp.procedure_name}`);
      });
    } else {
      console.log('No se encontraron stored procedures');
    }
    
    console.log('\n ¡Conexión exitosa! La base de datos está lista para usar.');
    
  } catch (error) {
    console.error('\n Error en la conexión:');
    console.error('   • Mensaje:', error.message);
    
    if (error.code) {
      console.error('   • Código:', error.code);
    }
    
    console.error('\n Posibles soluciones:');
    console.error('   1. Verificar que Docker esté ejecutándose');
    console.error('   2. Comprobar que el contenedor SQL Server esté activo');
    console.error('   3. Validar las credenciales en el archivo .env');
    console.error('   4. Asegurar que el puerto 1433 esté disponible');
    
    process.exit(1);
  } finally {
    await closeDatabase();
  }
}

// Ejecutar si se llama directamente
if (require.main === module) {
  testConnection();
}

module.exports = { testConnection };
