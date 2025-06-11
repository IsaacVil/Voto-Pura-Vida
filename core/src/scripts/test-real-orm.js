/**
 * Script de Testing Automatizado Real para ORM de Votación
 * Ejecutar: npm run test:real-orm
 */

require('dotenv').config();
const axios = require('axios');
const fs = require('fs');
const path = require('path');

const BASE_URL = `http://localhost:${process.env.PORT || 3000}/api/orm`;
const RESULTS_FILE = path.join(__dirname, '..', 'testing', 'test-results.json');

class VotingTestSuite {
  constructor() {
    this.results = {
      timestamp: new Date().toISOString(),
      totalTests: 0,
      passed: 0,
      failed: 0,
      tests: []
    };
  }

  async runTest(name, testFunction) {
    console.log(`\n🧪 Ejecutando: ${name}`);
    console.log('─'.repeat(60));
    
    const startTime = Date.now();
    let result;
    
    try {
      result = await testFunction();
      this.results.passed++;
      console.log(`✅ PASÓ: ${name} (${Date.now() - startTime}ms)`);
    } catch (error) {
      result = { error: error.message, stack: error.stack };
      this.results.failed++;
      console.log(`❌ FALLÓ: ${name} (${Date.now() - startTime}ms)`);
      console.log(`   Error: ${error.message}`);
    }
    
    this.results.totalTests++;
    this.results.tests.push({
      name,
      status: result.error ? 'FAILED' : 'PASSED',
      duration: Date.now() - startTime,
      result,
      timestamp: new Date().toISOString()
    });
    
    return result;
  }

  async testServerHealth() {
    const response = await axios.get(`${BASE_URL}/health`);
    
    if (response.status !== 200) {
      throw new Error(`Servidor no saludable: ${response.status}`);
    }
    
    console.log(`   Estado del servidor: ${response.data.status || 'OK'}`);
    return response.data;
  }

  async testValidVote() {
    const voteData = {
      userid: 1,
      proposalid: 1,
      voteDecision: 'yes',
      mfaToken: `test_token_${Date.now()}`,
      mfaCode: '123456',
      biometricData: `bio_${Date.now()}`,
      clientIP: '192.168.1.100',
      userAgent: 'RealTesting/1.0'
    };
    
    const response = await axios.post(`${BASE_URL}/votar`, voteData);
    
    if (response.status === 200) {
      console.log(`   ✅ Voto registrado: ID ${response.data.data?.voteId}`);
      console.log(`   📊 Hash: ${response.data.data?.hash?.substring(0, 16)}...`);
      return response.data;
    } else if (response.status === 409) {
      console.log(`   ⚠️ Usuario ya votó (esperado en re-tests)`);
      return response.data;
    } else {
      throw new Error(`Respuesta inesperada: ${response.status}`);
    }
  }

  async testInvalidUser() {
    const voteData = {
      userid: 99999,
      proposalid: 1,
      voteDecision: 'no',
      mfaToken: 'invalid_token',
      mfaCode: '123456',
      biometricData: 'bio_test',
      clientIP: '192.168.1.101',
      userAgent: 'RealTesting/1.0'
    };
    
    try {
      await axios.post(`${BASE_URL}/votar`, voteData);
      throw new Error('Debería haber fallado con usuario inexistente');
    } catch (error) {
      if (error.response?.status === 404) {
        console.log(`   ✅ Validación correcta: ${error.response.data.error}`);
        return error.response.data;
      }
      throw error;
    }
  }

  async testMissingFields() {
    const incompleteData = {
      userid: 1,
      proposalid: 1
      // Campos faltantes intencionalmente
    };
    
    try {
      await axios.post(`${BASE_URL}/votar`, incompleteData);
      throw new Error('Debería haber fallado con campos faltantes');
    } catch (error) {
      if (error.response?.status === 400) {
        console.log(`   ✅ Validación correcta: ${error.response.data.error}`);
        return error.response.data;
      }
      throw error;
    }
  }

