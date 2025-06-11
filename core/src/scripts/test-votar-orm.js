/**
 * Script de prueba para el endpoint de votación ORM
 * Ejecutar: npm run test:votar-orm
 */

require('dotenv').config();
const axios = require('axios');

const BASE_URL = `http://localhost:${process.env.PORT || 3000}/api/orm`;

async function testVotarORM() {
  console.log('Iniciando pruebas del endpoint de votación ORM...\n');

  try {
    // ===== TEST 0: OBTENER OPCIONES DE VOTACIÓN =====
    console.log('0. Test: Obtener opciones de votación disponibles');
    
    const opcionesResponse = await axios.get(`${BASE_URL}/votar?proposalid=1`);
    console.log('Opciones obtenidas:', JSON.stringify(opcionesResponse.data, null, 2));
    
    const opciones = opcionesResponse.data.data;
    if (!opciones.preguntas.length) {
      throw new Error('No se encontraron preguntas para la propuesta');
    }
    
    const primeraPregunta = opciones.preguntas[0];
    const primeraOpcion = primeraPregunta.opciones[0];
    
    console.log(`✅ Opciones obtenidas correctamente`);
    console.log(`   Pregunta: ${primeraPregunta.question}`);
    console.log(`   Primera opción: ${primeraOpcion.optiontext}\n`);

    // ===== TEST 1: VOTACIÓN EXITOSA =====
    console.log('1. Test: Votación exitosa con todos los datos');
    
    const votoValido = {
      userid: 1,
      proposalid: 1,
      optionid: primeraOpcion.optionid,
      questionid: primeraPregunta.questionId,
      mfaToken: 'valid_token_123',
      mfaCode: '123456',
      biometricData: 'biometric_data_sample',
      clientIP: '192.168.1.100',
      userAgent: 'Test Voting Client'
    };    try {
      const response = await axios.post(`${BASE_URL}/votar`, votoValido);
      
      if (response.status === 201) {
        console.log('   ✅ Voto procesado exitosamente');
        console.log(`   Vote ID: ${response.data.data.voteId}`);
        console.log(`   Propuesta: ${response.data.data.proposalId}`);
        console.log(`   Pregunta: ${response.data.data.question}`);
        console.log(`   Opción seleccionada: ${response.data.data.selectedOption}`);
        console.log(`   Timestamp: ${response.data.data.timestamp}`);
        console.log(`   Hash: ${response.data.data.hash}`);
      }
    } catch (error) {
      const errorData = error.response?.data;
      console.log(`   ❌ Error: ${error.response?.status} - ${errorData?.error || error.message}`);
      if (errorData?.errorCode) {
        console.log(`   Código de error: ${errorData.errorCode}`);
      }
    }    // ===== TEST 2: VALIDACIONES DE CAMPOS REQUERIDOS =====
    console.log('\n2. Test: Validación de campos requeridos');
    
    const datosIncompletos = {
      userid: 1,
      proposalid: 1
      // Faltan optionid, questionid, mfaToken, mfaCode
    };

    try {
      await axios.post(`${BASE_URL}/votar`, datosIncompletos);
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   ✅ Validación correcta de campos requeridos');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }    // ===== TEST 3: USUARIO INEXISTENTE =====
    console.log('\n3. Test: Usuario inexistente');
    
    const usuarioInexistente = {
      userid: 9999,
      proposalid: 1,
      optionid: primeraOpcion.optionid,
      questionid: primeraPregunta.questionId,
      mfaToken: 'token_9999',
      mfaCode: '123456',
      biometricData: 'bio_data'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, usuarioInexistente);
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('   ✅ Validación correcta de usuario inexistente');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }    // ===== TEST 4: PROPUESTA INEXISTENTE =====
    console.log('\n4. Test: Propuesta inexistente');
    
    const propuestaInexistente = {
      userid: 1,
      proposalid: 9999,
      optionid: 1,
      questionid: 1,
      mfaToken: 'token_1',
      mfaCode: '123456',
      biometricData: 'bio_data'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, propuestaInexistente);
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('   ✅ Validación correcta de propuesta inexistente');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }

    // ===== TEST 5: OPCIÓN INVÁLIDA =====
    console.log('\n5. Test: Opción de voto inválida');
    
    const opcionInvalida = {
      userid: 1,
      proposalid: 1,
      optionid: 9999, // Opción que no existe
      questionid: primeraPregunta.questionId,
      mfaToken: 'token_1',
      mfaCode: '123456',
      biometricData: 'bio_data'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, opcionInvalida);
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   ✅ Validación correcta de opción inválida');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }

    // ===== TEST 6: MFA INVÁLIDO =====
    console.log('\n6. Test: MFA inválido');
    
    const mfaInvalido = {
      userid: 1,
      proposalid: 1,
      optionid: primeraOpcion.optionid,
      questionid: primeraPregunta.questionId,
      mfaToken: 'invalid_token',
      mfaCode: '000', // Código inválido (muy corto)
      biometricData: 'bio_data'
    };

    try {
      await axios.post(`${BASE_URL}/votar`, mfaInvalido);
    } catch (error) {
      if (error.response?.status === 401) {
        console.log('   ✅ Validación correcta de MFA inválido');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }

    // ===== TEST 7: MÚLTIPLES VOTOS DEL MISMO USUARIO =====
    console.log('\n7. Test: Prevención de doble votación');
    
    // Usar segunda opción para el segundo voto
    const segundaOpcion = primeraPregunta.opciones[1] || primeraPregunta.opciones[0];
    
    const segundoVoto = {
      userid: 1,
      proposalid: 1,
      optionid: segundaOpcion.optionid,
      questionid: primeraPregunta.questionId,
      mfaToken: 'token_1',
      mfaCode: '123456',
      biometricData: 'bio_data_2'
    };    try {
      await axios.post(`${BASE_URL}/votar`, segundoVoto);
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('   ✅ Prevención correcta de doble votación');
        console.log(`   Error: ${error.response.data.error}`);
      }
    }    // ===== TEST 8: DIFERENTES OPCIONES DE VOTO =====
    console.log('\n8. Test: Diferentes opciones de voto');
    
    const opcionesDisponibles = primeraPregunta.opciones;
    
    for (let i = 0; i < opcionesDisponibles.length && i < 3; i++) {
      const opcion = opcionesDisponibles[i];
      const votoOpcion = {
        userid: i + 5, // Usuarios diferentes para evitar conflictos
        proposalid: 1,
        optionid: opcion.optionid,
        questionid: primeraPregunta.questionId,
        mfaToken: `token_${i + 5}`,
        mfaCode: `${(i + 1).toString().repeat(6)}`, // 6 dígitos        biometricData: `bio_data_${i}`
      };

      try {
        const response = await axios.post(`${BASE_URL}/votar`, votoOpcion);
        console.log(`   ✅ Voto "${opcion.optiontext}" procesado para usuario ${i + 5}`);
      } catch (error) {
        console.log(`   ❌ Voto "${opcion.optiontext}" - Error: ${error.response?.data?.error || error.message}`);
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

  // Primero obtener las opciones de votación
  try {
    const opcionesResponse = await axios.get(`${BASE_URL}/votar?proposalid=1`);
    const opciones = opcionesResponse.data.data;
    const primeraPregunta = opciones.preguntas[0];
    const opcionesDisponibles = primeraPregunta.opciones;

    const usuarios = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]; // Usuarios de prueba
    
    const resultados = {
      exitosos: 0,
      errores: 0,
      detalles: []
    };

    for (let i = 0; i < usuarios.length; i++) {
      const userid = usuarios[i];
      const opcionSeleccionada = opcionesDisponibles[i % opcionesDisponibles.length];
      
      const votoData = {
        userid,
        proposalid: 1,
        optionid: opcionSeleccionada.optionid,
        questionid: primeraPregunta.questionId,
        mfaToken: `batch_token_${userid}`,
        mfaCode: `${i.toString().padStart(6, '0')}`,
        biometricData: `batch_bio_${userid}`,
        clientIP: `192.168.1.${100 + i}`,
        userAgent: 'Batch Test Client'
      };

      try {
        console.log(`Procesando voto de usuario ${userid} (${opcionSeleccionada.optiontext})...`);
        
        const response = await axios.post(`${BASE_URL}/votar`, votoData);
        
        if (response.status === 201) {
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
      }

      // Pausa pequeña entre requests
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

  } catch (error) {
    console.log(`Error obteniendo opciones para pruebas de carga: ${error.message}`);
  }
}

// ===== FUNCIÓN PARA PROBAR MÉTRICAS DE VOTACIÓN =====
async function testMetricasVotacion() {
  console.log('\n9. Probando consulta de métricas de votación...\n');

  try {
    // Obtener métricas de votación para la propuesta 1
    const response = await axios.get(`${BASE_URL}/votar?proposalid=1&metrics=true`);
    
    console.log('   ✅ Métricas obtenidas exitosamente');
    console.log(`   Total de votos: ${response.data.data.totalVotos}`);
    console.log('   Distribución de votos:');
    
    response.data.data.distribucionVotos.forEach(distribucion => {
      console.log(`     • ${distribucion.opcion}: ${distribucion.cantidad} votos (${distribucion.porcentaje}%)`);
    });
    
  } catch (error) {
    console.log(`   ❌ Error obteniendo métricas: ${error.response?.data?.error || error.message}`);
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

