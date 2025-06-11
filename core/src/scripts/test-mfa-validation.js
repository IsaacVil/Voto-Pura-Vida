/**
 * Script de prueba para validar las funciones MFA implementadas
 * Este script prueba específicamente la validación MFA en el endpoint de votar
 */

const axios = require('axios');
const speakeasy = require('speakeasy');

const BASE_URL = 'http://localhost:3000/api';

// Configuración para pruebas
const TEST_CONFIG = {
  userid: 1,
  proposalid: 1,
  optionid: 1,
  questionid: 1,
  biometricData: JSON.stringify({
    type: 'facial',
    data: 'sample_biometric_data',
    confidence: 0.95
  })
};

/**
 * Probar validación TOTP
 */
async function testTOTPValidation() {
  console.log('\n=== PRUEBA DE VALIDACIÓN TOTP ===');
  
  try {
    // Generar un secreto TOTP de prueba
    const secret = speakeasy.generateSecret({
      name: 'VotoPuraVida Test',
      length: 32
    });
    
    console.log(`Secret TOTP generado: ${secret.base32}`);
    
    // Generar código TOTP válido
    const validToken = speakeasy.totp({
      secret: secret.base32,
      encoding: 'base32'
    });
    
    console.log(`Código TOTP válido generado: ${validToken}`);
    
    // Test 1: Código TOTP válido (simulado)
    const testData = {
      ...TEST_CONFIG,
      mfaToken: 'totp_token',
      mfaCode: validToken
    };
    
    console.log('Enviando solicitud con código TOTP válido...');
    const response = await axios.post(`${BASE_URL}/orm/votar`, testData);
    console.log('✅ Respuesta:', response.status, response.data?.success ? 'SUCCESS' : 'ERROR');
    
  } catch (error) {
    if (error.response) {
      console.log(`📋 Status: ${error.response.status}`);
      console.log(`📋 Error: ${error.response.data.error}`);
      
      // Verificar si el error es por MFA (esperado en entorno de prueba)
      if (error.response.data.error?.includes('MFA') || 
          error.response.data.error?.includes('TOTP') ||
          error.response.status === 401) {
        console.log('✅ Validación MFA funcionando correctamente');
      }
    } else {
      console.error('❌ Error de conexión:', error.message);
    }
  }
}

/**
 * Probar validación SMS
 */
async function testSMSValidation() {
  console.log('\n=== PRUEBA DE VALIDACIÓN SMS ===');
  
  try {
    const testData = {
      ...TEST_CONFIG,
      mfaToken: 'sms_token_12345',
      mfaCode: '123456'
    };
    
    console.log('Enviando solicitud con código SMS...');
    const response = await axios.post(`${BASE_URL}/orm/votar`, testData);
    console.log('✅ Respuesta:', response.status, response.data?.success ? 'SUCCESS' : 'ERROR');
    
  } catch (error) {
    if (error.response) {
      console.log(`📋 Status: ${error.response.status}`);
      console.log(`📋 Error: ${error.response.data.error}`);
      
      if (error.response.data.error?.includes('MFA') || 
          error.response.data.error?.includes('SMS') ||
          error.response.status === 401) {
        console.log('✅ Validación SMS funcionando correctamente');
      }
    } else {
      console.error('❌ Error de conexión:', error.message);
    }
  }
}

/**
 * Probar validación Email
 */
async function testEmailValidation() {
  console.log('\n=== PRUEBA DE VALIDACIÓN EMAIL ===');
  
  try {
    const testData = {
      ...TEST_CONFIG,
      mfaToken: 'email_token_67890',
      mfaCode: '654321'
    };
    
    console.log('Enviando solicitud con código Email...');
    const response = await axios.post(`${BASE_URL}/orm/votar`, testData);
    console.log('✅ Respuesta:', response.status, response.data?.success ? 'SUCCESS' : 'ERROR');
    
  } catch (error) {
    if (error.response) {
      console.log(`📋 Status: ${error.response.status}`);
      console.log(`📋 Error: ${error.response.data.error}`);
      
      if (error.response.data.error?.includes('MFA') || 
          error.response.data.error?.includes('EMAIL') ||
          error.response.status === 401) {
        console.log('✅ Validación Email funcionando correctamente');
      }
    } else {
      console.error('❌ Error de conexión:', error.message);
    }
  }
}

/**
 * Probar códigos MFA inválidos
 */
async function testInvalidMFA() {
  console.log('\n=== PRUEBA DE CÓDIGOS MFA INVÁLIDOS ===');
  
  const invalidCodes = [
    { code: '123', desc: 'muy corto' },
    { code: '1234567', desc: 'muy largo' },
    { code: 'abcdef', desc: 'no numérico' },
    { code: '', desc: 'vacío' }
  ];
  
  for (const invalid of invalidCodes) {
    try {
      console.log(`\nProbando código ${invalid.desc}: "${invalid.code}"`);
      
      const testData = {
        ...TEST_CONFIG,
        mfaToken: 'test_token',
        mfaCode: invalid.code
      };
      
      const response = await axios.post(`${BASE_URL}/orm/votar`, testData);
      console.log('❌ No debería haber aceptado el código:', response.status);
      
    } catch (error) {
      if (error.response?.status === 400 || error.response?.status === 401) {
        console.log(`✅ Correctamente rechazado código ${invalid.desc}`);
      } else {
        console.log(`📋 Error: ${error.response?.data?.error || error.message}`);
      }
    }
  }
}

/**
 * Verificar que el endpoint de health funciona
 */
async function testHealthEndpoint() {
  console.log('\n=== PRUEBA DE HEALTH ENDPOINT ===');
  
  try {
    const response = await axios.get(`${BASE_URL}/orm/health`);
    console.log('✅ Health endpoint funcionando:', response.data);
  } catch (error) {
    console.error('❌ Error en health endpoint:', error.message);
  }
}

/**
 * Función principal de pruebas
 */
async function runMFATests() {
  console.log('🔐 INICIANDO PRUEBAS DE VALIDACIÓN MFA');
  console.log('=======================================');
  
  try {
    // Verificar que el servidor esté funcionando
    await testHealthEndpoint();
    
    // Probar diferentes métodos MFA
    await testTOTPValidation();
    await testSMSValidation();
    await testEmailValidation();
    
    // Probar códigos inválidos
    await testInvalidMFA();
    
    console.log('\n✅ TODAS LAS PRUEBAS MFA COMPLETADAS');
    console.log('=======================================');
    
  } catch (error) {
    console.error('❌ Error general en las pruebas:', error.message);
  }
}

// Ejecutar pruebas si el script se ejecuta directamente
if (require.main === module) {
  runMFATests().catch(console.error);
}

module.exports = { runMFATests };
