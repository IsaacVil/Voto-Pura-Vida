
const { prisma, handlePrismaError, executeTransaction } = require('../../src/config/prisma');
const crypto = require('crypto');

module.exports = async (req, res) => {
  try {
    const { method } = req;

    if (method === 'GET') {
      // GET: Obtener configuración existente o datos para configurar
      const { proposalid, type } = req.query;

      if (!proposalid) {
        return res.status(400).json({
          error: 'ID de propuesta requerido',
          timestamp: new Date().toISOString()
        });
      }

      try {
        if (type === 'configuration') {
          // Obtener configuración existente de votación
          const config = await obtenerConfiguracionVotacion(parseInt(proposalid));
          return res.status(200).json({
            success: true,
            data: config,
            timestamp: new Date().toISOString()
          });
        } else if (type === 'setup-data') {
          // Obtener datos necesarios para configurar votación
          const setupData = await obtenerDatosConfiguracion()
          return res.status(200).json({
            success: true,
            data: setupData,
            timestamp: new Date().toISOString()
          });
        } else {
          return res.status(400).json({
            error: 'Tipo de consulta no válido. Use "configuration" o "setup-data"',
            timestamp: new Date().toISOString()
          });
        }
      } catch (error) {
        console.error('Error en GET configurarVotacion:', error);
        return res.status(500).json({
          error: 'Error interno del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }

    if (method === 'POST') {
      // POST: Crear nueva configuración de votación
      const configuracionData = req.body;

      // Validar estructura de datos requerida
      const validacion = validarEstructuraConfiguracion(configuracionData);
      if (!validacion.valida) {
        return res.status(400).json({
          error: 'Datos de configuración inválidos',
          details: validacion.errores,
          timestamp: new Date().toISOString()
        });
      }

      try {
        // Ejecutar configuración en transacción
        const resultado = await executeTransaction(async (prismaClient) => {
          return await configurarVotacionCompleta(prismaClient, configuracionData);
        });

        if (!resultado.success) {
          return res.status(400).json({
            error: resultado.error,
            details: resultado.details,
            timestamp: new Date().toISOString()
          });
        }

        // Registrar en logs de auditoría
        await registrarLogConfiguracion(
          configuracionData.userid,
          resultado.data.votingconfigid,
          'VOTACION_CONFIGURADA',
          configuracionData
        );

        return res.status(201).json({
          success: true,
          message: 'Configuración de votación creada exitosamente',
          data: resultado.data,
          timestamp: new Date().toISOString()
        });

      } catch (error) {
        console.error('Error en POST configurarVotacion:', error);
        return res.status(500).json({
          error: 'Error interno del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }

    if (method === 'PUT') {
      // PUT: Actualizar configuración existente (solo si no ha iniciado la votación)
      const configuracionData = req.body;
      const { votingconfigid } = req.query;

      if (!votingconfigid) {
        return res.status(400).json({
          error: 'ID de configuración de votación requerido',
          timestamp: new Date().toISOString()
        });
      }

      try {
        // Verificar si se puede actualizar
        const puedeActualizar = await verificarActualizacionPermitida(parseInt(votingconfigid));
        if (!puedeActualizar.permitida) {
          return res.status(403).json({
            error: 'No se puede actualizar la configuración',
            details: puedeActualizar.razon,
            timestamp: new Date().toISOString()
          });
        }

        // Validar estructura de datos
        const validacion = validarEstructuraConfiguracion(configuracionData);
        if (!validacion.valida) {
          return res.status(400).json({
            error: 'Datos de configuración inválidos',
            details: validacion.errores,
            timestamp: new Date().toISOString()
          });
        }

        // Ejecutar actualización en transacción
        const resultado = await executeTransaction(async (prismaClient) => {
          return await actualizarConfiguracionVotacion(
            prismaClient, 
            parseInt(votingconfigid), 
            configuracionData
          );
        });

        if (!resultado.success) {
          return res.status(400).json({
            error: resultado.error,
            details: resultado.details,
            timestamp: new Date().toISOString()
          });
        }

        // Registrar en logs de auditoría
        await registrarLogConfiguracion(
          configuracionData.userid,
          parseInt(votingconfigid),
          'VOTACION_ACTUALIZADA',
          configuracionData
        );

        return res.status(200).json({
          success: true,
          message: 'Configuración de votación actualizada exitosamente',
          data: resultado.data,
          timestamp: new Date().toISOString()
        });

      } catch (error) {
        console.error('Error en PUT configurarVotacion:', error);
        return res.status(500).json({
          error: 'Error interno del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }

    if (method === 'DELETE') {
      // DELETE: Eliminar configuración (solo si no ha iniciado la votación)
      const { votingconfigid } = req.query;

      if (!votingconfigid) {
        return res.status(400).json({
          error: 'ID de configuración de votación requerido',
          timestamp: new Date().toISOString()
        });
      }

      try {
        // Verificar si se puede eliminar
        const puedeEliminar = await verificarEliminacionPermitida(parseInt(votingconfigid));
        if (!puedeEliminar.permitida) {
          return res.status(403).json({
            error: 'No se puede eliminar la configuración',
            details: puedeEliminar.razon,
            timestamp: new Date().toISOString()
          });
        }

        // Ejecutar eliminación en transacción
        const resultado = await executeTransaction(async (prismaClient) => {
          return await eliminarConfiguracionVotacion(prismaClient, parseInt(votingconfigid));
        });

        if (!resultado.success) {
          return res.status(400).json({
            error: resultado.error,
            details: resultado.details,
            timestamp: new Date().toISOString()
          });
        }

        // Registrar en logs de auditoría
        await registrarLogConfiguracion(
          req.user?.userid || 0,
          parseInt(votingconfigid),
          'VOTACION_ELIMINADA',
          { votingconfigid }
        );

        return res.status(200).json({
          success: true,
          message: 'Configuración de votación eliminada exitosamente',
          timestamp: new Date().toISOString()
        });

      } catch (error) {
        console.error('Error en DELETE configurarVotacion:', error);
        return res.status(500).json({
          error: 'Error interno del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }

    // Método no permitido
    return res.status(405).json({
      error: `Método ${method} no permitido`,
      allowedMethods: ['GET', 'POST', 'PUT', 'DELETE'],
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error general en configurarVotacion:', error);
    return res.status(500).json({
      error: 'Error interno del servidor',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Obtiene la configuración existente de votación para una propuesta
 */
async function obtenerConfiguracionVotacion(proposalid) {
  try {
    const configuracion = await prisma.PV_VotingConfigurations.findFirst({
      where: { proposalid },
      include: {
        PV_Proposals: {
          select: {
            proposalid: true,
            title: true,
            description: true,
            statusid: true
          }
        },
        PV_VotingStatus: {
          select: {
            statusid: true,
            name: true,
            description: true
          }
        },
        PV_VotingTypes: {
          select: {
            votingTypeId: true,
            name: true
          }
        },
        PV_NotificationMethods: {
          select: {
            notificationmethodid: true,
            name: true,
            description: true
          }
        },
        PV_VotingTargetSegments: {
          include: {
            PV_PopulationSegments: {
              include: {
                PV_SegmentTypes: true
              }
            }
          }
        },
        PV_VotingOptions: {
          include: {
            PV_VotingQuestions: {
              include: {
                PV_questionType: true
              }
            },
            PV_mediafiles: true
          },
          orderBy: {
            optionorder: 'asc'
          }
        }
      }
    });

    if (!configuracion) {
      return null;
    }    // Estructurar datos para respuesta
    return {
      configuracion: {
        votingconfigid: configuracion.votingconfigid,
        proposalid: configuracion.proposalid,
        startdate: configuracion.startdate,
        enddate: configuracion.enddate,
        votingtypeId: configuracion.votingtypeId,
        allowweightedvotes: configuracion.allowweightedvotes,
        requiresallvoters: configuracion.requiresallvoters,
        notificationmethodid: configuracion.notificationmethodid,
        publicVoting: configuracion.publicVoting,
        statusid: configuracion.statusid,
        configureddate: configuracion.configureddate,
        publisheddate: configuracion.publisheddate,
        finalizeddate: configuracion.finalizeddate,
        checksum: configuracion.checksum ? configuracion.checksum.toString('hex') : null
      },
      propuesta: configuracion.PV_Proposals,
      estado: configuracion.PV_VotingStatus,
      tipoVotacion: configuracion.PV_VotingTypes,
      metodoNotificacion: configuracion.PV_NotificationMethods,
      segmentosObjetivo: configuracion.PV_VotingTargetSegments.map(ts => ({
        targetsegmentid: ts.targetsegmentid,
        voteweight: ts.voteweight,
        assigneddate: ts.assigneddate,
        segmento: {
          segmentid: ts.PV_PopulationSegments.segmentid,
          name: ts.PV_PopulationSegments.name,
          description: ts.PV_PopulationSegments.description,
          tipo: ts.PV_PopulationSegments.PV_SegmentTypes
        }
      })),
      opciones: configuracion.PV_VotingOptions.map(option => ({
        optionid: option.optionid,
        optiontext: option.optiontext,
        optionorder: option.optionorder,
        mediafileId: option.mediafileId,
        checksum: option.checksum ? option.checksum.toString('hex') : null,
        pregunta: {
          ...option.PV_VotingQuestions,
          checksum: option.PV_VotingQuestions.checksum ? option.PV_VotingQuestions.checksum.toString('hex') : null
        },
        mediafile: option.PV_mediafiles
      }))
    };

  } catch (error) {
    console.error('Error al obtener configuración de votación:', error);
    throw error;
  }
}

/**
 * Obtiene los datos necesarios para configurar una votación
 */
async function obtenerDatosConfiguracion() {
  try {
    const [
      tiposVotacion,
      estadosVotacion,
      metodosNotificacion,
      segmentosPoblacion,
      tiposSegmento,
      tiposPregunta
    ] = await Promise.all([
      prisma.PV_VotingTypes.findMany({
        orderBy: { name: 'asc' }
      }),
      prisma.PV_VotingStatus.findMany({
        orderBy: { name: 'asc' }
      }),
      prisma.PV_NotificationMethods.findMany({
        orderBy: { name: 'asc' }
      }),
      prisma.PV_PopulationSegments.findMany({
        include: {
          PV_SegmentTypes: true
        },
        orderBy: { name: 'asc' }
      }),
      prisma.PV_SegmentTypes.findMany({
        orderBy: { name: 'asc' }
      }),
      prisma.PV_questionType.findMany({
        orderBy: { type: 'asc' }
      })
    ]);

    return {
      tiposVotacion,
      estadosVotacion,
      metodosNotificacion,
      segmentosPoblacion,
      tiposSegmento,
      tiposPregunta
    };

  } catch (error) {
    console.error('Error al obtener datos de configuración:', error);
    throw error;
  }
}

/**
 * Valida la estructura de datos de configuración
 */
function validarEstructuraConfiguracion(data) {
  const errores = [];

  // Validaciones básicas requeridas
  if (!data.proposalid) {
    errores.push('ID de propuesta requerido');
  }

  if (!data.userid) {
    errores.push('ID de usuario requerido');
  }

  if (!data.startdate) {
    errores.push('Fecha de inicio requerida');
  }

  if (!data.enddate) {
    errores.push('Fecha de fin requerida');
  }

  if (!data.votingtypeId) {
    errores.push('Tipo de votación requerido');
  }

  // Validar fechas
  if (data.startdate && data.enddate) {
    const startDate = new Date(data.startdate);
    const endDate = new Date(data.enddate);
    const now = new Date();

    if (startDate <= now) {
      errores.push('La fecha de inicio debe ser futura');
    }

    if (endDate <= startDate) {
      errores.push('La fecha de fin debe ser posterior a la fecha de inicio');
    }
  }

  // Validar opciones de votación
  if (!data.opciones || !Array.isArray(data.opciones) || data.opciones.length < 2) {
    errores.push('Se requieren al menos 2 opciones de votación');
  }

  // Validar preguntas
  if (!data.preguntas || !Array.isArray(data.preguntas) || data.preguntas.length === 0) {
    errores.push('Se requiere al menos una pregunta');
  }

  // Validar restricciones de IP si están presentes
  if (data.allowedIPs) {
    if (!Array.isArray(data.allowedIPs)) {
      errores.push('IPs permitidas debe ser un array');
    } else {
      const invalidIPs = data.allowedIPs.filter(ip => !validarFormatoIP(ip));
      if (invalidIPs.length > 0) {
        errores.push(`IPs inválidas: ${invalidIPs.join(', ')}`);
      }
    }
  }

  if (data.restrictedIPs) {
    if (!Array.isArray(data.restrictedIPs)) {
      errores.push('IPs restringidas debe ser un array');
    } else {
      const invalidIPs = data.restrictedIPs.filter(ip => !validarFormatoIP(ip));
      if (invalidIPs.length > 0) {
        errores.push(`IPs inválidas: ${invalidIPs.join(', ')}`);
      }
    }
  }

  // Validar horarios de acceso si están presentes
  if (data.accessSchedule) {
    const horarios = data.accessSchedule;
    if (!horarios.startTime || !horarios.endTime) {
      errores.push('Horario de acceso debe incluir hora de inicio y fin');
    }
    
    if (horarios.daysOfWeek && !Array.isArray(horarios.daysOfWeek)) {
      errores.push('Días de la semana debe ser un array');
    }
  }

  // Validar turnos si están presentes
  if (data.votingShifts && Array.isArray(data.votingShifts)) {
    for (const turno of data.votingShifts) {
      if (!turno.name || !turno.startTime || !turno.endTime) {
        errores.push('Cada turno debe tener nombre, hora de inicio y fin');
      }
    }
  }

  return {
    valida: errores.length === 0,
    errores
  };
}

/**
 * Validar formato de IP (IPv4 y IPv6 básico)
 */
function validarFormatoIP(ip) {
  // Validación IPv4
  const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
  
  // Validación IPv6 (básica)
  const ipv6Regex = /^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$/;
  
  // Validación CIDR
  const cidrRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/(?:3[0-2]|[1-2]?[0-9])$/;
  
  return ipv4Regex.test(ip) || ipv6Regex.test(ip) || cidrRegex.test(ip);
}

/**
 * Configura una votación completa en transacción
 */
async function configurarVotacionCompleta(prismaClient, data) {
  try {
    // 1. Verificar que la propuesta existe y está en estado válido
    const propuesta = await prismaClient.PV_Proposals.findUnique({
      where: { proposalid: data.proposalid },
      include: {
        PV_ProposalStatus: true
      }
    });

    if (!propuesta) {
      return {
        success: false,
        error: 'Propuesta no encontrada',
        details: `No existe propuesta con ID ${data.proposalid}`
      };
    }

    // 2. Verificar permisos del usuario
    const permisoValido = await verificarPermisosConfiguracion(data.userid, data.proposalid);
    if (!permisoValido.permitido) {
      return {
        success: false,
        error: 'Permisos insuficientes',
        details: permisoValido.razon
      };
    }

    // 3. Verificar que no existe configuración previa activa
    const configExistente = await prismaClient.PV_VotingConfigurations.findFirst({
      where: { 
        proposalid: data.proposalid,
        statusid: { in: [1, 2, 3] } // Estados activos
      }
    });

    if (configExistente) {
      return {
        success: false,
        error: 'Ya existe una configuración activa para esta propuesta',
        details: `Configuración ID: ${configExistente.votingconfigid}`
      };
    }

    // 4. Crear configuración principal
    const checksum = generarChecksumConfiguracion(data);
      const nuevaConfiguracion = await prismaClient.PV_VotingConfigurations.create({
      data: {
        proposalid: data.proposalid,
        startdate: new Date(data.startdate),
        enddate: new Date(data.enddate),
        votingtypeId: data.votingtypeId,
        allowweightedvotes: data.allowweightedvotes || false,
        requiresallvoters: data.requiresallvoters || false,
        notificationmethodid: data.notificationmethodid || null,
        userid: data.userid,
        publicVoting: data.publicVoting || false,
        statusid: 1, // Configurada/Preparada
        checksum: checksum
      }
    });

    // 5. Crear preguntas de votación
    const preguntasCreadas = [];
    for (const pregunta of data.preguntas) {      const nuevaPregunta = await prismaClient.PV_VotingQuestions.create({
        data: {
          question: pregunta.question,
          questionTypeId: pregunta.questionTypeId,
          createdDate: new Date(),
          checksum: Buffer.from(
            crypto.createHash('sha256')
              .update(`${pregunta.question}-${pregunta.questionTypeId}-${Date.now()}`)
              .digest('hex'),
            'hex'
          )
        }
      });
      preguntasCreadas.push(nuevaPregunta);
    }

    // 6. Crear opciones de votación
    const opcionesCreadas = [];
    for (let i = 0; i < data.opciones.length; i++) {
      const opcion = data.opciones[i];
      const nuevaOpcion = await prismaClient.PV_VotingOptions.create({
        data: {
          votingconfigid: nuevaConfiguracion.votingconfigid,
          optiontext: opcion.optiontext,
          optionorder: i + 1,
          questionId: preguntasCreadas[opcion.questionIndex || 0].questionId,
          mediafileId: opcion.mediafileId || null,          checksum: Buffer.from(
            crypto.createHash('sha256')
              .update(`${opcion.optiontext}-${nuevaConfiguracion.votingconfigid}-${i}`)
              .digest('hex'), 
            'hex'
          )
        }
      });
      opcionesCreadas.push(nuevaOpcion);
    }

    // 7. Configurar segmentos objetivo si se especifican
    const segmentosCreados = [];
    if (data.segmentosObjetivo && data.segmentosObjetivo.length > 0) {
      for (const segmento of data.segmentosObjetivo) {
        const nuevoSegmento = await prismaClient.PV_VotingTargetSegments.create({
          data: {
            votingconfigid: nuevaConfiguracion.votingconfigid,
            segmentid: segmento.segmentid,
            voteweight: segmento.voteweight || 1.0,
            assigneddate: new Date()
          }
        });
        segmentosCreados.push(nuevoSegmento);
      }
    }    // 8. Inicializar métricas de votación
    await inicializarMetricasVotacion(prismaClient, nuevaConfiguracion.votingconfigid);    // Convertir checksum a formato hexadecimal para respuesta legible
    const configuracionLegible = {
      ...nuevaConfiguracion,
      checksum: nuevaConfiguracion.checksum.toString('hex')
    };

    const preguntasLegibles = preguntasCreadas.map(pregunta => ({
      ...pregunta,
      checksum: pregunta.checksum.toString('hex')
    }));

    const opcionesLegibles = opcionesCreadas.map(opcion => ({
      ...opcion,
      checksum: opcion.checksum.toString('hex')
    }));

    return {
      success: true,
      data: {
        votingconfigid: nuevaConfiguracion.votingconfigid,
        configuracion: configuracionLegible,
        preguntas: preguntasLegibles,
        opciones: opcionesLegibles,
        segmentos: segmentosCreados
      }
    };

  } catch (error) {
    console.error('Error en configurarVotacionCompleta:', error);
    return {
      success: false,
      error: 'Error al configurar votación',
      details: error.message
    };
  }
}

/**
 * Actualiza una configuración de votación existente
 */
async function actualizarConfiguracionVotacion(prismaClient, votingconfigid, data) {
  try {
    // 1. Obtener configuración actual
    const configActual = await prismaClient.PV_VotingConfigurations.findUnique({
      where: { votingconfigid },
      include: {
        PV_VotingOptions: true,
        PV_VotingTargetSegments: true
      }
    });

    if (!configActual) {
      return {
        success: false,
        error: 'Configuración no encontrada'
      };
    }

    // 2. Generar nuevo checksum
    const checksum = generarChecksumConfiguracion(data);

    // 3. Actualizar configuración principal
    const configActualizada = await prismaClient.PV_VotingConfigurations.update({
      where: { votingconfigid },
      data: {
        startdate: new Date(data.startdate),
        enddate: new Date(data.enddate),
        votingtypeId: data.votingtypeId,
        allowweightedvotes: data.allowweightedvotes || false,
        requiresallvoters: data.requiresallvoters || false,
        notificationmethodid: data.notificationmethodid || null,
        publicVoting: data.publicVoting || false,
        checksum: checksum
      }
    });

    // 4. Actualizar opciones (eliminar existentes y crear nuevas)
    await prismaClient.PV_VotingOptions.deleteMany({
      where: { votingconfigid }
    });

    const opcionesActualizadas = [];
    for (let i = 0; i < data.opciones.length; i++) {
      const opcion = data.opciones[i];
      const nuevaOpcion = await prismaClient.PV_VotingOptions.create({
        data: {
          votingconfigid,
          optiontext: opcion.optiontext,
          optionorder: i + 1,
          questionId: opcion.questionId,
          mediafileId: opcion.mediafileId || null,          checksum: Buffer.from(
            crypto.createHash('sha256')
              .update(`${opcion.optiontext}-${votingconfigid}-${i}`)
              .digest('hex'),
            'hex'
          )
        }
      });
      opcionesActualizadas.push(nuevaOpcion);
    }

    // 5. Actualizar segmentos objetivo
    await prismaClient.PV_VotingTargetSegments.deleteMany({
      where: { votingconfigid }
    });

    const segmentosActualizados = [];
    if (data.segmentosObjetivo && data.segmentosObjetivo.length > 0) {
      for (const segmento of data.segmentosObjetivo) {
        const nuevoSegmento = await prismaClient.PV_VotingTargetSegments.create({
          data: {
            votingconfigid,
            segmentid: segmento.segmentid,
            voteweight: segmento.voteweight || 1.0,
            assigneddate: new Date()
          }
        });
        segmentosActualizados.push(nuevoSegmento);
      }
    }    // Convertir checksums a formato hexadecimal para respuesta legible
    const configuracionLegible = {
      ...configActualizada,
      checksum: configActualizada.checksum.toString('hex')
    };

    const opcionesLegibles = opcionesActualizadas.map(opcion => ({
      ...opcion,
      checksum: opcion.checksum.toString('hex')
    }));

    return {
      success: true,
      data: {
        votingconfigid,
        configuracion: configuracionLegible,
        opciones: opcionesLegibles,
        segmentos: segmentosActualizados
      }
    };

  } catch (error) {
    console.error('Error en actualizarConfiguracionVotacion:', error);
    return {
      success: false,
      error: 'Error al actualizar configuración',
      details: error.message
    };
  }
}

/**
 * Elimina una configuración de votación
 */
async function eliminarConfiguracionVotacion(prismaClient, votingconfigid) {
  try {
    // 1. Eliminar dependencias en orden
    await prismaClient.PV_VotingTargetSegments.deleteMany({
      where: { votingconfigid }
    });

    await prismaClient.PV_VotingOptions.deleteMany({
      where: { votingconfigid }
    });

    await prismaClient.PV_VotingMetrics.deleteMany({
      where: { votingconfigid }
    });

    // 2. Eliminar configuración principal
    await prismaClient.PV_VotingConfigurations.delete({
      where: { votingconfigid }
    });

    return {
      success: true
    };

  } catch (error) {
    console.error('Error en eliminarConfiguracionVotacion:', error);
    return {
      success: false,
      error: 'Error al eliminar configuración',
      details: error.message
    };
  }
}

/**
 * Verifica si se puede actualizar una configuración
 */
async function verificarActualizacionPermitida(votingconfigid) {
  try {
    const configuracion = await prisma.PV_VotingConfigurations.findUnique({
      where: { votingconfigid },
      include: {
        PV_VotingStatus: true
      }
    });

    if (!configuracion) {
      return {
        permitida: false,
        razon: 'Configuración no encontrada'
      };
    }

    // No permitir actualización si la votación ya inició
    const ahora = new Date();
    if (configuracion.startdate <= ahora) {
      return {
        permitida: false,
        razon: 'No se puede actualizar una votación que ya ha iniciado'
      };
    }

    // No permitir actualización si está finalizada o cancelada
    if (configuracion.statusid >= 4) { // Asumiendo que 4+ son estados finales
      return {
        permitida: false,
        razon: 'No se puede actualizar una votación finalizada o cancelada'
      };
    }

    return {
      permitida: true
    };

  } catch (error) {
    console.error('Error en verificarActualizacionPermitida:', error);
    return {
      permitida: false,
      razon: 'Error al verificar permisos de actualización'
    };
  }
}

/**
 * Verifica si se puede eliminar una configuración
 */
async function verificarEliminacionPermitida(votingconfigid) {
  try {
    const configuracion = await prisma.PV_VotingConfigurations.findUnique({
      where: { votingconfigid },
      include: {
        PV_Votes: {
          take: 1 // Solo verificar si existe algún voto
        }
      }
    });

    if (!configuracion) {
      return {
        permitida: false,
        razon: 'Configuración no encontrada'
      };
    }

    // No permitir eliminación si ya hay votos registrados
    if (configuracion.PV_Votes.length > 0) {
      return {
        permitida: false,
        razon: 'No se puede eliminar una configuración que ya tiene votos registrados'
      };
    }

    // No permitir eliminación si la votación ya inició
    const ahora = new Date();
    if (configuracion.startdate <= ahora) {
      return {
        permitida: false,
        razon: 'No se puede eliminar una votación que ya ha iniciado'
      };
    }

    return {
      permitida: true
    };

  } catch (error) {
    console.error('Error en verificarEliminacionPermitida:', error);
    return {
      permitida: false,
      razon: 'Error al verificar permisos de eliminación'
    };
  }
}

/**
 * Verifica permisos del usuario para configurar votaciones
 */
async function verificarPermisosConfiguracion(userid, proposalid) {
  try {
    // 1. Verificar que el usuario existe y está activo
    const usuario = await prisma.PV_Users.findUnique({
      where: { userid },
      include: {
        PV_UserStatus: true,
        PV_UserPermissions: {
          include: {
            PV_Permissions: true
          }
        },
        PV_UserRoles: {
          include: {
            PV_Roles: {
              include: {
                PV_RolePermissions: {
                  include: {
                    PV_Permissions: true
                  }
                }
              }
            }
          }
        }
      }
    });

    if (!usuario) {
      return {
        permitido: false,
        razon: 'Usuario no encontrado'
      };
    }

    if (!usuario.PV_UserStatus?.active) {
      return {
        permitido: false,
        razon: 'Usuario no está activo'
      };
    }

    // 2. Verificar permisos específicos para configurar votaciones
    const permisoConfigVotacion = 'CONF_VOT'; // Código de permiso para configurar votaciones
    
    // Buscar permiso directo del usuario
    const permisoDirecto = usuario.PV_UserPermissions.find(up => 
      up.PV_Permissions.code === permisoConfigVotacion && up.enabled && !up.deleted
    );

    if (permisoDirecto) {
      return { permitido: true };
    }

    // Buscar permiso a través de roles
    for (const userRole of usuario.PV_UserRoles) {
      if (!userRole.enabled || userRole.deleted) continue;
      
      const permisoRol = userRole.PV_Roles.PV_RolePermissions.find(rp =>
        rp.PV_Permissions.code === permisoConfigVotacion && rp.enabled && !rp.deleted
      );

      if (permisoRol) {
        return { permitido: true };
      }
    }

    // 3. Verificar si es el creador de la propuesta
    const propuesta = await prisma.PV_Proposals.findUnique({
      where: { proposalid }
    });

    if (propuesta && propuesta.createdby === userid) {
      return { permitido: true };
    }

    return {
      permitido: false,
      razon: 'Usuario no tiene permisos para configurar votaciones'
    };

  } catch (error) {
    console.error('Error en verificarPermisosConfiguracion:', error);
    return {
      permitido: false,
      razon: 'Error al verificar permisos'
    };
  }
}

/**
 * Inicializa las métricas de votación para una configuración
 */
async function inicializarMetricasVotacion(prismaClient, votingconfigid) {
  try {
    // Obtener tipos de métricas disponibles
    const tiposMetricas = await prismaClient.PV_VotingMetricsType.findMany();

    // Crear métricas iniciales
    for (const tipo of tiposMetricas) {
      await prismaClient.PV_VotingMetrics.create({
        data: {
          votingconfigid,
          metrictypeId: tipo.VotingMetricTypeId,
          metricvalue: 0,
          calculateddate: new Date(),
          isactive: true
        }
      });
    }

  } catch (error) {
    console.error('Error en inicializarMetricasVotacion:', error);
    throw error;
  }
}

/**
 * Genera un checksum para la configuración
 */
function generarChecksumConfiguracion(data) {
  const contenido = JSON.stringify({
    proposalid: data.proposalid,
    startdate: data.startdate,
    enddate: data.enddate,
    votingtypeId: data.votingtypeId,
    opciones: data.opciones,
    timestamp: Date.now()
  });

  // Generar hash como string hexadecimal y luego convertir a Buffer para la BD
  const hashHex = crypto.createHash('sha256').update(contenido).digest('hex');
  return Buffer.from(hashHex, 'hex');
}

/**
 * Registra logs de auditoría para configuración
 */
async function registrarLogConfiguracion(userid, votingconfigid, accion, datos) {
  try {
    await prisma.PV_Logs.create({
      data: {
        description: `Configuración de votación: ${accion}`,
        name: 'ConfiguracionVotacion',
        posttime: new Date(),
        computer: 'API-Server',
        trace: `Usuario: ${userid}, ConfigID: ${votingconfigid}`,
        referenceid1: BigInt(votingconfigid),
        referenceid2: BigInt(userid),
        checksum: Buffer.from(
          crypto.createHash('sha256').update(JSON.stringify(datos)).digest('hex'),
          'hex'
        ),
        logtypeid: 1, // Tipo de log para configuración
        logsourceid: 1, // Fuente API
        logseverityid: 1, // Info
        value1: accion,
        value2: JSON.stringify(datos).substring(0, 250)
      }
    });
  } catch (error) {
    console.error('Error al registrar log de configuración:', error);
    // No fallar la operación por error en logging
  }
}
