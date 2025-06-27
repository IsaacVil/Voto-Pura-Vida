/**
 * ENDPOINT: /api/stored-procedures/revisarPropuesta
 * 
 * DESCRIPCIÓN:
 * API para revisar propuestas utilizando el stored procedure 'revisarPropuesta'.
 */

const sql = require('mssql');
const jwt = require('jsonwebtoken');
const { getDbConfig } = require('../../src/config/database');
const config = getDbConfig();

const JWT_SECRET = 'supersecreto_para_firmar_tokens';

// Función para extraer userid del JWT y obtener email del usuario
async function getUserDataFromJWT(req) {
  // Extraer JWT del header Authorization
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('No se encontró el token de autenticación en los headers.');
  }
  
  const token = authHeader.split(' ')[1];
  const decoded = jwt.verify(token, JWT_SECRET);
  const userid = decoded.sub || decoded.userid || decoded.userId || decoded.id;
  
  if (!userid) {
    throw new Error('El token no contiene userid.');
  }

  // Obtener email del usuario desde la base de datos
  const pool = await sql.connect(config);
  try {
    const userRequest = pool.request();
    userRequest.input('userid', sql.Int, userid);
    
    const userResult = await userRequest.query(`
      SELECT email, firstname, lastname
      FROM PV_Users 
      WHERE userid = @userid AND deleted = 0
    `);

    if (userResult.recordset.length === 0) {
      throw new Error(`No se encontró usuario con ID: ${userid}`);
    }

    const userData = userResult.recordset[0];
    return {
      userid: userid,
      email: userData.email,
      firstname: userData.firstname,
      lastname: userData.lastname
    };
  } finally {
    await pool.close();
  }
}

