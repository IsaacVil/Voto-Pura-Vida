/**
 * Script de prueba para el endpoint de votación ORM
 * Ejecutar: npm run test:votar-orm
 */

require('dotenv').config();
const axios = require('axios');

const BASE_URL = `http://localhost:${process.env.PORT || 3001}/api/orm`;

async function testVotarORM() {
  console.log('Iniciando pruebas del endpoint de votación ORM...\n');

  try {
    // ===== TEST 1: VOTACIÓN EXITOSA =====
    console.log('1. Test: Votación exitosa con todos los datos');
    
    const votoValido = {
      userid: 1,
      proposalid: 1,
      voteDecision: 'yes',
      mfaToken: 'valid_token_123',
      mfaCode: '123456',
      biometricData: 'biometric_data_sample',
      clientIP: '192.168.1.100',
      userAgent: 'Test Voting Client'
    };

    try {
      const response = await axios.post(`${BASE_URL}/votar`, votoValido);
      
      if (response.status === 0) {
        console.log('   Voto procesado exitosamente');
        console.log(`   Vote ID: ${response.data.data.voteId}`);
        console.log(`   Propuesta: ${response.data.data.proposalId}`);
        console.log(`   Timestamp: ${response.data.data.timestamp}`);
        console.log(`   Hash: ${response.data.data.hash}`);
      }
    } catch (error) {
      const errorData = error.response?.data;
      console.log(`   Resultado: ${error.response?.status} - ${errorData?.error || error.message}`);
      if (errorData?.errorCode) {
        console.log(`   Código de error: ${errorData.errorCode}`);
      }
    }    // ===== TEST 2: VALIDACIONES DE CAMPOS REQUERIDOS =====
    console.log('\n2. Test: Validación de campos requeridos');
    
    const datosIncompletos = {
      userid: 1,
      proposalid: 1
      // Faltan campos requeridos
    };

    try {
      await axios.post(`${BASE_URL}/votar`, datosIncompletos);
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   Validación correcta de campos requeridos');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }    // ===== TEST 3: USUARIO INEXISTENTE =====
    console.log('\n3. Test: Usuario inexistente');
    
    const usuarioInexistente = {
      userid: 9999,
      proposalid: 1,
      voteDecision: 'no',
      mfaToken: 'token_9999',
      mfaCode: '123456',
      biometricData: 'bio_data'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, usuarioInexistente);
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('   Validación correcta de usuario inexistente');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }    // ===== TEST 4: PROPUESTA INEXISTENTE =====
    console.log('\n4. Test: Propuesta inexistente');
    
    const propuestaInexistente = {
      userid: 1,
      proposalid: 9999,
      voteDecision: 'abstain',
      mfaToken: 'token_1',
      mfaCode: '123456',
      biometricData: 'bio_data'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, propuestaInexistente);
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('   Validación correcta de propuesta inexistente');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }

    // ===== TEST 5: MFA INVÁLIDO =====
    console.log('\n5. Test: MFA inválido');
    
    const mfaInvalido = {
      userid: 1,
      proposalid: 1,
      voteDecision: 'yes',
      mfaToken: 'invalid_token',
      mfaCode: '000', // Código inválido (muy corto)
      biometricData: 'bio_data'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, mfaInvalido);
    } catch (error) {
      if (error.response?.status === 401) {
        console.log('   Validación correcta de MFA inválido');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }

    // ===== TEST 6: MÚLTIPLES VOTOS DEL MISMO USUARIO =====
    console.log('\n6. Test: Prevención de doble votación');
    
    const segundoVoto = {
      userid: 1,
      proposalid: 1,
      voteDecision: 'no', // Cambiar decisión
      mfaToken: 'token_1',
      mfaCode: '123456',
      biometricData: 'bio_data_2'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, segundoVoto);
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('   Prevención correcta de doble votación');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }    // ===== TEST 7: DIFERENTES DECISIONES DE VOTO =====
    console.log('\n7. Test: Diferentes tipos de decisión');
    
    const tiposDecision = ['yes', 'no', 'abstain'];
    
    for (let i = 0; i < tiposDecision.length; i++) {
      const decision = tiposDecision[i];
      const votoTipoDecision = {
        userid: i + 5, // Usuarios diferentes para evitar conflictos
        proposalid: 1,
        voteDecision: decision,
        mfaToken: `token_${i}`,
        mfaCode: `${i}${i}${i}${i}${i}${i}`, // 6 dígitos
        biometricData: `bio_data_${i}`
      };

      try {
        const response = await axios.post(`${BASE_URL}/votar`, votoTipoDecision);
        console.log(`   Voto "${decision}" procesado para usuario ${i + 5}`);      } catch (error) {
        console.log(`       Voto "${decision}" - Error: ${error.response?.data?.error || error.message}`);
      }
    }

    console.log('\nPruebas del endpoint de votación completadas!');

  } catch (error) {
    console.error('\nError general en las pruebas:', error.message);
  }
}

