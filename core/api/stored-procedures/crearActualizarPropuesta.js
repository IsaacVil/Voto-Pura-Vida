/**

/**
 * ENDPOINT: /api/stored-procedures/crearActualizarPropuesta
 *
 * DESCRIPCIÓN:
 * API para crear y actualizar propuestas utilizando el stored procedure 'crearActualizarPropuesta'.
 * Este endpoint maneja tanto la creación (POST) como la actualización (PUT) de propuestas de manera unificada. */

const sql = require('mssql');
const { getDbConfig } = require('../../src/config/database');

// Usar la misma configuración que funciona en login.js
const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

module.exports = async (req, res) => {
  try {
    const { method } = req;
    
    // Obtener proposalid del parámetro de ruta o de req.proposalid (establecido por el server.js)
    let proposalid = null;
    
    if (req.proposalid !== undefined) {
      // Viene del server.js
      const proposalIdParam = req.proposalid;
      
      if (proposalIdParam && proposalIdParam !== 'null' && proposalIdParam !== 'undefined' && proposalIdParam !== '0') {
        const parsedId = parseInt(proposalIdParam);
        if (!isNaN(parsedId) && parsedId > 0) {
          proposalid = parsedId;
        }
      }
    } else {
      // Fallback: extraer de la URL como antes
      const urlParts = req.url.split('/');
      const proposalIdParam = urlParts[urlParts.length - 1];
      
      if (proposalIdParam && proposalIdParam !== 'null' && proposalIdParam !== 'undefined' && proposalIdParam !== '0') {
        const parsedId = parseInt(proposalIdParam);
        if (!isNaN(parsedId) && parsedId > 0) {
          proposalid = parsedId;
        }
      }
    }
    
    console.log(`ID recibido: "${req.proposalid || 'desde URL'}" → Procesado como: ${proposalid}`);

    if (method === 'POST') {
      // POST: Crear o actualizar según si proposalid es null o no
      return await crearOActualizarPropuesta(req, res, proposalid);
    
    } else if (method === 'GET') {
      // GET: Obtener información de propuesta
      return await obtenerInformacionPropuesta(req, res, proposalid);
    
    } else {
      res.setHeader('Allow', ['GET', 'POST']);
      return res.status(405).json({
        error: `Método ${method} no permitido`,
        allowedMethods: ['GET', 'POST'],
        ejemplos: {
          crear: 'POST /api/crear-actualizar-propuesta/null',
          actualizar: 'POST /api/crear-actualizar-propuesta/123',
          obtener: 'GET /api/crear-actualizar-propuesta/123'
        },
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
 * Crear o actualizar propuesta según el proposalid
 * Si proposalid es null → CREAR nueva propuesta
 * Si proposalid tiene valor → ACTUALIZAR propuesta existente
 */
async function crearOActualizarPropuesta(req, res, proposalid) {

  // Verificar que el usuario está autenticado
  if (!req.user || !req.user.userId) {
    return res.status(401).json({
      error: 'Usuario no autenticado',
      details: 'El middleware JWT no estableció req.user.userId',
      timestamp: new Date().toISOString()
    });
  }

  // Obtener userid del token JWT (ya verificado por middleware)
  const createdby = req.user.userId;
  const esCreacion = proposalid === null || proposalid === undefined;

  console.log(`Usuario autenticado: ${createdby}, Operación: ${esCreacion ? 'CREAR' : 'ACTUALIZAR'}`);

  let verificationPool;
  try {
    verificationPool = await sql.connect(config);
    
    // Verificar que el usuario existe en PV_Users
    const userCheckRequest = verificationPool.request();
    userCheckRequest.input('userid', sql.Int, parseInt(createdby));
    
    const userExistsResult = await userCheckRequest.query(`
      SELECT userid, firstname, lastname, email, userStatusId
      FROM [dbo].[PV_Users] 
      WHERE userid = @userid
    `);
    
    if (userExistsResult.recordset.length === 0) {
      console.log(`Usuario ${createdby} no existe en la base de datos`);
      return res.status(403).json({
        error: 'Usuario no válido',
        details: `El usuario con ID ${createdby} no existe en la base de datos`,
        solucion: 'Verifique que el token JWT corresponde a un usuario registrado',
        timestamp: new Date().toISOString()
      });
    }
    
    const usuario = userExistsResult.recordset[0];
    console.log(`Usuario válido encontrado: ${usuario.firstname} ${usuario.lastname} (${usuario.email})`);
    
    // Verificar que el usuario está activo
    if (usuario.userStatusId !== 1 && usuario.userStatusId !== 2) { 
      console.log(`Usuario ${createdby} no está activo (status: ${usuario.userStatusId})`);
      return res.status(403).json({
        error: 'Usuario inactivo',
        details: 'Su cuenta no está activa o verificada',
        userStatus: usuario.userStatusId,
        timestamp: new Date().toISOString()
      });
    }
    
  } catch (error) {
    console.error('Error verificando usuario:', error);
    return res.status(500).json({
      error: 'Error interno validando usuario',
      details: error.message,
      configUsada: {
        server: config.server,
        database: config.database,
        user: config.user
      },
      timestamp: new Date().toISOString()
    });
  } finally {
    if (verificationPool) {
      try {
        await verificationPool.close();
      } catch (closeError) {
        console.error('Error cerrando conexión de verificación:', closeError);
      }
    }
  }
  
  const {
    title,
    description,
    proposalcontent,
    budget,
    percentageRequested, 
    proposaltype, 
    organizationid,
    version,
    // Documentos existentes (solo para actualización)
    documentids,
    // Documentos nuevos
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

  const proposalTypeMap = {
    'infraestructura': 1,
    'educacion': 2,
    'infraestructura-tecnologica': 3,
    'desarrollo-social': 4,
    'sostenibilidad-ambiental': 5,
    'educacion-capacitacion': 6,
    'salud-publica': 7,
    'transporte-infraestructura': 8,
    'innovacion-empresarial': 9,
    'cultura-recreacion': 10
  };

  // Validaciones básicas 
  const camposRequeridos = {
    title: 'Título',
    description: 'Descripción',
    budget: 'Presupuesto',
    proposaltype: 'Tipo de propuesta'
  };

  // Validaciones adicionales para actualización
  if (!esCreacion && (!proposalid || proposalid <= 0)) {
    return res.status(400).json({
      error: 'ID de propuesta inválido para actualización',
      detalles: `ID recibido: ${proposalid}. Para crear use: /null, /0. Para actualizar use: /123`,
      ejemplos: {
        crear: '/api/crear-actualizar-propuesta/null',
        actualizar: '/api/crear-actualizar-propuesta/123'
      },
      timestamp: new Date().toISOString()
    });
  }

  const errores = [];
  Object.entries(camposRequeridos).forEach(([campo, descripcion]) => {
    if (!req.body[campo]) {
      errores.push(`${descripcion} es requerido`);
    }
  });

  // Validar que el tipo de propuesta existe
  if (proposaltype && !proposalTypeMap[proposaltype.toLowerCase()]) {
    errores.push(`Tipo de propuesta inválido. Tipos válidos: ${Object.keys(proposalTypeMap).join(', ')}`);
  }

  if (budget && (isNaN(budget) || parseFloat(budget) <= 0)) {
    errores.push('El presupuesto debe ser un número positivo');
  }

  if (errores.length > 0) {
    return res.status(400).json({
      error: `Datos inválidos para ${esCreacion ? 'crear' : 'actualizar'} propuesta`,
      details: errores,
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    //Obtener el ID del tipo de propuesta mapeado
    const proposaltypeid = proposalTypeMap[proposaltype.toLowerCase()];
    
    console.log(`${esCreacion ? 'Creando' : 'Actualizando'} propuesta: ${title} por usuario ${createdby}, tipo: ${proposaltype} (ID: ${proposaltypeid})`);
    if (!esCreacion) {
      console.log(`ID de propuesta a actualizar: ${proposalid}`);
    }

    pool = await sql.connect(config);
    const request = pool.request();

    // Agregar parámetros al SP
    request.input('proposalid', sql.Int, proposalid); 
    request.input('title', sql.NVarChar(200), title);
    request.input('description', sql.NVarChar(sql.MAX), description);
    request.input('proposalcontent', sql.NVarChar(sql.MAX), proposalcontent || '');
    request.input('budget', sql.Decimal(18, 2), parseFloat(budget));
    request.input('percentageRequested', sql.Decimal(12, 8), percentageRequested ? parseFloat(percentageRequested) : null);
    request.input('createdby', sql.Int, parseInt(createdby));
    request.input('proposaltypeid', sql.Int, parseInt(proposaltypeid));
    request.input('organizationid', sql.Int, parseInt(organizationid || 1));
    request.input('version', sql.Int, parseInt(version || 1));

    // Parámetros de documentos
    request.input('documentids', sql.NVarChar(sql.MAX), documentids || null);
    request.input('mediapath', sql.NVarChar(sql.MAX), mediapath || null);
    request.input('mediatypeid', sql.NVarChar(sql.MAX), mediatypeid || null);
    request.input('sizeMB', sql.NVarChar(sql.MAX), sizeMB || null);
    request.input('encoding', sql.NVarChar(sql.MAX), encoding || null);
    request.input('samplerate', sql.NVarChar(sql.MAX), samplerate || null);
    request.input('languagecode', sql.NVarChar(sql.MAX), languagecode || null);    
    request.input('documenttypeid', sql.NVarChar(sql.MAX), documenttypeid || null);

    // Comentarios de cambio
    request.input('changecomments', sql.NVarChar(500), 
      changecomments || (esCreacion ? 'Creación inicial' : 'Actualización de propuesta'));

    // Segmentos objetivo
    request.input('targetSegments', sql.NVarChar(300), targetSegments || null);
    request.input('segmentWeights', sql.NVarChar(300), segmentWeights || null);

    if (!esCreacion) {
      request.input('startdate', sql.DateTime, startdate ? new Date(startdate) : new Date());
      request.input('enddate', sql.DateTime, enddate ? new Date(enddate) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000));
      request.input('votingtypeid', sql.Int, parseInt(votingtypeid || 1));
      request.input('allowweightedvotes', sql.Bit, allowweightedvotes || false);
      request.input('requiresallvoters', sql.Bit, requiresallvoters || false);
      request.input('notificationmethodid', sql.Int, parseInt(notificationmethodid || 1));
      request.input('publisheddate', sql.DateTime, publisheddate ? new Date(publisheddate) : null);
      request.input('finalizeddate', sql.DateTime, finalizeddate ? new Date(finalizeddate) : null);
      request.input('publicvoting', sql.Bit, publicvoting || true);
    }

    // Parámetros de salida
    request.output('mensaje', sql.NVarChar(100), '');
    request.output('proposalIdCreated', sql.Int, null);

    console.log('Ejecutando SP crearActualizarPropuesta...');
    const result = await request.execute('crearActualizarPropuesta');

    const mensaje = result.output.mensaje;
    const proposalIdCreated = result.output.proposalIdCreated;
    
    console.log(`Propuesta ${esCreacion ? 'creada' : 'actualizada'}:`, mensaje);
    console.log(`ID de propuesta devuelto por SP: ${proposalIdCreated}`);

    if (mensaje && (
      mensaje.toLowerCase().includes('error') ||
      mensaje.toLowerCase().includes('permisos') ||
      mensaje.toLowerCase().includes('no tiene') ||
      mensaje.toLowerCase().includes('fallido') ||
      mensaje.toLowerCase().includes('failed')
    )) {
      console.log('El SP devolvió un mensaje de error:', mensaje);
      return res.status(403).json({
        success: false,
        error: 'Error del stored procedure',
        message: mensaje,
        details: 'El stored procedure reportó un problema con la operación',
        solucion: 'Verifique los permisos del usuario o los datos enviados',
        timestamp: new Date().toISOString()
      });
    }

    // Respuesta exitosa solo si no hay errores
    const finalProposalId = esCreacion ? proposalIdCreated : proposalid;
    
    return res.status(esCreacion ? 201 : 200).json({
      success: true,
      message: 'Propuesta creada exitosamente',
      data: {
        action: esCreacion ? 'created' : 'updated',
        proposalId: finalProposalId, 
        title: title,
        proposalType: proposaltype,
        proposalTypeId: proposaltypeid,
        budget: parseFloat(budget),
        percentageRequested: percentageRequested ? parseFloat(percentageRequested) : null,
        createdBy: parseInt(createdby),
        version: esCreacion ? 1 : parseInt(version || 1),
        processedAt: new Date(),
        hasDocuments: !!mediapath || !!documentids,
        hasTargetSegments: !!targetSegments
      },
      debug: {
        inputProposalId: proposalid,
        outputProposalId: proposalIdCreated,
        wasCreation: esCreacion
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error(`Error ejecutando SP crearActualizarPropuesta (${esCreacion ? 'crear' : 'actualizar'}):`, error);

    // Manejo específico de errores lanzados por RAISERROR del stored procedure
    let statusCode = 500;
    let errorMessage = `Error al ${esCreacion ? 'crear' : 'actualizar'} la propuesta`;
    
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
        errorMessage = `Usuario sin permisos para ${esCreacion ? 'crear' : 'actualizar'} propuestas`;
      } else if (error.message.includes('no coinciden')) {
        statusCode = 400;
        errorMessage = 'Número de segmentos y pesos no coinciden';
      } else if (error.message.includes('no existe') && !esCreacion) {
        statusCode = 404;
        errorMessage = 'Propuesta no encontrada para actualizar';
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message,
      errorCode: `SP_${esCreacion ? 'CREAR' : 'ACTUALIZAR'}_PROPUESTA_ERROR`,
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
      FROM PV_n vc
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