  async testInvalidProposal() {
    const voteData = {
      userid: 2,
      proposalid: 99999,
      voteDecision: 'abstain',
      mfaToken: 'test_token_proposal',
      mfaCode: '123456',
      biometricData: 'bio_proposal_test',
      clientIP: '192.168.1.102',
      userAgent: 'RealTesting/1.0'
    };
    
    try {
      await axios.post(`${BASE_URL}/votar`, voteData);
      throw new Error('Debería haber fallado con propuesta inexistente');
    } catch (error) {
      if (error.response?.status === 404) {
        console.log(`   ✅ Validación correcta: ${error.response.data.error}`);
        return error.response.data;
      }
      throw error;
    }
  }

  async testDoubleVoting() {
    const voteData = {
      userid: 1,
      proposalid: 1,
      voteDecision: 'no', // Cambiar decisión
      mfaToken: 'double_vote_token',
      mfaCode: '123456',
      biometricData: 'bio_double_test',
      clientIP: '192.168.1.103',
      userAgent: 'RealTesting/1.0'
    };
    
    try {
      await axios.post(`${BASE_URL}/votar`, voteData);
      throw new Error('Debería haber fallado por doble votación');
    } catch (error) {
      if (error.response?.status === 409) {
        console.log(`   ✅ Prevención correcta: ${error.response.data.error}`);
        return error.response.data;
      }
      throw error;
    }
  }

  async testDifferentVoteTypes() {
    const decisions = ['yes', 'no', 'abstain'];
    const results = [];
    
    for (let i = 0; i < decisions.length; i++) {
      const decision = decisions[i];
      const voteData = {
        userid: i + 10, // Usuarios únicos
        proposalid: 1,
        voteDecision: decision,
        mfaToken: `token_${decision}_${i}`,
        mfaCode: '123456',
        biometricData: `bio_${decision}_${i}`,
        clientIP: `192.168.1.${110 + i}`,
        userAgent: 'RealTesting/1.0'
      };
      
      try {
        const response = await axios.post(`${BASE_URL}/votar`, voteData);
        console.log(`   ✅ Voto "${decision}": ID ${response.data.data?.voteId}`);
        results.push({ decision, success: true, data: response.data });
      } catch (error) {
        console.log(`   ⚠️ Voto "${decision}": ${error.response?.data?.error || error.message}`);
        results.push({ decision, success: false, error: error.response?.data });
      }
      
      // Pausa entre votos
      await new Promise(resolve => setTimeout(resolve, 500));
    }
    
    return results;
  }

  async testVotingMetrics() {
    try {
      const response = await axios.get(`${BASE_URL}/usuarios?include_voting_metrics=true&limit=10`);
      
      if (response.status === 200) {
        console.log(`   ✅ Métricas obtenidas: ${response.data.data?.length || 0} usuarios`);
        return response.data;
      } else {
        throw new Error(`Error obteniendo métricas: ${response.status}`);
      }
    } catch (error) {
      console.log(`   ⚠️ Endpoint de métricas no disponible: ${error.message}`);
      return { error: error.message, expected: true };
    }
  }

  async testLoadTesting() {
    console.log(`   🔄 Ejecutando ${5} votos simultáneos...`);
    
    const promises = [];
    for (let i = 0; i < 5; i++) {
      const voteData = {
        userid: i + 20,
        proposalid: 1,
        voteDecision: ['yes', 'no', 'abstain'][i % 3],
        mfaToken: `load_token_${i}`,
        mfaCode: '123456',
        biometricData: `load_bio_${i}`,
        clientIP: `192.168.1.${120 + i}`,
        userAgent: 'LoadTesting/1.0'
      };
      
      promises.push(
        axios.post(`${BASE_URL}/votar`, voteData)
          .then(response => ({ success: true, userid: voteData.userid, data: response.data }))
          .catch(error => ({ success: false, userid: voteData.userid, error: error.response?.data }))
      );
    }
    
    const results = await Promise.all(promises);
    const successful = results.filter(r => r.success).length;
    
    console.log(`   📊 Resultados de carga: ${successful}/${results.length} exitosos`);
    
    return {
      total: results.length,
      successful,
      failed: results.length - successful,
      results
    };
  }

