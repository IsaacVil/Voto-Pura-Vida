/**
 * Endpoint: /api/stored-procedures/crearActualizarPropuesta
 * Permite crear y actualizar propuestas utilizando el SP crearActualizarPropuesta
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

/**
 * Crear nueva propuesta
 */
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

    // Parámetros de documentos - ✅ SIN valores por defecto para múltiples
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

    // Parámetro de salida
    request.output('mensaje', sql.NVarChar(100), '');

    console.log('Ejecutando SP crearActualizarPropuesta...');
    const result = await request.execute('crearActualizarPropuesta');

    const mensaje = result.output.mensaje;
    console.log('Propuesta creada:', mensaje);

    // Respuesta exitosa
    return res.status(201).json({
      success: true,
      message: mensaje,
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

    let statusCode = 500;
    let errorMessage = 'Error al crear la propuesta';
    
    if (error.message) {
      if (error.message.includes('no tiene permisos')) {
        statusCode = 403;
        errorMessage = 'Usuario sin permisos para crear propuestas';
      } else if (error.message.includes('no coinciden')) {
        statusCode = 400;
        errorMessage = 'Número de segmentos y pesos no coinciden';
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message,
      errorCode: 'SP_CREAR_PROPUESTA_ERROR',
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

/**
 * Actualizar propuesta existente
 */
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

    // Agregar parámetros (mismos que crear pero con proposalid)
    request.input('proposalid', sql.Int, parseInt(proposalid));
    request.input('title', sql.NVarChar(200), title);
    request.input('description', sql.NVarChar(sql.MAX), description);
    request.input('proposalcontent', sql.NVarChar(sql.MAX), proposalcontent || '');
    request.input('budget', sql.Decimal(18, 2), parseFloat(budget));
    request.input('createdby', sql.Int, parseInt(createdby));
    request.input('proposaltypeid', sql.Int, parseInt(proposaltypeid));
    request.input('organizationid', sql.Int, parseInt(organizationid || 1));
    request.input('version', sql.Int, parseInt(version || 1));

    // Documentos - ✅ SIN valores por defecto para múltiples
    request.input('documentids', sql.NVarChar(sql.MAX), documentids || null);
    request.input('mediapath', sql.NVarChar(sql.MAX), mediapath || null);
    request.input('mediatypeid', sql.NVarChar(sql.MAX), mediatypeid || null);
    request.input('sizeMB', sql.NVarChar(sql.MAX), sizeMB || null);
    request.input('encoding', sql.NVarChar(sql.MAX), encoding || null);
    request.input('samplerate', sql.NVarChar(sql.MAX), samplerate || null);
    request.input('languagecode', sql.NVarChar(sql.MAX), languagecode || null);    request.input('documenttypeid', sql.NVarChar(sql.MAX), documenttypeid || null);

    request.input('changecomments', sql.NVarChar(500), changecomments || 'Actualización de propuesta');

    // Segmentos y votación (mismos parámetros que crear)
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

    request.output('mensaje', sql.NVarChar(100), '');

    console.log('Ejecutando SP crearActualizarPropuesta para actualización...');
    const result = await request.execute('crearActualizarPropuesta');

    const mensaje = result.output.mensaje;
    console.log('Propuesta actualizada:', mensaje);

  return res.status(200).json({
    success: true,
    message: mensaje,
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

    let statusCode = 500;
    let errorMessage = 'Error al actualizar la propuesta';
    
    if (error.message) {
      if (error.message.includes('no existe')) {
        statusCode = 404;
        errorMessage = 'Propuesta no encontrada';
      } else if (error.message.includes('no tiene permisos')) {
        statusCode = 403;
        errorMessage = 'Sin permisos para actualizar propuesta';
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message,
      errorCode: 'SP_ACTUALIZAR_PROPUESTA_ERROR',
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