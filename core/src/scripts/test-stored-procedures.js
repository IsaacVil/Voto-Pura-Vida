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

    // ===== TEST 4: CREAR/ACTUALIZAR PROPUESTA =====
    console.log('\n\n📝 TEST 4: Crear/Actualizar Propuesta (crearActualizarPropuesta)');
    console.log('-'.repeat(60));

    // Test 4a: Crear nueva propuesta 
    console.log('\n4a. Creando nueva propuesta...');
    const nuevaPropuesta = {
      title: 'Renovación del Parque Central',
      description: 'Proyecto de renovación integral del Parque Central de San José, incluyendo mejoras en infraestructura, áreas verdes y espacios recreativos.',
      proposalcontent: 'El proyecto contempla: 1) Renovación de senderos peatonales, 2) Instalación de nueva iluminación LED, 3) Creación de áreas de juegos infantiles, 4) Mejora del sistema de riego, 5) Plantación de árboles nativos.',
      budget: 50000000.00,
      createdby: 1,
      proposaltypeid: 1,
      organizationid: 1,
      version: 1,

      mediapath: '/uploads/cedula.pdf,/uploads/comprobante.pdf,/uploads/planos.dwg',
      mediatypeid: '1,2,3',
      sizeMB: '2,1,15',
      encoding: 'UTF-8,UTF-8,ASCII',
      samplerate: '0,0,0',
      languagecode: 'ES,ES,ES',
      documenttypeid: '1,2,3', 

      changecomments: 'Propuesta inicial - versión 1.0',
      targetSegments: 'Adultos,Jóvenes,Familias',
      segmentWeights: '0.40,0.35,0.25', 


      startdate: '2025-07-01T08:00:00.000Z',
      enddate: '2025-07-15T18:00:00.000Z',
      votingtypeid: 1,
      allowweightedvotes: true,
      requiresallvoters: false,
      notificationmethodid: 1,
      publisheddate: '2025-06-20T09:00:00.000Z',
      finalizeddate: '2025-08-20T09:00:00.000Z',
      publicvoting: true
    };

    try {
      const crearResponse = await axios.post(`${BASE_URL}/crearActualizarPropuesta`, nuevaPropuesta);
      console.log('   ✅ Propuesta creada exitosamente');
      console.log(`   📝 Mensaje: ${crearResponse.data.message}`);
      console.log(`   🆔 Propuesta ID: ${crearResponse.data.data.proposalId || 'N/A'}`);
      console.log(`   💰 Presupuesto: ₡${crearResponse.data.data.budget.toLocaleString('es-CR')}`);
      console.log(`   👤 Creada por usuario: ${crearResponse.data.data.createdBy}`);
      console.log(`   📄 Documentos: ${crearResponse.data.data.hasDocuments ? 'Sí (3 archivos)' : 'No'}`);
      console.log(`   🎯 Segmentos: ${crearResponse.data.data.hasTargetSegments ? 'Sí (3 segmentos)' : 'No'}`);
      console.log(`   📅 Procesado: ${new Date(crearResponse.data.data.processedAt).toLocaleString('es-CR')}`);
      
    
      if (crearResponse.data.data.details) {
        console.log(`   📊 Detalles del proceso:`);
        console.log(`      - Workflow ejecutado: ${crearResponse.data.data.details.workflowExecuted ? 'Sí' : 'No'}`);
        console.log(`      - Documentos procesados: ${crearResponse.data.data.details.documentsProcessed ? 'Sí' : 'No'}`);
        console.log(`      - Validaciones aplicadas: ${crearResponse.data.data.details.validationRulesApplied ? 'Sí' : 'No'}`);
      }
      
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
      if (error.response?.data?.details) {
        console.log(`   📝 Detalles del error:`);
        if (Array.isArray(error.response.data.details)) {
          error.response.data.details.forEach((detail, index) => {
            console.log(`      ${index + 1}. ${detail}`);
          });
        } else {
          console.log(`      - ${error.response.data.details}`);
        }
      }
      if (error.response?.status) {
        console.log(`   📊 Status HTTP: ${error.response.status}`);
      }
    }

    // Test 4b: Obtener información de propuesta creada
    console.log('\n4b. Obteniendo información de propuesta creada...');
    try {
      const infoResponse = await axios.get(`${BASE_URL}/crearActualizarPropuesta?proposalid=1`);
      console.log('   ✅ Información obtenida exitosamente');
      console.log(`   📋 Título: ${infoResponse.data.data.propuesta.title}`);
      console.log(`   💰 Presupuesto: ₡${infoResponse.data.data.propuesta.budget.toLocaleString('es-CR')}`);
      console.log(`   👤 Creada por: ${infoResponse.data.data.propuesta.createdByName || 'N/A'}`);
      console.log(`   📊 Estado: ${infoResponse.data.data.propuesta.statusName || 'N/A'}`);
      console.log(`   🏷️ Tipo: ${infoResponse.data.data.propuesta.typeName || 'N/A'}`);
      console.log(`   📄 Total documentos: ${infoResponse.data.data.resumen.totalDocumentos}`);
      console.log(`   🗳️ Votación configurada: ${infoResponse.data.data.resumen.tieneVotacion ? 'Sí' : 'No'}`);
      console.log(`   🎯 Segmentos objetivo: ${infoResponse.data.data.resumen.totalSegmentos}`);
      console.log(`   🔧 Reglas validación: ${infoResponse.data.data.resumen.totalReglasValidacion || 0}`);
      console.log(`   📅 Creada: ${new Date(infoResponse.data.data.propuesta.createdon).toLocaleString('es-CR')}`);
      
      // ✅ MOSTRAR DOCUMENTOS CREADOS
      if (infoResponse.data.data.documentos && infoResponse.data.data.documentos.length > 0) {
        console.log(`   📄 Documentos creados:`);
        infoResponse.data.data.documentos.forEach((doc, index) => {
          console.log(`      ${index + 1}. ${doc.mediapath} (${doc.sizeMB}MB, Tipo: ${doc.documentTypeName || 'N/A'})`);
        });
      }
      
      // ✅ MOSTRAR SEGMENTOS CREADOS
      if (infoResponse.data.data.segmentosObjetivo && infoResponse.data.data.segmentosObjetivo.length > 0) {
        console.log(`   🎯 Segmentos objetivo creados:`);
        infoResponse.data.data.segmentosObjetivo.forEach(seg => {
          console.log(`      - ${seg.segmentName}: ${(seg.voteweight * 100).toFixed(1)}%`);
        });
      }
      
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
    }

    // Test 4c: Actualizar propuesta existente
    console.log('\n4c. Actualizando propuesta existente...');
    const actualizacion = {
      proposalid: 1,
      title: 'Renovación del Parque Central - ACTUALIZADA',
      description: 'Proyecto de renovación integral del Parque Central de San José, incluyendo mejoras en infraestructura, áreas verdes, espacios recreativos Y NUEVAS ÁREAS DEPORTIVAS.',
      proposalcontent: 'El proyecto contempla: 1) Renovación de senderos peatonales, 2) Instalación de nueva iluminación LED, 3) Creación de áreas de juegos infantiles, 4) Mejora del sistema de riego, 5) Plantación de árboles nativos, 6) NUEVA: Construcción de cancha deportiva.',
      budget: 65000000.00, 
      createdby: 1,
      proposaltypeid: 1,
      organizationid: 1,
      version: 1,
      
      documentids: '1,2,3',
      mediapath: '/uploads/cedula_v2.pdf,/uploads/comprobante_v2.pdf,/uploads/planos_v2.dwg',
      mediatypeid: '1,2,3',
      sizeMB: '3,2,18', 
      encoding: 'UTF-8,UTF-8,ASCII',
      samplerate: '0,0,0',
      languagecode: 'ES,ES,ES',
      documenttypeid: '1,2,3',
      
      changecomments: 'Actualización mayor: presupuesto ampliado de ₡50M a ₡65M, documentos actualizados con versión 2',
      
      targetSegments: 'Adultos,Jóvenes,Familias,Deportistas',
      segmentWeights: '0.35,0.30,0.25,0.10', 
      
      startdate: '2025-07-01T08:00:00.000Z',
      enddate: '2025-07-30T18:00:00.000Z', 
      votingtypeid: 1,
      allowweightedvotes: false, 
      requiresallvoters: true, 
      notificationmethodid: 2, 
      publisheddate: '2025-06-20T09:00:00.000Z',
      finalizeddate: '2025-08-30T09:00:00.000Z', 
      publicvoting: false 
    };

    try {
      const actualizarResponse = await axios.put(`${BASE_URL}/crearActualizarPropuesta`, actualizacion);
      console.log('   ✅ Propuesta actualizada exitosamente');
      console.log(`   📝 Mensaje: ${actualizarResponse.data.message}`);
      console.log(`   🔄 Nueva versión: ${actualizarResponse.data.data.newVersion}`);
      console.log(`   🆔 Propuesta ID: ${actualizarResponse.data.data.proposalId}`);
      console.log(`   💰 Nuevo presupuesto: ₡${actualizacion.budget.toLocaleString('es-CR')}`);
      console.log(`   📄 Docs actualizados: ${actualizarResponse.data.data.hasDocumentUpdates ? 'Sí' : 'No'}`);
      console.log(`   🎯 Segmentos actualizados: ${actualizarResponse.data.data.hasTargetSegments ? 'Sí' : 'No'}`);
      console.log(`   📅 Actualizado: ${new Date(actualizarResponse.data.data.updatedAt).toLocaleString('es-CR')}`);
      
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
      if (error.response?.data?.details) {
        console.log(`   📝 Detalles: ${error.response.data.details}`);
      }
    }

    // Test 4d: Validación de datos inválidos
    console.log('\n4d. Probando validación de datos inválidos...');
    try {
      await axios.post(`${BASE_URL}/crearActualizarPropuesta`, {
        title: '', 
        description: 'Descripción válida',
        budget: -1000, 
        createdby: null, 
        proposaltypeid: 'invalid' 
      });
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   ✅ Validación correcta de datos inválidos');
        console.log(`   📝 Errores detectados: ${error.response.data.details?.length || 1}`);
        if (error.response.data.details) {
          error.response.data.details.forEach((detail, index) => {
            console.log(`      ${index + 1}. ${detail}`);
          });
        }
      } else {
        console.log(`   ❌ Error inesperado: ${error.response?.data?.error || error.message}`);
      }
    }

    // Test 4e: Propuesta inexistente para actualizar
    console.log('\n4e. Probando actualización de propuesta inexistente...');
    try {
      await axios.put(`${BASE_URL}/crearActualizarPropuesta`, {
        proposalid: 99999, 
        title: 'Propuesta Inexistente',
        description: 'Esta propuesta no debería existir',
        budget: 50000,
        createdby: 1,
        proposaltypeid: 1
      });
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('   ✅ Validación correcta de propuesta inexistente');
        console.log(`   📝 Error: ${error.response.data.error}`);
      } else {
        console.log(`   ❌ Error inesperado: ${error.response?.data?.error || error.message}`);
      }
    }

    // Test 4f: Usuario sin permisos
    console.log('\n4f. Probando creación con usuario sin permisos...');
    try {
      await axios.post(`${BASE_URL}/crearActualizarPropuesta`, {
        ...nuevaPropuesta,
        createdby: 999 // ❌ Usuario inexistente/sin permisos
      });
    } catch (error) {
      if (error.response?.status === 403) {
        console.log('   ✅ Validación correcta de permisos');
        console.log(`   📝 Error: ${error.response.data.error}`);
      } else {
        console.log(`   ❌ Error inesperado: ${error.response?.data?.error || error.message}`);
      }
    }

    // Test 4g: Verificar estado final después de las operaciones
    console.log('\n4g. Verificando estado final de la propuesta...');
    try {
      const estadoFinalResponse = await axios.get(`${BASE_URL}/crearActualizarPropuesta?proposalid=1`);
      console.log('   ✅ Estado final verificado');
      console.log(`   📋 Título final: ${estadoFinalResponse.data.data.propuesta.title}`);
      console.log(`   💰 Presupuesto final: ₡${estadoFinalResponse.data.data.propuesta.budget.toLocaleString('es-CR')}`);
      console.log(`   🔢 Versión actual: ${estadoFinalResponse.data.data.propuesta.version}`);
      console.log(`   📊 Total versiones: ${estadoFinalResponse.data.data.propuesta.totalVersions || 'N/A'}`);
      console.log(`   📄 Documentos finales: ${estadoFinalResponse.data.data.resumen.totalDocumentos}`);
      console.log(`   🎯 Segmentos finales: ${estadoFinalResponse.data.data.resumen.totalSegmentos}`);
      console.log(`   📅 Última modificación: ${new Date(estadoFinalResponse.data.data.propuesta.lastmodified).toLocaleString('es-CR')}`);
      
    } catch (error) {
      console.log(`   ❌ Error en verificación final: ${error.response?.data?.error || error.message}`);
    }

    // ===== TEST 5: REVISAR PROPUESTA =====
    console.log('\n\n🔍 TEST 5: Revisar Propuesta (revisarPropuesta)');
    console.log('-'.repeat(60));

    // Test 5a: Obtener información de propuesta para revisión
    console.log('\n5a. Obteniendo información de propuesta para revisión...');
    try {
      const infoRevisionResponse = await axios.get(`${BASE_URL}/revisarPropuesta?proposalid=1`);
      console.log('   ✅ Información de revisión obtenida exitosamente');
      console.log(`   📋 Propuesta: ${infoRevisionResponse.data.data.propuesta.title}`);
      console.log(`   💰 Presupuesto: ₡${infoRevisionResponse.data.data.propuesta.budget.toLocaleString('es-CR')}`);
      console.log(`   📊 Estado: ${infoRevisionResponse.data.data.propuesta.statusName || 'N/A'}`);
      console.log(`   🏷️ Tipo: ${infoRevisionResponse.data.data.propuesta.proposalTypeName || 'N/A'}`);
      console.log(`   👤 Creada por: ${infoRevisionResponse.data.data.propuesta.createdBy || 'N/A'}`);
      console.log(`   📄 Total documentos: ${infoRevisionResponse.data.data.resumen.totalDocumentos}`);
      console.log(`   ✅ Docs aprobados: ${infoRevisionResponse.data.data.resumen.documentosAprobados}`);
      console.log(`   ⏳ Docs pendientes: ${infoRevisionResponse.data.data.resumen.documentosPendientes}`);
      console.log(`   🔬 Docs analizados: ${infoRevisionResponse.data.data.resumen.documentosAnalizados}`);
      console.log(`   📊 Análisis previo: ${infoRevisionResponse.data.data.resumen.tieneAnalisisPrevio ? 'Sí' : 'No'}`);
      console.log(`   🚀 Listo para revisión: ${infoRevisionResponse.data.data.resumen.listoParaRevision ? 'Sí' : 'No'}`);
      console.log(`   🔧 Reglas validación: ${infoRevisionResponse.data.data.resumen.totalReglasValidacion || 0}`);
      console.log(`   📋 Logs workflow: ${infoRevisionResponse.data.data.resumen.workflowLogsCount || 0}`);
      
      if (infoRevisionResponse.data.data.documentos && infoRevisionResponse.data.data.documentos.length > 0) {
        console.log(`   📄 Documentos para revisar:`);
        infoRevisionResponse.data.data.documentos.forEach((doc, index) => {
          console.log(`      ${index + 1}. ${doc.mediapath} - Estado: ${doc.aivalidationstatus || 'Pendiente'} (${doc.sizeMB}MB)`);
        });
      }
      
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
    }

    // Test 5b: Ejecutar revisión de propuesta
    console.log('\n5b. Ejecutando revisión completa de propuesta...');
    try {
      const revisionResponse = await axios.post(`${BASE_URL}/revisarPropuesta`, {
        proposalid: 1
      });
      
      console.log('   ✅ Revisión ejecutada exitosamente');
      console.log(`   📝 Mensaje: ${revisionResponse.data.message}`);
      console.log(`   📊 Estado: ${revisionResponse.data.data.status}`);
      console.log(`   🆔 Propuesta ID: ${revisionResponse.data.data.proposalId}`);
      console.log(`   🕐 Procesado: ${new Date(revisionResponse.data.data.processedAt).toLocaleString('es-CR')}`);
      
      // ✅ MOSTRAR DETALLES DEL PROCESO
      if (revisionResponse.data.data.details) {
        console.log(`   📊 Detalles del proceso de revisión:`);
        console.log(`      - Workflow ejecutado: ${revisionResponse.data.data.details.workflowExecuted ? 'Sí' : 'No'}`);
        console.log(`      - Documentos procesados: ${revisionResponse.data.data.details.documentsProcessed ? 'Sí' : 'No'}`);
        console.log(`      - Propuesta analizada: ${revisionResponse.data.data.details.proposalAnalyzed ? 'Sí' : 'No'}`);
        console.log(`      - Logs generados: ${revisionResponse.data.data.details.logsGenerated ? 'Sí' : 'No'}`);
        console.log(`      - Reglas aplicadas: ${revisionResponse.data.data.details.validationRulesApplied ? 'Sí' : 'No'}`);
      }
      
    } catch (error) {
      console.log(`   ❌ Error: ${error.response?.data?.error || error.message}`);
      if (error.response?.data?.details) {
        console.log(`   📝 Detalles: ${error.response.data.details}`);
      }
    }

    // Test 5c: Revisar propuesta inexistente
    console.log('\n5c. Probando revisión de propuesta inexistente...');
    try {
      await axios.post(`${BASE_URL}/revisarPropuesta`, {
        proposalid: 99999
      });
    } catch (error) {
      if (error.response?.status === 404) {
        console.log('   ✅ Validación correcta de propuesta inexistente');
        console.log(`   📝 Error: ${error.response.data.error}`);
      } else {
        console.log(`   ❌ Error inesperado: ${error.response?.data?.error || error.message}`);
      }
    }

    // Test 5d: Datos faltantes
    console.log('\n5d. Probando revisión sin ID de propuesta...');
    try {
      await axios.post(`${BASE_URL}/revisarPropuesta`, {});
    } catch (error) {
      if (error.response?.status === 400) {
        console.log('   ✅ Validación correcta de datos faltantes');
        console.log(`   📝 Error: ${error.response.data.error}`);
      }
    }

    // Test 5e: Verificar resultados después de la revisión
    console.log('\n5e. Verificando resultados después de la revisión...');
    try {
      const verificacionResponse = await axios.get(`${BASE_URL}/revisarPropuesta?proposalid=1`);
      const resumen = verificacionResponse.data.data.resumen;
      
      console.log('   ✅ Verificación completada');
      console.log(`   📊 Docs analizados después: ${resumen.documentosAnalizados}`);
      console.log(`   ✅ Docs aprobados después: ${resumen.documentosAprobados}`);
      console.log(`   ⏳ Docs pendientes después: ${resumen.documentosPendientes}`);
      console.log(`   📈 Análisis previo ahora: ${resumen.tieneAnalisisPrevio ? 'Sí' : 'No'}`);
      console.log(`   📅 Última revisión: ${resumen.ultimaRevision ? new Date(resumen.ultimaRevision).toLocaleString('es-CR') : 'N/A'}`);
      console.log(`   📋 Logs workflow generados: ${resumen.workflowLogsCount || 0}`);
      
      if (verificacionResponse.data.data.analisisPrevios.length > 0) {
        const ultimoAnalisis = verificacionResponse.data.data.analisisPrevios[0];
        console.log(`   🔬 Último análisis AI:`);
        console.log(`      - Confianza: ${ultimoAnalisis.confidence ? (ultimoAnalisis.confidence * 100).toFixed(1) + '%' : 'N/A'}`);
        console.log(`      - Recomendaciones: ${ultimoAnalisis.recommendations || 'N/A'}`);
        console.log(`      - Factores de riesgo: ${ultimoAnalisis.riskfactors || 'N/A'}`);
        console.log(`      - Problemas de cumplimiento: ${ultimoAnalisis.complianceissues || 'N/A'}`);
        console.log(`      - Análisis presupuestario: ${ultimoAnalisis.budgetanalysis || 'N/A'}`);
        console.log(`      - Workflow: ${ultimoAnalisis.workflowName || 'N/A'}`);
      }
      
      if (verificacionResponse.data.data.reglasValidacion && verificacionResponse.data.data.reglasValidacion.length > 0) {
        console.log(`   🔧 Reglas de validación aplicadas:`);
        verificacionResponse.data.data.reglasValidacion.forEach((regla, index) => {
          console.log(`      ${index + 1}. ${regla.fieldname}: ${regla.ruletype} (${regla.rulevalue})`);
        });
      }
      
    } catch (error) {
      console.log(`   ❌ Error en verificación: ${error.response?.data?.error || error.message}`);
    }

    // Test 5f: Método no permitido
    console.log('\n5f. Probando método no permitido en revisarPropuesta...');
    try {
      await axios.put(`${BASE_URL}/revisarPropuesta`, { proposalid: 1 });
    } catch (error) {
      if (error.response?.status === 405) {
        console.log('   ✅ Método PUT correctamente rechazado');
        console.log(`   📝 Métodos permitidos: ${error.response.data.allowedMethods?.join(', ')}`);
      }
    }

    console.log('\n🎉 Pruebas de endpoints Stored Procedures completadas!');
    console.log('=' .repeat(80));

  } catch (error) {
    console.error('\n💥 Error general en las pruebas:', error.message);
  }
}

async function mostrarInfoConexion() {
  console.log('🔗 Información de conexión:');
  console.log(`   Base URL: ${BASE_URL}`);
  console.log(`   Endpoints disponibles:`);
  console.log(`   - POST ${BASE_URL}/invertirEnPropuesta`);
  console.log(`   - GET  ${BASE_URL}/invertirEnPropuesta?proposalid=<id>&userid=<id>`);
  console.log(`   - POST ${BASE_URL}/repartirDividendos`);
  console.log(`   - GET  ${BASE_URL}/repartirDividendos?proposalid=<id>&reportid=<id>`);
  console.log(`   - POST ${BASE_URL}/crearActualizarPropuesta`);
  console.log(`   - PUT  ${BASE_URL}/crearActualizarPropuesta`);
  console.log(`   - GET  ${BASE_URL}/crearActualizarPropuesta?proposalid=<id>`);
  console.log(`   - POST ${BASE_URL}/revisarPropuesta`);
  console.log(`   - GET  ${BASE_URL}/revisarPropuesta?proposalid=<id>`);
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