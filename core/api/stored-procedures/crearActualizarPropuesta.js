/**
 * ENDPOINT: /api/stored-procedures/crearActualizarPropuesta
 * 
 * DESCRIPCIÓN:
 * API para crear y actualizar propuestas utilizando el stored procedure 'crearActualizarPropuesta'.
 * Este endpoint maneja tanto la creación (POST) como la actualización (PUT) de propuestas de manera unificada.
 * 
 */

const sql = require('mssql');
const { getDbConfig } = require('../../src/config/database');
const config = getDbConfig();

module.exports = async (req, res) => {
  try {
    const { method } = req;

    if (method === 'POST') {
      // POST: Crear nueva propuesta
      return await crearPropuesta(req, res);
    
    } else if (method === 'PUT') {
      // PUT: Actualizar propuesta existente
      return await actualizarPropuesta(req, res);
    
    } else if (method === 'GET') {
      // GET: Obtener información de propuesta
      const { proposalid } = req.query;
      return await obtenerInformacionPropuesta(req, res, proposalid);
    
    } else {
      res.setHeader('Allow', ['GET', 'POST', 'PUT']);
      return res.status(405).json({
        error: `Método ${method} no permitido`,
        allowedMethods: ['GET', 'POST', 'PUT'],
        timestamp: new Date().toISOString()
      });
    }

  } catch (error) {
    console.error('Error en endpoint crearActualizarPropuesta:', error);
    return res.status(500).json({
      error: 'Error interno del servidor',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
};

async function crearPropuesta(req, res) {
  const {
    title,
    description,
    proposalcontent,
    budget,
    createdby,
    proposaltypeid,
    organizationid,
    // Documentos
    mediapath,
    mediatypeid,
    sizeMB,
    encoding,
    samplerate,
    languagecode,
    documenttypeid,  
    // Comentarios
    changecomments,
    // Segmentos
    targetSegments,
    segmentWeights,
    // Votación
    startdate,
    enddate,
    votingtypeid,
    allowweightedvotes,
    requiresallvoters,
    notificationmethodid,
    publisheddate,
    finalizeddate,
    publicvoting
  } = req.body;

  // Validaciones básicas
  const camposRequeridos = {
    title: 'Título',
    description: 'Descripción',
    budget: 'Presupuesto',
    createdby: 'Usuario creador',
    proposaltypeid: 'Tipo de propuesta'
  };

  const errores = [];
  Object.entries(camposRequeridos).forEach(([campo, descripcion]) => {
    if (!req.body[campo]) {
      errores.push(`${descripcion} es requerido`);
    }
  });

  if (budget && (isNaN(budget) || parseFloat(budget) <= 0)) {
    errores.push('El presupuesto debe ser un número positivo');
  }

  if (errores.length > 0) {
    return res.status(400).json({
      error: 'Datos inválidos para crear propuesta',
      details: errores,
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Creando propuesta: ${title} por usuario ${createdby}`);

    pool = await sql.connect(config);
    const request = pool.request();

    // Agregar parámetros al SP
    request.input('proposalid', sql.Int, null); // NULL para crear
    request.input('title', sql.NVarChar(200), title);
    request.input('description', sql.NVarChar(sql.MAX), description);
    request.input('proposalcontent', sql.NVarChar(sql.MAX), proposalcontent || '');
    request.input('budget', sql.Decimal(18, 2), parseFloat(budget));
    request.input('createdby', sql.Int, parseInt(createdby));
    request.input('proposaltypeid', sql.Int, parseInt(proposaltypeid));
    request.input('organizationid', sql.Int, parseInt(organizationid || 1));
    request.input('version', sql.Int, 1);

    // Parámetros de documentos 
    request.input('documentids', sql.NVarChar(sql.MAX), null);
    request.input('mediapath', sql.NVarChar(sql.MAX), mediapath || null);
    request.input('mediatypeid', sql.NVarChar(sql.MAX), mediatypeid || null);
    request.input('sizeMB', sql.NVarChar(sql.MAX), sizeMB || null);
    request.input('encoding', sql.NVarChar(sql.MAX), encoding || null);
    request.input('samplerate', sql.NVarChar(sql.MAX), samplerate || null);
    request.input('languagecode', sql.NVarChar(sql.MAX), languagecode || null);    request.input('documenttypeid', sql.NVarChar(sql.MAX), documenttypeid || null);

    // Comentarios de cambio
    request.input('changecomments', sql.NVarChar(500), changecomments || 'Creación inicial');

    // Segmentos objetivo
    request.input('targetSegments', sql.NVarChar(300), targetSegments || null);
    request.input('segmentWeights', sql.NVarChar(300), segmentWeights || null);

    // Configuración de votación
    request.input('startdate', sql.DateTime, startdate ? new Date(startdate) : new Date());
    request.input('enddate', sql.DateTime, enddate ? new Date(enddate) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)); // 30 días
    request.input('votingtypeid', sql.Int, parseInt(votingtypeid || 1));
    request.input('allowweightedvotes', sql.Bit, allowweightedvotes || false);
    request.input('requiresallvoters', sql.Bit, requiresallvoters || false);
    request.input('notificationmethodid', sql.Int, parseInt(notificationmethodid || 1));
    request.input('publisheddate', sql.DateTime, publisheddate ? new Date(publisheddate) : null);
    request.input('finalizeddate', sql.DateTime, finalizeddate ? new Date(finalizeddate) : null);
    request.input('publicvoting', sql.Bit, publicvoting || true);


    console.log('Ejecutando SP crearActualizarPropuesta...');
    const result = await request.execute('crearActualizarPropuesta');
    
    // Si llegamos aquí, la propuesta se creó exitosamente
    console.log('Propuesta creada exitosamente');

    // Respuesta exitosa - ya no dependemos del mensaje de salida
    return res.status(201).json({
      success: true,
      message: 'Propuesta creada exitosamente',
      data: {
        action: 'created',
        title: title,
        budget: parseFloat(budget),
        createdBy: parseInt(createdby),
        processedAt: new Date(),
        hasDocuments: !!mediapath,
        hasTargetSegments: !!targetSegments
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error ejecutando SP crearActualizarPropuesta:', error);

    // Manejo específico de errores lanzados por RAISERROR del stored procedure
    let statusCode = 500;
    let errorMessage = 'Error al crear la propuesta';
    let errorCode = 'SP_CREAR_PROPUESTA_ERROR';
    
    if (error.message) {
      const errorMsg = error.message.toLowerCase();
      
      // Errores de validación (400 Bad Request)
      if (errorMsg.includes('título es obligatorio') || 
          errorMsg.includes('presupuesto debe ser mayor a 0') ||
          errorMsg.includes('fecha de inicio debe ser mayor a la fecha actual') ||
          errorMsg.includes('fecha de fin debe ser mayor a la fecha de inicio') ||
          errorMsg.includes('número de segmentos objetivo') ||
          errorMsg.includes('pesos no coinciden')) {
        statusCode = 400;
        errorMessage = 'Datos de propuesta inválidos';
        errorCode = 'INVALID_PROPOSAL_DATA';
      }
      // Errores de autorización (403 Forbidden)
      else if (errorMsg.includes('no tiene permisos') || 
               errorMsg.includes('no autorizado')) {
        statusCode = 403;
        errorMessage = 'Usuario sin permisos para crear propuestas';
        errorCode = 'INSUFFICIENT_PERMISSIONS';
      }
      // Errores de recursos no encontrados (404 Not Found)
      else if (errorMsg.includes('usuario no existe') ||
               errorMsg.includes('tipo de votación no existe') ||
               errorMsg.includes('método de notificación no existe')) {
        statusCode = 404;
        errorMessage = 'Recurso requerido no encontrado';
        errorCode = 'RESOURCE_NOT_FOUND';
      }
      // Errores de integridad de datos (409 Conflict)
      else if (errorMsg.includes('ya existe una propuesta') ||
               errorMsg.includes('conflicto de datos')) {
        statusCode = 409;
        errorMessage = 'Conflicto con datos existentes';
        errorCode = 'DATA_CONFLICT';
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
    if (pool) {
      try {
        await pool.close();
      } catch (closeError) {
        console.error('Error cerrando conexión:', closeError);
      }
    }
  }
}

async function actualizarPropuesta(req, res) {
  const {
    proposalid,
    title,
    description,
    proposalcontent,
    budget,
    createdby,
    proposaltypeid,
    organizationid,
    version,
    // Documentos existentes
    documentids,
    mediapath,
    mediatypeid,
    sizeMB,
    encoding,
    samplerate,
    languagecode,
    documenttypeid,  
    // Comentarios
    changecomments,
    // Segmentos
    targetSegments,
    segmentWeights,
    // Votación
    startdate,
    enddate,
    votingtypeid,
    allowweightedvotes,
    requiresallvoters,
    notificationmethodid,
    publisheddate,
    finalizeddate,
    publicvoting
  } = req.body;

  // Validaciones para actualización
  if (!proposalid) {
    return res.status(400).json({
      error: 'ID de propuesta requerido para actualización',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Actualizando propuesta ${proposalid}: ${title}`);

    pool = await sql.connect(config);
    const request = pool.request();

    // Agregar parámetros 
    request.input('proposalid', sql.Int, parseInt(proposalid));
    request.input('title', sql.NVarChar(200), title);
    request.input('description', sql.NVarChar(sql.MAX), description);
    request.input('proposalcontent', sql.NVarChar(sql.MAX), proposalcontent || '');
    request.input('budget', sql.Decimal(18, 2), parseFloat(budget));
    request.input('createdby', sql.Int, parseInt(createdby));
    request.input('proposaltypeid', sql.Int, parseInt(proposaltypeid));
    request.input('organizationid', sql.Int, parseInt(organizationid || 1));
    request.input('version', sql.Int, parseInt(version || 1));

    request.input('documentids', sql.NVarChar(sql.MAX), documentids || null);
    request.input('mediapath', sql.NVarChar(sql.MAX), mediapath || null);
    request.input('mediatypeid', sql.NVarChar(sql.MAX), mediatypeid || null);
    request.input('sizeMB', sql.NVarChar(sql.MAX), sizeMB || null);
    request.input('encoding', sql.NVarChar(sql.MAX), encoding || null);
    request.input('samplerate', sql.NVarChar(sql.MAX), samplerate || null);
    request.input('languagecode', sql.NVarChar(sql.MAX), languagecode || null);    request.input('documenttypeid', sql.NVarChar(sql.MAX), documenttypeid || null);

    request.input('changecomments', sql.NVarChar(500), changecomments || 'Actualización de propuesta');

    request.input('targetSegments', sql.NVarChar(300), targetSegments || null);
    request.input('segmentWeights', sql.NVarChar(300), segmentWeights || null);
    request.input('startdate', sql.DateTime, startdate ? new Date(startdate) : new Date());
    request.input('enddate', sql.DateTime, enddate ? new Date(enddate) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000));
    request.input('votingtypeid', sql.Int, parseInt(votingtypeid || 1));
    request.input('allowweightedvotes', sql.Bit, allowweightedvotes || false);
    request.input('requiresallvoters', sql.Bit, requiresallvoters || false);
    request.input('notificationmethodid', sql.Int, parseInt(notificationmethodid || 1));
    request.input('publisheddate', sql.DateTime, publisheddate ? new Date(publisheddate) : null);
    request.input('finalizeddate', sql.DateTime, finalizeddate ? new Date(finalizeddate) : null);
    request.input('publicvoting', sql.Bit, publicvoting || true);

    // NOTA: Ya no usamos parámetro de salida 'mensaje' - el SP ahora lanza errores directamente
    // Si llega aquí sin excepción, significa que la actualización fue exitosa

    console.log('Ejecutando SP crearActualizarPropuesta para actualización...');
    const result = await request.execute('crearActualizarPropuesta');
    
    // Si llegamos aquí, la propuesta se actualizó exitosamente
    console.log('Propuesta actualizada exitosamente');

  return res.status(200).json({
    success: true,
    message: 'Propuesta actualizada exitosamente',
    data: {
      proposalId: parseInt(proposalid),
      title: title,
      versionUpdated: `v${parseInt(version)} → v${parseInt(version) + 1}`,
      budgetUpdated: `₡${parseFloat(budget).toLocaleString('es-CR')}`,
      
      // Lo que se procesó exitosamente
      processed: {
        documents: documentids ? `${documentids.split(',').length} actualizados` : 'Sin cambios',
        newDocuments: mediapath ? `${mediapath.split(',').length} agregados` : 'Ninguno',
        targetSegments: targetSegments ? `${targetSegments.split(',').length} configurados` : 'Sin segmentos',
        votingPeriod: startdate && enddate ? 
          `${new Date(startdate).toLocaleDateString('es-CR')} - ${new Date(enddate).toLocaleDateString('es-CR')}` : 'No configurado'
      },
      
      // Validaciones que pasaron
      validated: {
        dataIntegrity: true,
        permissionsOK: true,
        businessRules: true,
        workflowExecuted: true
      },
      
      updatedAt: new Date().toLocaleString('es-CR')
    },
    timestamp: new Date().toISOString()
  });

  } catch (error) {
    console.error('Error actualizando propuesta:', error);

    // Manejo específico de errores lanzados por RAISERROR del stored procedure
    let statusCode = 500;
    let errorMessage = 'Error al actualizar la propuesta';
    let errorCode = 'SP_ACTUALIZAR_PROPUESTA_ERROR';
    
    if (error.message) {
      const errorMsg = error.message.toLowerCase();
      
      // Errores de validación (400 Bad Request)
      if (errorMsg.includes('título es obligatorio') || 
          errorMsg.includes('presupuesto debe ser mayor a 0') ||
          errorMsg.includes('fecha de inicio debe ser mayor a la fecha actual') ||
          errorMsg.includes('fecha de fin debe ser mayor a la fecha de inicio') ||
          errorMsg.includes('número de segmentos objetivo') ||
          errorMsg.includes('pesos no coinciden')) {
        statusCode = 400;
        errorMessage = 'Datos de propuesta inválidos';
        errorCode = 'INVALID_PROPOSAL_DATA';
      }
      // Errores de autorización (403 Forbidden)
      else if (errorMsg.includes('no tiene permisos') || 
               errorMsg.includes('no autorizado')) {
        statusCode = 403;
        errorMessage = 'Usuario sin permisos para actualizar propuestas';
        errorCode = 'INSUFFICIENT_PERMISSIONS';
      }
      // Errores de recursos no encontrados (404 Not Found)
      else if (errorMsg.includes('propuesta no existe') ||
               errorMsg.includes('usuario no existe') ||
               errorMsg.includes('tipo de votación no existe') ||
               errorMsg.includes('método de notificación no existe')) {
        statusCode = 404;
        errorMessage = 'Recurso requerido no encontrado';
        errorCode = 'RESOURCE_NOT_FOUND';
      }
      // Errores de integridad de datos (409 Conflict)
      else if (errorMsg.includes('ya existe una propuesta') ||
               errorMsg.includes('conflicto de datos') ||
               errorMsg.includes('versión incorrecta')) {
        statusCode = 409;
        errorMessage = 'Conflicto con datos existentes';
        errorCode = 'DATA_CONFLICT';
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
    if (pool) {
      try {
        await pool.close();
      } catch (closeError) {
        console.error('Error cerrando conexión:', closeError);
      }
    }
  }
}


async function obtenerInformacionPropuesta(req, res, proposalid) {
  if (!proposalid) {
    return res.status(400).json({
      error: 'ID de propuesta requerido',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    pool = await sql.connect(config);

    // Obtener propuesta con versiones
    const propuestaRequest = pool.request();
    propuestaRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const propuestaResult = await propuestaRequest.query(`
      SELECT 
        p.proposalid,
        p.title,
        p.description,
        p.proposalcontent,
        p.budget,
        p.createdby,
        p.createdon,
        p.lastmodified,
        p.proposaltypeid,
        p.statusid,
        p.organizationid,
        p.version,
        ps.name as statusName,
        pt.name as typeName,
        u.firstname + ' ' + u.lastname as createdByName,
        -- Versiones
        (SELECT COUNT(*) FROM PV_ProposalVersions pv WHERE pv.proposalid = p.proposalid) as totalVersions
      FROM PV_Proposals p
      LEFT JOIN PV_ProposalStatus ps ON p.statusid = ps.statusid
      LEFT JOIN PV_ProposalTypes pt ON p.proposaltypeid = pt.proposaltypeid
      LEFT JOIN PV_Users u ON p.createdby = u.userid
      WHERE p.proposalid = @proposalid
    `);

    if (propuestaResult.recordset.length === 0) {
      return res.status(404).json({
        error: 'Propuesta no encontrada',
        timestamp: new Date().toISOString()
      });
    }

    const documentosRequest = pool.request();
    documentosRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const documentosResult = await documentosRequest.query(`
      SELECT 
        d.documentId,
        d.documentTypeId,
        d.aivalidationstatus,
        d.version,
        m.mediapath,
        m.sizeMB,
        m.encoding,
        m.samplerate,
        m.languagecode,
        dt.name as documentTypeName
      FROM PV_ProposalDocuments pd
      JOIN PV_Documents d ON pd.documentId = d.documentId
      LEFT JOIN PV_mediafiles m ON d.mediafileId = m.mediafileid
      LEFT JOIN PV_DocumentTypes dt ON d.documentTypeId = dt.documentTypeId
      WHERE pd.proposalid = @proposalid
    `);

    const votacionRequest = pool.request();
    votacionRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const votacionResult = await votacionRequest.query(`
      SELECT 
        vc.votingconfigid,
        vc.startdate,
        vc.enddate,
        vc.allowweightedvotes,
        vc.requiresallvoters,
        vc.publicVoting,
        vc.statusid as votingStatusId,
        vs.name as votingStatusName
      FROM PV_VotingConfigurations vc
      LEFT JOIN PV_VotingStatus vs ON vc.statusid = vs.statusid
      WHERE vc.proposalid = @proposalid
    `);

    const segmentosRequest = pool.request();
    segmentosRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const segmentosResult = await segmentosRequest.query(`
      SELECT 
        vts.targetsegmentid,
        vts.voteweight,
        ps.name as segmentName,
        ps.description as segmentDescription
      FROM PV_VotingConfigurations vc
      JOIN PV_VotingTargetSegments vts ON vc.votingconfigid = vts.votingconfigid
      JOIN PV_PopulationSegments ps ON vts.segmentid = ps.segmentid
      WHERE vc.proposalid = @proposalid
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
        configuracionVotacion: votacionResult.recordset[0] || null,
        segmentosObjetivo: segmentosResult.recordset,
        reglasValidacion: validationRulesResult.recordset,  
        resumen: {
          totalDocumentos: documentosResult.recordset.length,
          tieneVotacion: votacionResult.recordset.length > 0,
          totalSegmentos: segmentosResult.recordset.length,
          totalReglasValidacion: validationRulesResult.recordset.length 
        }
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error obteniendo información de propuesta:', error);
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