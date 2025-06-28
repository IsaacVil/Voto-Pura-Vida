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

require('dotenv').config();
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_firmar_tokens';

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
      WHERE userid = @userid
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
    // Solo permitir POST para revisión de propuesta
    if (req.method !== 'POST') {
      res.setHeader('Allow', ['POST']);
      return res.status(405).json({
        error: `Método ${req.method} no permitido`,
        allowedMethods: ['POST'],
        timestamp: new Date().toISOString()
      });
    }
    // Ejecutar revisión de propuesta usando el SP
    return await ejecutarRevisionPropuesta(req, res);
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
  const { proposalId } = req.body;

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

  // Validación básica del id de propuesta
  if (!proposalId) {
    return res.status(400).json({
      error: 'ID de la propuesta es requerido',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Iniciando revisión de propuesta: ${proposalId} para usuario: ${email}`);
    console.log('Parámetros enviados al SP:', {
      email: email,
      emailNormalized: email.trim().toLowerCase(),
      proposalId: proposalId
    });

    // Conectar a SQL Server
    pool = await sql.connect(config);

    // Preparar la llamada al stored procedure
    const request = pool.request();
    request.input('proposalid', sql.Int, proposalId);
    // Agregar parámetro de salida @mensaje
    request.output('mensaje', sql.NVarChar(200));
    // El SP requiere proposalid y mensaje

    console.log('Parámetros finales para SP:', {
      proposalId: proposalId
    });

    // Ejecutar el stored procedure
    const result = await request.execute('revisarPropuesta');
    const mensaje = result.output.mensaje;

    // Si llegamos aquí, la propuesta fue revisada y aprobada exitosamente
    console.log('Revisión de propuesta completada exitosamente');

    // Respuesta exitosa - la propuesta fue aprobada y publicada
    return res.status(200).json({
      success: true,
      message: mensaje || 'Propuesta revisada y aprobada exitosamente',
      data: {
        userEmail: email,
        proposalId: proposalId,
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
      if (errorMsg.includes('id de la propuesta es requerido')) {
        statusCode = 400;
        errorMessage = 'ID de la propuesta es requerido';
        errorCode = 'PROPOSAL_ID_REQUIRED';
        diagnosticInfo = { step: 'validacion_proposal_id', data: { proposalId } };
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
        errorMessage = `No se encontró propuesta pendiente con ID ${proposalId} para usuario ${email}`;
        errorCode = 'PROPOSAL_NOT_FOUND';
        diagnosticInfo = { 
          step: 'buscar_propuesta', 
          data: { email, proposalId },
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
          suggestion: 'Verificar que existan usuarios con roleid=2, enabled=1 y userStatus activo'
        };
      }
      else if (errorMsg.includes('propuesta sin documentos')) {
        statusCode = 422;
        errorMessage = 'La propuesta no tiene documentos para revisar';
        errorCode = 'NO_DOCUMENTS';
        diagnosticInfo = { 
          step: 'verificar_documentos', 
          data: { proposalId },
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
          data: { proposalId },
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
        proposalId: proposalId,
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