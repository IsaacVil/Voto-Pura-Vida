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
      return await ejecutarRevisionPropuesta(req, res);    } else if (method === 'GET') {
      // GET: Obtener información de propuesta para revisión
      const { name, createdByName } = req.query;
      return await obtenerInformacionRevision(req, res, name, createdByName);
    
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


//Ejecuta la revisión de propuesta llamando al SP revisarPropuesta

async function ejecutarRevisionPropuesta(req, res) {
  const { name, createdByName } = req.body;

  // Validación básica
  if (!name || !createdByName) {
    return res.status(400).json({
      error: 'Nombre de propuesta y nombre del creador requeridos',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Iniciando revisión de propuesta: ${name} (creado por: ${createdByName})`);

    // Conectar a SQL Server
    pool = await sql.connect(config);

    //Buscar el proposalid usando name y createdByName
    const searchRequest = pool.request();
    searchRequest.input('name', sql.NVarChar(255), name);
    searchRequest.input('createdByName', sql.NVarChar(255), createdByName);
    
    const searchResult = await searchRequest.query(`
      SELECT p.proposalid, p.createdby, u.firstname as creatorName
      FROM PV_Proposals p
      INNER JOIN PV_Users u ON p.createdby = u.userid
      WHERE p.title = @name AND u.firstname = @createdByName
    `);

    if (searchResult.recordset.length === 0) {
      return res.status(404).json({
        error: 'Propuesta no encontrada con los datos proporcionados',
        details: `No se encontró propuesta con nombre "${name}" creada por "${createdByName}"`,
        timestamp: new Date().toISOString()
      });
    }

    const proposalid = searchResult.recordset[0].proposalid;
    const createdby = searchResult.recordset[0].createdby;
    const creatorName = searchResult.recordset[0].creatorName;
    console.log(`Propuesta encontrada: ID ${proposalid}, creada por ${creatorName} (ID: ${createdby})`);

    // Preparar la llamada al stored procedure
    const request = pool.request();
    
    // Agregar parámetros
    request.input('proposalid', sql.Int, proposalid);
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
        proposalId: proposalid,
        proposalName: name,
        createdBy: createdby,
        createdByName: creatorName,
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
      } else if (error.message.includes('no encontrada')) {
        statusCode = 404;
        errorMessage = 'Propuesta no encontrada con los datos proporcionados';
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


 //Obtiene información simplificada de propuesta para revisión

async function obtenerInformacionRevision(req, res, name, createdByName) {
  if (!name || !createdByName) {
    return res.status(400).json({
      error: 'Nombre de propuesta y nombre del creador requeridos',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    pool = await sql.connect(config);    
    const searchRequest = pool.request();
    searchRequest.input('name', sql.NVarChar(255), name);
    searchRequest.input('createdByName', sql.NVarChar(255), createdByName);
    
    const searchResult = await searchRequest.query(`
      SELECT p.proposalid, p.createdby, u.firstname as creatorName
      FROM PV_Proposals p
      INNER JOIN PV_Users u ON p.createdby = u.userid
      WHERE p.title = @name AND u.firstname = @createdByName
    `);

    if (searchResult.recordset.length === 0) {
      return res.status(404).json({
        error: 'Propuesta no encontrada con los datos proporcionados',
        details: `No se encontró propuesta con nombre "${name}" creada por "${createdByName}"`,
        timestamp: new Date().toISOString()
      });
    }

    const proposalid = searchResult.recordset[0].proposalid;
    const createdby = searchResult.recordset[0].createdby;
    const creatorName = searchResult.recordset[0].creatorName;

    const propuestaRequest = pool.request();
    propuestaRequest.input('proposalid', sql.Int, proposalid);
    
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
          proposalid: propuestaResult.recordset[0].proposalid,
          title: propuestaResult.recordset[0].title,
          statusid: propuestaResult.recordset[0].statusid,
          statusName: propuestaResult.recordset[0].statusName,
          createdBy: createdby,
          createdByName: creatorName
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