module.exports = async (req, res) => {
  try {
    const { method } = req;

    if (method === 'POST') {
      // POST: Ejecutar revisión de propuesta usando el SP
      return await ejecutarRevisionPropuesta(req, res);
    
    } else if (method === 'GET') {
      // GET: Obtener información de propuesta para revisión
      return await obtenerInformacionRevision(req, res);
    
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
  const { proposalName } = req.body;

  // Obtener datos del usuario desde el JWT
  let userData;
  try {
    userData = await getUserDataFromJWT(req);
  } catch (err) {
    return res.status(401).json({ 
      error: 'Token inválido o expirado.', 
      details: err.message,
      timestamp: new Date().toISOString()
    });
  }

  const { email, userid } = userData;

  // Validación básica del nombre de propuesta
  if (!proposalName) {
    return res.status(400).json({
      error: 'Nombre de la propuesta es requerido',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Iniciando revisión de propuesta: ${proposalName} para usuario: ${email}`);
    console.log('Parámetros enviados al SP:', {
      email: email,
      emailNormalized: email.trim().toLowerCase(),
      proposalName: proposalName,
      proposalNameTrimmed: proposalName.trim()
    });

    // Conectar a SQL Server
    pool = await sql.connect(config);

    // Preparar la llamada al stored procedure
    const request = pool.request();
    
    // Agregar parámetros email y nombre de propuesta
    const emailParam = email.trim().toLowerCase();
    const proposalParam = proposalName.trim();
    
    request.input('email', sql.NVarChar(100), emailParam);
    request.input('proposalName', sql.NVarChar(200), proposalParam);

    console.log('Parámetros finales para SP:', {
      email: emailParam,
      proposalName: proposalParam
    });

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
    console.error('Error completo:', {
      message: error.message,
      code: error.code,
      number: error.number,
      state: error.state,
      severity: error.severity,
      procedure: error.procedure,
      line: error.line
    });

    // Manejo específico de errores lanzados por RAISERROR del stored procedure
    let statusCode = 500;
    let errorMessage = 'Error al revisar la propuesta';
    let errorCode = 'SP_REVISION_ERROR';
    let diagnosticInfo = {};
    
    if (error.message) {
      const errorMsg = error.message.toLowerCase();
      
      // Errores específicos del SP con mensajes detallados
      if (errorMsg.includes('email es requerido')) {
        statusCode = 400;
        errorMessage = 'Email es requerido para identificar al usuario';
        errorCode = 'EMAIL_REQUIRED';
        diagnosticInfo = { step: 'validacion_email', data: { email } };
      }
      else if (errorMsg.includes('nombre de la propuesta es requerido')) {
        statusCode = 400;
        errorMessage = 'Nombre de la propuesta es requerido';
        errorCode = 'PROPOSAL_NAME_REQUIRED';
        diagnosticInfo = { step: 'validacion_proposal_name', data: { proposalName } };
      }
      else if (errorMsg.includes('no se encontró usuario')) {
        statusCode = 404;
        errorMessage = `No se encontró usuario activo y verificado con email: ${email}`;
        errorCode = 'USER_NOT_FOUND';
        diagnosticInfo = { 
          step: 'buscar_usuario', 
          data: { email, searchedEmail: email.trim().toLowerCase() },
          suggestion: 'Verificar que el usuario exista en PV_Users y tenga userStatus activo=1 y verified=1'
        };
      }
      else if (errorMsg.includes('no se encontró propuesta pendiente')) {
        statusCode = 404;
        errorMessage = `No se encontró propuesta pendiente "${proposalName}" para usuario ${email}`;
        errorCode = 'PROPOSAL_NOT_FOUND';
        diagnosticInfo = { 
          step: 'buscar_propuesta', 
          data: { email, proposalName },
          suggestion: 'Verificar que la propuesta exista, tenga statusid=2 (pendiente) y pertenezca al usuario'
        };
      }
      else if (errorMsg.includes('no se encontró reviewer')) {
        statusCode = 500;
        errorMessage = 'No hay revisores disponibles en el sistema';
        errorCode = 'NO_REVIEWERS_AVAILABLE';
        diagnosticInfo = { 
          step: 'buscar_reviewer', 
          data: { requiredRole: 2 },
          suggestion: 'Verificar que existan usuarios con roleid=2, enabled=1, deleted=0 y userStatus activo'
        };
      }
      else if (errorMsg.includes('propuesta sin documentos')) {
        statusCode = 422;
        errorMessage = 'La propuesta no tiene documentos para revisar';
        errorCode = 'NO_DOCUMENTS';
        diagnosticInfo = { 
          step: 'verificar_documentos', 
          data: { proposalName },
          suggestion: 'La propuesta debe tener documentos en PV_ProposalDocuments'
        };
      }
      else if (errorMsg.includes('propuesta requiere revisión') || 
               errorMsg.includes('no cumple todos los criterios')) {
        statusCode = 409;
        errorMessage = 'La propuesta no cumple todos los criterios de aprobación automática';
        errorCode = 'PROPOSAL_REVIEW_REQUIRED';
        diagnosticInfo = { 
          step: 'evaluacion_final', 
          data: { proposalName },
          suggestion: 'La propuesta necesita revisión manual adicional'
        };
      }
      else if (errorMsg.includes('workflow no configurado')) {
        statusCode = 422;
        errorMessage = 'Workflow no configurado correctamente en el sistema';
        errorCode = 'WORKFLOW_NOT_CONFIGURED';
        diagnosticInfo = { 
          step: 'verificar_workflow', 
          suggestion: 'Verificar que existan workflows configurados en PV_Workflows'
        };
      }
      // Error genérico pero con información adicional
      else {
        errorMessage = error.message || 'Error desconocido en el stored procedure';
        diagnosticInfo = { 
          step: 'ejecucion_sp', 
          sqlError: {
            number: error.number,
            severity: error.severity,
            state: error.state,
            procedure: error.procedure,
            line: error.line
          }
        };
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message || 'Sin detalles específicos del error',
      errorCode: errorCode,
      diagnostic: diagnosticInfo,
      requestData: {
        email: email,
        proposalName: proposalName,
        emailNormalized: email ? email.trim().toLowerCase() : null
      },
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

async function obtenerInformacionRevision(req, res) {
  const { proposalName } = req.query;

  // Obtener datos del usuario desde el JWT
  let userData;
  try {
    userData = await getUserDataFromJWT(req);
  } catch (err) {
    return res.status(401).json({ 
      error: 'Token inválido o expirado.', 
      details: err.message,
      timestamp: new Date().toISOString()
    });
  }

  const { email, userid } = userData;

  if (!proposalName) {
    return res.status(400).json({
      error: 'Nombre de la propuesta es requerido',
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

    const proposalData = searchResult.recordset[0];

    const proposalid = proposalData.proposalid;

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
          proposalid: proposalData.proposalid,
          title: proposalData.title,
          statusid: proposalData.statusid,
          statusName: proposalData.statusName,
          createdon: proposalData.createdon,
          createdBy: proposalData.userid,
          createdByName: `${proposalData.firstname} ${proposalData.lastname}`,
          createdByEmail: proposalData.email
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
          ultimaActividad: logsResult.recordset.length > 0 ? logsResult.recordset[0].posttime : proposalData.createdon
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