require('dotenv').config();
const { getPool } = require('./src/config/database');
const fs = require('fs');

async function updateStoredProcedure() {
  try {
    const pool = await getPool();
    
    console.log('📝 Leyendo el stored procedure actualizado...');
    const sqlScript = fs.readFileSync('../scripts/V5__CrearActualizarPropuestaSP.sql', 'utf8');
    
    console.log('🔄 Ejecutando actualización del stored procedure...');
    await pool.request().query(sqlScript);
    
    console.log('✅ Stored procedure actualizado exitosamente');
    console.log('✅ Ahora valida permisos (permissionid=11) en lugar de roles');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error actualizando stored procedure:', error.message);
    process.exit(1);
  }
}

updateStoredProcedure();
