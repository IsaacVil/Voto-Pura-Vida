/**
 * ENDPOINT: /api/stored-procedures/revisarPropuesta
 * 
 * DESCRIPCIÓN:
 * API para revisar propuestas utilizando el stored procedure 'revisarPropuesta'.
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
      const { email, proposalName } = req.query;
      return await obtenerInformacionRevision(req, res, email, proposalName);
    
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


 //FUNCIÓN: ejecutarRevisionPropuesta

async function ejecutarRevisionPropuesta(req, res) {
  const { email, proposalName } = req.body;

  // Validación básica del email
  if (!email) {
    return res.status(400).json({
      error: 'Email del usuario es requerido',
      timestamp: new Date().toISOString()
    });
  }

  // Validación básica del nombre de propuesta
  if (!proposalName) {
    return res.status(400).json({
      error: 'Nombre de la propuesta es requerido',
      timestamp: new Date().toISOString()
    });
  }

  // Validación de formato de email básico
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      error: 'Formato de email inválido',
      details: 'El email debe tener un formato válido (ejemplo@dominio.com)',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Iniciando revisión de propuesta: ${proposalName} para usuario: ${email}`);

    // Conectar a SQL Server
    pool = await sql.connect(config);

    // Preparar la llamada al stored procedure
    const request = pool.request();
    
    // Agregar parámetros email y nombre de propuesta
    request.input('email', sql.NVarChar(100), email.trim().toLowerCase());
    request.input('proposalName', sql.NVarChar(200), proposalName.trim());

    // NOTA: Ya no usamos parámetro de salida 'mensaje' - el SP ahora lanza errores directamente
    // Si llega aquí sin excepción, significa que la revisión fue exitosa

    console.log('Ejecutando SP revisarPropuesta...');
    const result = await request.execute('revisarPropuesta');

    // Si llegamos aquí, la propuesta fue revisada y aprobada exitosamente
    console.log('Revisión de propuesta completada exitosamente');

    // Respuesta exitosa - la propuesta fue aprobada y publicada
    return res.status(200).json({
      success: true,
      message: 'Propuesta revisada y aprobada exitosamente',
      data: {
        userEmail: email,
        proposalName: proposalName,
        processedAt: new Date(),
        status: 'approved_and_published',
        details: {
          workflowExecuted: true,
          documentsProcessed: true,
          proposalAnalyzed: true,
          logsGenerated: true,
          validationRulesApplied: true,
          statusUpdated: true
        }
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error ejecutando SP revisarPropuesta:', error);

    // Manejo específico de errores lanzados por RAISERROR del stored procedure
    let statusCode = 500;
    let errorMessage = 'Error al revisar la propuesta';
    let errorCode = 'SP_REVISION_ERROR';
    
    if (error.message) {
      const errorMsg = error.message.toLowerCase();
      
      // Errores de validación de entrada (400 Bad Request)
      if (errorMsg.includes('email es requerido') || 
          errorMsg.includes('email inválido') ||
          errorMsg.includes('formato de email') ||
          errorMsg.includes('nombre de la propuesta es requerido')) {
        statusCode = 400;
        errorMessage = 'Email o nombre de propuesta inválido';
        errorCode = 'INVALID_INPUT';
      }
      // Errores de recursos no encontrados (404 Not Found)
      else if (errorMsg.includes('no se encontró usuario') ||
               errorMsg.includes('usuario no existe') ||
               errorMsg.includes('no se encontró propuesta pendiente') ||
               errorMsg.includes('sin propuestas pendientes') ||
               errorMsg.includes('nombre especificado')) {
        statusCode = 404;
        errorMessage = 'Usuario o propuesta no encontrada';
        errorCode = 'USER_OR_PROPOSAL_NOT_FOUND';
      }
      // Errores de proceso de revisión (409 Conflict)
      else if (errorMsg.includes('propuesta requiere revisión') ||
               errorMsg.includes('no cumple todos los criterios') ||
               errorMsg.includes('criterios de aprobación')) {
        statusCode = 409;
        errorMessage = 'La propuesta no cumple los criterios de aprobación automática';
        errorCode = 'PROPOSAL_REVIEW_REQUIRED';
      }
      // Errores de configuración o workflow (422 Unprocessable Entity)
      else if (errorMsg.includes('workflow no configurado') ||
               errorMsg.includes('sin documentos') ||
               errorMsg.includes('documentos no válidos')) {
        statusCode = 422;
        errorMessage = 'Propuesta no procesable - configuración o documentos incorrectos';
        errorCode = 'UNPROCESSABLE_PROPOSAL';
      }
      // Si el mensaje específico es útil, lo usamos directamente
      else if (error.message.length < 200) {
        errorMessage = error.message;
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message,
      errorCode: errorCode,
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

async function obtenerInformacionRevision(req, res, email, proposalName) {
  if (!email) {
    return res.status(400).json({
      error: 'Email del usuario es requerido',
      timestamp: new Date().toISOString()
    });
  }

  if (!proposalName) {
    return res.status(400).json({
      error: 'Nombre de la propuesta es requerido',
      timestamp: new Date().toISOString()
    });
  }

  // Validación de formato de email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      error: 'Formato de email inválido',
      details: 'El email debe tener un formato válido (ejemplo@dominio.com)',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    pool = await sql.connect(config);
    
    // Buscar usuario por email y su propuesta específica por nombre
    const searchRequest = pool.request();
    searchRequest.input('email', sql.NVarChar(100), email.trim().toLowerCase());
    searchRequest.input('proposalName', sql.NVarChar(200), proposalName.trim());
    
    const searchResult = await searchRequest.query(`
      SELECT 
        u.userid,
        u.firstname,
        u.lastname,
        u.email,
        p.proposalid,
        p.title,
        p.statusid,
        p.createdon,
        ps.name as statusName
      FROM PV_Users u
      INNER JOIN PV_Proposals p ON u.userid = p.createdby
      LEFT JOIN PV_ProposalStatus ps ON p.statusid = ps.statusid
      WHERE u.email = @email 
        AND p.title = @proposalName
        AND p.statusid = 2
        AND u.deleted = 0
      ORDER BY p.createdon DESC
    `);

    if (searchResult.recordset.length === 0) {
      return res.status(404).json({
        error: 'Propuesta no encontrada',
        details: `No se encontró propuesta "${proposalName}" para el usuario con email "${email}"`,
        timestamp: new Date().toISOString()
      });
    }

    const userData = searchResult.recordset[0];

    const proposalid = userData.proposalid;

    // Obtener documentos asociados a la propuesta
    const documentosRequest = pool.request();
    documentosRequest.input('proposalid', sql.Int, proposalid);
    
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
    const logsRequest = pool.request();
    logsRequest.input('proposalid', sql.Int, proposalid);
    
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
    `);    
    // Respuesta exitosa con la información de revisión
    return res.status(200).json({
      success: true,
      data: {
        propuesta: {
          proposalid: userData.proposalid,
          title: userData.title,
          statusid: userData.statusid,
          statusName: userData.statusName,
          createdon: userData.createdon,
          createdBy: userData.userid,
          createdByName: `${userData.firstname} ${userData.lastname}`,
          createdByEmail: userData.email
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
          value1: log.value1 ? log.value1.replace(/\r\n/g, '').replace(/\r/g, '').replace(/\n/g, '').replace(/\t/g, '').replace(/    /g, ' ').replace(/,}/g, '}') : null,
          value2: log.value2 ? log.value2.replace(/\r\n/g, '').replace(/\r/g, '').replace(/\n/g, '').replace(/\t/g, '').replace(/    /g, ' ').replace(/,}/g, '}') : null
        })),
        resumen: {
          totalDocumentos: documentosResult.recordset.length,
          documentosAprobados: documentosResult.recordset.filter(doc => doc.aivalidationstatus === 'Approved').length,
          listoParaRevision: documentosResult.recordset.length > 0,
          ultimaActividad: logsResult.recordset.length > 0 ? logsResult.recordset[0].posttime : userData.createdon
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