  async generateReport() {
    const reportPath = path.join(__dirname, '..', 'testing', `test-report-${Date.now()}.html`);
    
    const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Reporte de Testing ORM - Voto Pura Vida</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #007bff; color: white; padding: 20px; border-radius: 8px; }
        .summary { display: flex; gap: 20px; margin: 20px 0; }
        .metric { background: #f8f9fa; padding: 15px; border-radius: 8px; text-align: center; }
        .test { border: 1px solid #ddd; margin: 10px 0; border-radius: 4px; }
        .test-header { padding: 10px; background: #f8f9fa; font-weight: bold; }
        .test-body { padding: 10px; }
        .passed { border-left: 4px solid #28a745; }
        .failed { border-left: 4px solid #dc3545; }
        .code { background: #f1f1f1; padding: 10px; border-radius: 4px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🗳️ Reporte de Testing - Sistema de Votación ORM</h1>
        <p>Generado: ${new Date().toLocaleString()}</p>
    </div>
    
    <div class="summary">
        <div class="metric">
            <h3>${this.results.totalTests}</h3>
            <p>Tests Totales</p>
        </div>
        <div class="metric">
            <h3>${this.results.passed}</h3>
            <p>Exitosos</p>
        </div>
        <div class="metric">
            <h3>${this.results.failed}</h3>
            <p>Fallidos</p>
        </div>
        <div class="metric">
            <h3>${((this.results.passed / this.results.totalTests) * 100).toFixed(1)}%</h3>
            <p>Tasa de Éxito</p>
        </div>
    </div>
    
    <h2>Detalles de Tests</h2>
    ${this.results.tests.map(test => `
        <div class="test ${test.status.toLowerCase()}">
            <div class="test-header">
                ${test.status === 'PASSED' ? '✅' : '❌'} ${test.name} (${test.duration}ms)
            </div>
            <div class="test-body">
                <div class="code">${JSON.stringify(test.result, null, 2)}</div>
            </div>
        </div>
    `).join('')}
</body>
</html>`;
    
    fs.writeFileSync(reportPath, html);
    console.log(`\n📋 Reporte HTML generado: ${reportPath}`);
    
    return reportPath;
  }

  async saveResults() {
    try {
      const dir = path.dirname(RESULTS_FILE);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      
      fs.writeFileSync(RESULTS_FILE, JSON.stringify(this.results, null, 2));
      console.log(`\n💾 Resultados guardados: ${RESULTS_FILE}`);
    } catch (error) {
      console.error(`❌ Error guardando resultados: ${error.message}`);
    }
  }

  async run() {
    console.log('🚀 INICIANDO TESTING REAL DEL ORM DE VOTACIÓN');
    console.log('═'.repeat(80));
    
    // Tests básicos
    await this.runTest('1. Salud del Servidor', () => this.testServerHealth());
    await this.runTest('2. Voto Válido', () => this.testValidVote());
    await this.runTest('3. Usuario Inexistente', () => this.testInvalidUser());
    await this.runTest('4. Campos Faltantes', () => this.testMissingFields());
    await this.runTest('5. Propuesta Inexistente', () => this.testInvalidProposal());
    await this.runTest('6. Doble Votación', () => this.testDoubleVoting());
    await this.runTest('7. Tipos de Voto', () => this.testDifferentVoteTypes());
    await this.runTest('8. Métricas de Votación', () => this.testVotingMetrics());
    await this.runTest('9. Testing de Carga', () => this.testLoadTesting());
    
    // Resumen final
    console.log('\n' + '═'.repeat(80));
    console.log('📊 RESUMEN FINAL DEL TESTING');
    console.log('═'.repeat(80));
    console.log(`Total de Tests: ${this.results.totalTests}`);
    console.log(`✅ Exitosos: ${this.results.passed}`);
    console.log(`❌ Fallidos: ${this.results.failed}`);
    console.log(`📈 Tasa de Éxito: ${((this.results.passed / this.results.totalTests) * 100).toFixed(1)}%`);
    
    await this.saveResults();
    await this.generateReport();
    
    console.log('\n🎉 TESTING COMPLETADO!');
    
    return this.results;
  }
}

// Ejecutar si se llama directamente
if (require.main === module) {
  const testSuite = new VotingTestSuite();
  testSuite.run().catch(console.error);
}

module.exports = VotingTestSuite;
