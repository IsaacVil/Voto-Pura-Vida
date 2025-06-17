/**
 * Endpoint: /api/stored-procedures/revisarPropuesta
 * Permite revisar propuestas utilizando el SP revisarPropuesta
 */

const sql = require('mssql');
const { getDbConfig } = require('../../src/config/database');
const config = getDbConfig();

module.exports = async (req, res) => {
  try {
    const { method } = req;

    if (method === 'POST') {
      // POST: Ejecutar revisión de propuesta usando el SP
      return await ejecutarRevisionPropuesta(req, res);
    
    } else if (method === 'GET') {
      // GET: Obtener información de propuesta para revisión
      const { proposalid } = req.query;
      return await obtenerInformacionRevision(req, res, proposalid);
    
    } else {
      res.setHeader('Allow', ['GET', 'POST']);
      return res.status(405).json({
        error: `Método ${method} no permitido`,
        allowedMethods: ['GET', 'POST'],
        timestamp: new Date().toISOString()
      });
    }

  } catch (error) {
    console.error('Error en endpoint revisarPropuesta:', error);
    return res.status(500).json({
      error: 'Error interno del servidor',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Ejecuta la revisión de propuesta llamando al SP revisarPropuesta
 */
async function ejecutarRevisionPropuesta(req, res) {
  const { proposalid } = req.body;

  // Validación básica
  if (!proposalid) {
    return res.status(400).json({
      error: 'ID de propuesta requerido',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Iniciando revisión de propuesta: ${proposalid}`);

    // Conectar a SQL Server
    pool = await sql.connect(config);

    // Preparar la llamada al stored procedure
    const request = pool.request();
    
    // Agregar parámetros
    request.input('proposalid', sql.Int, parseInt(proposalid));
    request.output('mensaje', sql.NVarChar(200), '');

    // Ejecutar el stored procedure
    console.log('Ejecutando SP revisarPropuesta...');
    const result = await request.execute('revisarPropuesta');

    // Obtener el mensaje de salida
    const mensaje = result.output.mensaje;

    console.log('Revisión de propuesta completada:', mensaje);

    let status = 'unknown';
    if (mensaje.includes('aprobada') || mensaje.includes('publicada')) {
      status = 'approved';
    } else if (mensaje.includes('revisión') || mensaje.includes('requiere')) {
      status = 'review_required';
    } else if (mensaje.includes('ERROR') || mensaje.includes('error')) {
      status = 'error';
    } else {
      status = mensaje.includes('aprobada') ? 'approved' : 'review_required';
    }

    // Respuesta exitosa
    return res.status(200).json({
      success: true,
      message: mensaje,
      data: {
        proposalId: parseInt(proposalid),
        processedAt: new Date(),
        status: status,
        details: {
          workflowExecuted: true,
          documentsProcessed: true,
          proposalAnalyzed: true,
          logsGenerated: true,
          validationRulesApplied: true  
        }
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error ejecutando SP revisarPropuesta:', error);

    // Manejar errores específicos del SP
    let statusCode = 500;
    let errorMessage = 'Error al revisar la propuesta';
    
    if (error.message) {
      if (error.message.includes('no existe')) {
        statusCode = 404;
        errorMessage = 'La propuesta no existe';
      } else if (error.message.includes('sin documentos')) {
        statusCode = 400;
        errorMessage = 'La propuesta no tiene documentos para revisar';
      } else if (error.message.includes('ya procesada')) {
        statusCode = 409;
        errorMessage = 'La propuesta ya fue procesada';
      } else if (error.message.includes('permisos')) {  
        statusCode = 403;
        errorMessage = 'Sin permisos para revisar la propuesta';
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message,
      errorCode: 'SP_REVISION_ERROR',
      timestamp: new Date().toISOString()
    });

  } finally {
    // Cerrar conexión
    if (pool) {
      try {
        await pool.close();
      } catch (closeError) {
        console.error('Error cerrando conexión:', closeError);
      }
    }
  }
}

/**
 * Obtiene información de propuesta para revisión
 */
async function obtenerInformacionRevision(req, res, proposalid) {
  if (!proposalid) {
    return res.status(400).json({
      error: 'ID de propuesta requerido',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    pool = await sql.connect(config);

    // Obtener información de la propuesta
    const propuestaRequest = pool.request();
    propuestaRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const propuestaResult = await propuestaRequest.query(`
      SELECT 
        p.proposalid,
        p.title,
        p.description,
        p.budget,
        p.statusid,
        ps.name as statusName,
        p.createdon,
        p.lastmodified,
        u.firstname + ' ' + u.lastname as createdBy,
        pt.name as proposalTypeName 
      FROM PV_Proposals p
      LEFT JOIN PV_ProposalStatus ps ON p.statusid = ps.statusid
      LEFT JOIN PV_Users u ON p.createdby = u.userid
      LEFT JOIN PV_ProposalTypes pt ON p.proposaltypeid = pt.proposaltypeid 
      WHERE p.proposalid = @proposalid
    `);

    if (propuestaResult.recordset.length === 0) {
      return res.status(404).json({
        error: 'Propuesta no encontrada',
        timestamp: new Date().toISOString()
      });
    }

    // Obtener documentos de la propuesta
    const documentosRequest = pool.request();
    documentosRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const documentosResult = await documentosRequest.query(`
      SELECT 
        d.documentId,
        d.documentTypeId,
        d.aivalidationstatus,
        d.aivalidationresult,  
        d.version,
        dt.name as documentTypeName,
        m.mediapath,
        m.sizeMB,
        CASE 
          WHEN ada.documentid IS NOT NULL THEN 'Analyzed'
          ELSE 'Pending'
        END as analysisStatus,
        ada.confidence,  
        ada.result as analysisResult,  
        ada.analysisdate  
      FROM PV_ProposalDocuments pd
      JOIN PV_Documents d ON pd.documentId = d.documentId
      LEFT JOIN PV_DocumentTypes dt ON d.documentTypeId = dt.documentTypeId
      LEFT JOIN PV_mediafiles m ON d.mediafileId = m.mediafileid
      LEFT JOIN PV_AIDocumentAnalysis ada ON d.documentId = ada.documentid
      WHERE pd.proposalid = @proposalid
      ORDER BY d.documentId 
    `);

    // Obtener análisis AI previos
    const analisisRequest = pool.request();
    analisisRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const analisisResult = await analisisRequest.query(`
      SELECT 
        apa.proposalid,
        apa.confidence,
        apa.findings,
        apa.recommendations,
        apa.riskfactors, 
        apa.complianceissues,  
        apa.budgetanalysis,  
        apa.analysisdate,
        w.name as workflowName
      FROM PV_AIProposalAnalysis apa
      LEFT JOIN PV_Workflows w ON apa.workflowId = w.workflowId
      WHERE apa.proposalid = @proposalid
      ORDER BY apa.analysisdate DESC
    `);

    // ✅ MEJORAR QUERY DE LOGS - MÁS ESPECÍFICA
    const logsRequest = pool.request();
    logsRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const logsResult = await logsRequest.query(`
      SELECT 
        l.description,
        l.name,
        l.posttime,
        l.value1,
        l.value2,
        l.referenceid1,
        l.referenceid2
      FROM PV_Logs l
      WHERE (l.referenceid1 = @proposalid OR l.referenceid2 = @proposalid)
        AND l.name LIKE '%workflow%'  
      ORDER BY l.posttime DESC
    `);

    const validationRulesRequest = pool.request();
    validationRulesRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const validationRulesResult = await validationRulesRequest.query(`
      SELECT 
        vr.validationruleid,
        vr.fieldname,
        vr.ruletype,
        vr.rulevalue,
        vr.errormessage
      FROM PV_Proposals p
      JOIN PV_ValidationRules vr ON p.proposaltypeid = vr.proposaltypeid
      WHERE p.proposalid = @proposalid
    `);

    return res.status(200).json({
      success: true,
      data: {
        propuesta: propuestaResult.recordset[0],
        documentos: documentosResult.recordset,
        analisisPrevios: analisisResult.recordset,
        logsWorkflow: logsResult.recordset,
        reglasValidacion: validationRulesResult.recordset,  
        resumen: {
          totalDocumentos: documentosResult.recordset.length,
          documentosAprobados: documentosResult.recordset.filter(d => d.aivalidationstatus === 'Approved').length,
          documentosPendientes: documentosResult.recordset.filter(d => d.aivalidationstatus === 'Pending' || d.aivalidationstatus === 'Pendiente a revision').length,  // ✅ MEJORADO
          documentosAnalizados: documentosResult.recordset.filter(d => d.analysisStatus === 'Analyzed').length,
          tieneAnalisisPrevio: analisisResult.recordset.length > 0,
          ultimaRevision: analisisResult.recordset.length > 0 ? analisisResult.recordset[0].analysisdate : null,
          listoParaRevision: propuestaResult.recordset[0].statusid === 1 && documentosResult.recordset.length > 0,
          totalReglasValidacion: validationRulesResult.recordset.length, 
        }
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error obteniendo información de revisión:', error);
    return res.status(500).json({
      error: 'Error al obtener información de propuesta',
      details: error.message,
      timestamp: new Date().toISOString()
    });

  } finally {
    if (pool) {
      try {
        await pool.close();
      } catch (closeError) {
        console.error('Error cerrando conexión:', closeError);
      }
    }
  }
}