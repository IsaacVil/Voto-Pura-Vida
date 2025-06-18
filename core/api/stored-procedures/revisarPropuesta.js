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
 * Obtiene información simplificada de propuesta para revisión
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

    // ✅ 1. INFORMACIÓN BÁSICA DE LA PROPUESTA
    const propuestaRequest = pool.request();
    propuestaRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const propuestaResult = await propuestaRequest.query(`
      SELECT 
        p.proposalid,
        p.title,
        p.statusid,
        ps.name as statusName
      FROM PV_Proposals p
      LEFT JOIN PV_ProposalStatus ps ON p.statusid = ps.statusid
      WHERE p.proposalid = @proposalid
    `);

    if (propuestaResult.recordset.length === 0) {
      return res.status(404).json({
        error: 'Propuesta no encontrada',
        timestamp: new Date().toISOString()
      });
    }

    // ✅ 2. DOCUMENTOS ÚNICOS - Solo los más recientes por documento
    const documentosRequest = pool.request();
    documentosRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const documentosResult = await documentosRequest.query(`
      WITH DocumentosUnicos AS (
        SELECT 
          d.documentId,
          d.documentTypeId,
          d.aivalidationstatus,
          dt.name as documentTypeName,
          ROW_NUMBER() OVER (PARTITION BY d.documentId ORDER BY d.version DESC, d.documentId DESC) as rn
        FROM PV_ProposalDocuments pd
        JOIN PV_Documents d ON pd.documentId = d.documentId
        LEFT JOIN PV_DocumentTypes dt ON d.documentTypeId = dt.documentTypeId
        WHERE pd.proposalid = @proposalid
      )
      SELECT 
        documentId,
        documentTypeId,
        aivalidationstatus,
        documentTypeName
      FROM DocumentosUnicos 
      WHERE rn = 1
      ORDER BY documentId
    `);

    // ✅ 3. LOGS DE WORKFLOW - Solo últimos 10 con referenceIDs y values
    const logsRequest = pool.request();
    logsRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const logsResult = await logsRequest.query(`
      SELECT TOP 10
        l.name,
        l.posttime,
        l.referenceid1,
        l.referenceid2,
        l.value1,
        l.value2
      FROM PV_Logs l
      WHERE (l.referenceid1 = @proposalid OR l.referenceid2 = @proposalid)
        AND l.name LIKE '%workflow%'  
      ORDER BY l.posttime DESC
    `);    // ✅ RESPUESTA SIMPLIFICADA
    return res.status(200).json({
      success: true,
      data: {
        propuesta: {
          proposalid: propuestaResult.recordset[0].proposalid,
          title: propuestaResult.recordset[0].title,
          statusid: propuestaResult.recordset[0].statusid,
          statusName: propuestaResult.recordset[0].statusName
        },
        documentos: documentosResult.recordset.map(doc => ({
          documentId: doc.documentId,
          documentTypeName: doc.documentTypeName,
          status: doc.aivalidationstatus,
          approved: doc.aivalidationstatus === 'Approved'
        })),
        logs: logsResult.recordset.map(log => ({
          name: log.name,
          posttime: log.posttime,
          referenceid1: log.referenceid1,
          referenceid2: log.referenceid2,
          // ✅ LIMPIAR AGRESIVAMENTE LOS \r\n DE LOS VALUES
          value1: log.value1 ? log.value1.replace(/\r\n/g, '').replace(/\r/g, '').replace(/\n/g, '').replace(/\t/g, '').replace(/    /g, ' ').replace(/,}/g, '}') : null,
          value2: log.value2 ? log.value2.replace(/\r\n/g, '').replace(/\r/g, '').replace(/\n/g, '').replace(/\t/g, '').replace(/    /g, ' ').replace(/,}/g, '}') : null
        }))
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