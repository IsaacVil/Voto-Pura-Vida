/**
 * Script de pruebas para los endpoints de Stored Procedures
 * Prueba los endpoints de inversión y reparto de dividendos
 */

const axios = require('axios');

// Configuración base
const BASE_URL = 'http://localhost:3000/api/stored-procedures';

async function testStoredProceduresEndpoints() {
  console.log('🧪 Iniciando pruebas de endpoints Stored Procedures');
  console.log('=' .repeat(80));

  try {
    // ===== TEST 1: INVERSIÓN EN PROPUESTA =====
    console.log('\n📈 TEST 1: Inversión en Propuesta (PV_InvertirEnPropuesta)');
    console.log('-'.repeat(60));

    // Test 1a: Obtener información de inversiones existentes
    console.log('\n1a. Obteniendo información de inversiones para propuesta 1...');
    try {
      const infoResponse = await axios.get(`${BASE_URL}/invertirEnPropuesta?proposalid=1`);
      console.log('   ✅ Información obtenida exitosamente');
      console.log(`   📊 Total inversiones: ${infoResponse.data.data.investments.length}`);
      console.log(`   💰 Propuesta budget: $${infoResponse.data.data.proposal?.budget || 'N/A'}`);
      console.log(`   💵 Total invertido: $${infoResponse.data.data.proposal?.totalInvested || 0}`);
      console.log(`   🎯 Disponible para inversión: $${infoResponse.data.data.summary.availableForInvestment}`);
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
    }

    // Test 1b: Realizar nueva inversión
    console.log('\n1b. Realizando nueva inversión...');
    const inversionData = {
      proposalid: 1,
      userid: 2, // Usuario diferente para evitar conflictos
      amount: 5000.00,
      investmentdate: new Date().toISOString(),
      paymentmethodid: 1,
      availablemethodid: 1,
      currencyid: 1,
      exchangerateid: 1
    };

    try {
      const inversionResponse = await axios.post(`${BASE_URL}/invertirEnPropuesta`, inversionData);
      console.log('   ✅ Inversión procesada exitosamente');
      console.log(`   💰 Monto invertido: $${inversionResponse.data.data.amount}`);
      console.log(`   🏦 Adelanto inicial: $${inversionResponse.data.data.details.adelantoInicial}`);
      console.log(`   📊 Tramos creados: ${inversionResponse.data.data.details.tramosCreados}`);
      console.log(`   🗳️ Votaciones fiscalización: ${inversionResponse.data.data.details.votacionesFiscalizacion}`);
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
      if (error.response?.data?.details) {
        console.log(`   📝 Detalles: ${error.response.data.details}`);
      }
    }

    // Test 1c: Validación de campos requeridos
    console.log('\n1c. Probando validación de campos requeridos...');
    const inversionIncompleta = {
      proposalid: 1,
      userid: 2,
      // Faltan campos requeridos
    };

    try {
      await axios.post(`${BASE_URL}/invertirEnPropuesta`, inversionIncompleta);
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   ✅ Validación correcta de campos requeridos');
        console.log(`   📝 Errores: ${error.response.data.details?.join(', ')}`);
      }
    }

    // Test 1d: Inversión con monto inválido
    console.log('\n1d. Probando inversión con monto inválido...');
    const inversionInvalida = {
      ...inversionData,
      amount: -1000 // Monto negativo
    };

    try {
      await axios.post(`${BASE_URL}/invertirEnPropuesta`, inversionInvalida);
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   ✅ Validación correcta de monto inválido');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }

    // ===== TEST 2: REPARTO DE DIVIDENDOS =====
    console.log('\n\n💰 TEST 2: Reparto de Dividendos (sp_PV_RepartirDividendos)');
    console.log('-'.repeat(60));

    // Test 2a: Obtener información de dividendos disponibles
    console.log('\n2a. Obteniendo información de dividendos para propuesta 1...');
    try {
      const dividendosResponse = await axios.get(`${BASE_URL}/repartirDividendos?proposalid=1`);
      console.log('   ✅ Información de dividendos obtenida exitosamente');
      console.log(`   💵 Total dividendos disponibles: $${dividendosResponse.data.data.proposal.totalDividendosDisponibles}`);
      console.log(`   👥 Total inversionistas: ${dividendosResponse.data.data.resumen.totalInversionistas}`);
      console.log(`   📊 Equity total asignado: ${dividendosResponse.data.data.resumen.totalEquityAllocated}%`);
      console.log(`   ⚠️ Inversores sin medio pago: ${dividendosResponse.data.data.resumen.inversoresSinMedioPago}`);
      console.log(`   ✅ Disponible para reparto: ${dividendosResponse.data.data.resumen.disponibleParaReparto ? 'Sí' : 'No'}`);
      
      if (dividendosResponse.data.data.inversionistas.length > 0) {
        console.log('\n   📋 Inversionistas registrados:');
        dividendosResponse.data.data.inversionistas.forEach(inv => {
          console.log(`      - ${inv.investorName}: ${inv.equitypercentage}% ($${inv.potentialDividend} potencial)`);
        });
      }
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
    }

    // Test 2b: Procesar reparto de dividendos (solo si hay datos disponibles)
    console.log('\n2b. Procesando reparto de dividendos...');
    const repartoData = {
      proposalid: 1,
      processedby: 1, // Usuario administrador
      paymentmethodid: 1,
      availablemethodid: 1,
      currencyid: 1,
      exchangerateid: 1
    };

    try {
      const repartoResponse = await axios.post(`${BASE_URL}/repartirDividendos`, repartoData);
      console.log('   ✅ Reparto de dividendos procesado exitosamente');
      console.log(`   👥 Pagos realizados: ${repartoResponse.data.data.details.pagosRealizados}`);
      console.log(`   💰 Total repartido: $${repartoResponse.data.data.details.totalRepartido}`);
      console.log(`   📅 Procesado en: ${new Date(repartoResponse.data.data.processedAt).toLocaleString()}`);
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
      if (error.response?.data?.details) {
        console.log(`   📝 Detalles: ${error.response.data.details}`);
      }
    }

    // Test 2c: Validación de campos requeridos para dividendos
    console.log('\n2c. Probando validación de campos requeridos para dividendos...');
    const repartoIncompleto = {
      proposalid: 1,
      // Faltan campos requeridos
    };

    try {
      await axios.post(`${BASE_URL}/repartirDividendos`, repartoIncompleto);
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   ✅ Validación correcta de campos requeridos');
        console.log(`   📝 Errores: ${error.response.data.details?.join(', ')}`);
      }
    }

    // Test 2d: Usuario sin permisos
    console.log('\n2d. Probando reparto con usuario sin permisos...');
    const repartoSinPermisos = {
      ...repartoData,
      processedby: 999 // Usuario inexistente/sin permisos
    };

    try {
      await axios.post(`${BASE_URL}/repartirDividendos`, repartoSinPermisos);
    } catch (error) {
      if (error.response?.status === 403) {
        console.log('   ✅ Validación correcta de permisos');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }

    // ===== TEST 3: MÉTODOS NO PERMITIDOS =====
    console.log('\n\n⚠️  TEST 3: Métodos HTTP no permitidos');
    console.log('-'.repeat(60));

    // Test 3a: PUT en inversión
    console.log('\n3a. Probando método PUT en inversión...');
    try {
      await axios.put(`${BASE_URL}/invertirEnPropuesta`, {});
    } catch (error) {
      if (error.response?.status === 405) {
        console.log('   ✅ Método PUT correctamente rechazado');
        console.log(`   Métodos permitidos: ${error.response.data.allowedMethods?.join(', ')}`);
      }
    }

    // Test 3b: DELETE en dividendos
    console.log('\n3b. Probando método DELETE en dividendos...');
    try {
      await axios.delete(`${BASE_URL}/repartirDividendos`);
    } catch (error) {
      if (error.response?.status === 405) {
        console.log('   ✅ Método DELETE correctamente rechazado');
        console.log(`   Métodos permitidos: ${error.response.data.allowedMethods?.join(', ')}`);
      }
    }

    console.log('\n🎉 Pruebas de endpoints Stored Procedures completadas!');
    console.log('=' .repeat(80));

  } catch (error) {
    console.error('\n💥 Error general en las pruebas:', error.message);
  }
}

// Función auxiliar para mostrar resumen de conexión
async function mostrarInfoConexion() {
  console.log('🔗 Información de conexión:');
  console.log(`   Base URL: ${BASE_URL}`);
  console.log(`   Endpoints disponibles:`);
  console.log(`   - POST ${BASE_URL}/invertirEnPropuesta`);
  console.log(`   - GET  ${BASE_URL}/invertirEnPropuesta?proposalid=<id>&userid=<id>`);
  console.log(`   - POST ${BASE_URL}/repartirDividendos`);
  console.log(`   - GET  ${BASE_URL}/repartirDividendos?proposalid=<id>&reportid=<id>`);
  console.log('');
}

// Ejecutar pruebas
async function main() {
  await mostrarInfoConexion();
  await testStoredProceduresEndpoints();
}

// Manejar errores no capturados
process.on('unhandledRejection', (error) => {
  console.error('💥 Error no manejado:', error.message);
  process.exit(1);
});

// Ejecutar si se llama directamente
if (require.main === module) {
  main().catch(console.error);
}

module.exports = { testStoredProceduresEndpoints };