// ===== FUNCIÓN PARA PROBAR CARGA DE VOTACIÓN =====
async function testCargaVotacion() {
  console.log('\n8. Simulando carga de votación (múltiples usuarios)...\n');

  const usuarios = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]; // Usuarios de prueba
  const decisiones = ['yes', 'no', 'abstain'];
  
  const resultados = {
    exitosos: 0,
    errores: 0,
    detalles: []
  };

  for (let i = 0; i < usuarios.length; i++) {
    const userid = usuarios[i];
    const decision = decisiones[i % decisiones.length];
      const votoData = {
      userid,
      proposalid: 1,
      voteDecision: decision,
      mfaToken: `batch_token_${userid}`,
      mfaCode: `${i.toString().padStart(6, '0')}`,
      biometricData: `batch_bio_${userid}`,
      clientIP: `192.168.1.${100 + i}`,
      userAgent: 'Batch Test Client'
    };

    try {
      console.log(`Procesando voto de usuario ${userid} (${decision})...`);
      
      const response = await axios.post(`${BASE_URL}/votar`, votoData);
      
      if (response.status === 0) {
        resultados.exitosos++;
        console.log(`   Usuario ${userid}: Voto ID ${response.data.data.voteId}`);
      }
    } catch (error) {
      resultados.errores++;
      const errorMsg = error.response?.data?.error || error.message;
      console.log(`   Usuario ${userid}: ${errorMsg}`);
      
      resultados.detalles.push({
        userid,
        error: errorMsg,
        codigo: error.response?.data?.errorCode
      });
    }    // Pausa pequeña entre requests
    await new Promise(resolve => setTimeout(resolve, 100));
  }

  console.log('\nResumen de carga de votación:');
  console.log(`   Votos exitosos: ${resultados.exitosos}`);
  console.log(`   Errores: ${resultados.errores}`);
  console.log(`   Tasa de éxito: ${((resultados.exitosos / usuarios.length) * 100).toFixed(1)}%`);
  
  if (resultados.detalles.length > 0) {
    console.log('\nDetalles de errores:');
    resultados.detalles.forEach(detalle => {
      console.log(`   • Usuario ${detalle.userid}: ${detalle.error} (${detalle.codigo || 'N/A'})`);
    });
  }
}

// ===== FUNCIÓN PARA PROBAR MÉTRICAS DE VOTACIÓN =====
async function testMetricasVotacion() {
  console.log('\n9. Probando consulta de métricas de votación...\n');

  try {
    // Intentar obtener métricas usando el endpoint de usuarios (con filtros)
    const response = await axios.get(`${BASE_URL}/usuarios?include_voting_metrics=true&limit=5`);
    
    console.log('   Métricas obtenidas exitosamente');
    console.log(`   Usuarios con métricas: ${response.data.data.length}`);
    
  } catch (error) {
    console.log(`   Error obteniendo métricas: ${error.response?.data?.error || error.message}`);
  }
}

// ===== EJECUTAR TODAS LAS PRUEBAS =====
async function runAllVotingTests() {
  console.log('Iniciando suite completa de pruebas de votación\n');
  console.log('='.repeat(60));
  
  await testVotarORM();
  await testCargaVotacion();
  await testMetricasVotacion();
  
  console.log('\n' + '='.repeat(60));
  console.log('Suite de pruebas de votación finalizada');
  console.log('\nNotas importantes:');
  console.log('   • Las pruebas asumen datos de prueba en la BD');
  console.log('   • Algunos errores son esperados (validaciones)');
  console.log('   • El cifrado y MFA son simulados para testing');
  console.log('   • En producción, implementar validaciones reales');
}

// Ejecutar si se llama directamente
if (require.main === module) {
  runAllVotingTests().catch(console.error);
}

module.exports = {
  testVotarORM,
  testCargaVotacion,
  testMetricasVotacion,
  runAllVotingTests
};

