
const { prisma, handlePrismaError, executeTransaction } = require('../../src/config/prisma');
const crypto = require('crypto');

// Endpoint principal para configurar votaciones
// Maneja GET, POST, PUT y DELETE
module.exports = async (req, res) => {
  try {
    const { method } = req;

    // GET: Consultar configuraciones existentes o datos para configurar
    if (method === 'GET') {
      const { proposalid, type } = req.query;

      // Verificar que se envió el ID de la propuesta
      if (!proposalid) {
        return res.status(400).json({
          error: 'Falta el ID de la propuesta',
          timestamp: new Date().toISOString()
        });
      }

      try {
        if (type === 'configuration') {
          // Buscar la configuración que ya existe para esta propuesta
          const config = await buscarConfiguracion(parseInt(proposalid));
          return res.status(200).json({
            success: true,
            data: config,
            timestamp: new Date().toISOString()
          });
        } else if (type === 'setup-data') {
          // Traer todos los datos necesarios para crear una nueva configuración
          const datosParaConfigurar = await traerDatosConfiguracion();
          return res.status(200).json({
            success: true,
            data: datosParaConfigurar,
            timestamp: new Date().toISOString()
          });
        } else {
          return res.status(400).json({
            error: 'Tipo no válido. Use "configuration" o "setup-data"',
            timestamp: new Date().toISOString()
          });
        }
      } catch (error) {
        console.error('Error buscando configuración:', error);
        return res.status(500).json({
          error: 'Error del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }    // POST: Crear nueva configuración de votación
    if (method === 'POST') {
      const datosConfiguracion = req.body;

      // Verificar que los datos están completos
      const validacion = verificarDatos(datosConfiguracion);
      if (!validacion.valida) {
        return res.status(400).json({
          error: 'Datos incompletos o inválidos',
          details: validacion.errores,
          timestamp: new Date().toISOString()
        });
      }

      try {
        // Crear la configuración en una transacción para que todo se haga bien o nada
        const resultado = await executeTransaction(async (prismaClient) => {
          return await crearConfiguracionCompleta(prismaClient, datosConfiguracion);
        });

        // Si algo salió mal
        if (!resultado.success) {
          return res.status(400).json({
            error: resultado.error,
            details: resultado.details,
            timestamp: new Date().toISOString()
          });
        }

        // Guardar un log de que se configuró la votación
        await guardarLogConfiguracion(
          datosConfiguracion.userid,
          resultado.data.votingconfigid,
          'VOTACION_CONFIGURADA',
          datosConfiguracion
        );

        return res.status(201).json({
          success: true,
          message: 'Configuración creada exitosamente',
          data: resultado.data,
          timestamp: new Date().toISOString()
        });

      } catch (error) {
        console.error('Error creando configuración:', error);
        return res.status(500).json({
          error: 'Error del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }    // PUT: Actualizar una configuración que ya existe (solo si no empezó la votación)
    if (method === 'PUT') {
      const datosConfiguracion = req.body;
      const { votingconfigid } = req.query;

      // Verificar que mandaron el ID de configuración
      if (!votingconfigid) {
        return res.status(400).json({
          error: 'Falta el ID de configuración de votación',
          timestamp: new Date().toISOString()
        });
      }

      try {
        // Verificar si se puede actualizar (que no haya empezado la votación)
        const puedeActualizar = await puedeModificarConfiguracion(parseInt(votingconfigid));
        if (!puedeActualizar.permitida) {
          return res.status(403).json({
            error: 'No se puede actualizar la configuración',
            details: puedeActualizar.razon,
            timestamp: new Date().toISOString()
          });
        }

        // Verificar que los datos están bien
        const validacion = verificarDatos(datosConfiguracion);
        if (!validacion.valida) {
          return res.status(400).json({
            error: 'Datos incompletos o inválidos',
            details: validacion.errores,
            timestamp: new Date().toISOString()
          });
        }

        // Actualizar en una transacción
        const resultado = await executeTransaction(async (prismaClient) => {
          return await actualizarConfiguracion(
            prismaClient, 
            parseInt(votingconfigid), 
            datosConfiguracion
          );
        });

        if (!resultado.success) {
          return res.status(400).json({
            error: resultado.error,
            details: resultado.details,
            timestamp: new Date().toISOString()
          });
        }

        // Guardar log de la actualización
        await guardarLogConfiguracion(
          datosConfiguracion.userid,
          parseInt(votingconfigid),
          'VOTACION_ACTUALIZADA',
          datosConfiguracion
        );

        return res.status(200).json({
          success: true,
          message: 'Configuración actualizada exitosamente',
          data: resultado.data,
          timestamp: new Date().toISOString()
        });

      } catch (error) {
        console.error('Error actualizando configuración:', error);
        return res.status(500).json({
          error: 'Error del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }    // DELETE: Borrar una configuración (solo si no empezó la votación)
    if (method === 'DELETE') {
      const { votingconfigid } = req.query;

      // Verificar que mandaron el ID
      if (!votingconfigid) {
        return res.status(400).json({
          error: 'Falta el ID de configuración de votación',
          timestamp: new Date().toISOString()
        });
      }

      try {
        // Verificar si se puede borrar
        const puedeBorrar = await puedeBorrarConfiguracion(parseInt(votingconfigid));
        if (!puedeBorrar.permitida) {
          return res.status(403).json({
            error: 'No se puede borrar la configuración',
            details: puedeBorrar.razon,
            timestamp: new Date().toISOString()
          });
        }

        // Borrar en una transacción
        const resultado = await executeTransaction(async (prismaClient) => {
          return await borrarConfiguracion(prismaClient, parseInt(votingconfigid));
        });

        if (!resultado.success) {
          return res.status(400).json({
            error: resultado.error,
            details: resultado.details,
            timestamp: new Date().toISOString()
          });
        }

        // Guardar log del borrado
        await guardarLogConfiguracion(
          req.user?.userid || 0,
          parseInt(votingconfigid),
          'VOTACION_ELIMINADA',
          { votingconfigid }
        );

        return res.status(200).json({
          success: true,
          message: 'Configuración borrada exitosamente',
          timestamp: new Date().toISOString()
        });

      } catch (error) {
        console.error('Error borrando configuración:', error);
        return res.status(500).json({
          error: 'Error del servidor',
          details: error.message,
          timestamp: new Date().toISOString()
        });
      }
    }

    // Si llegó hasta acá, el método no está permitido
    return res.status(405).json({
      error: `Método ${method} no permitido`,
      allowedMethods: ['GET', 'POST', 'PUT', 'DELETE'],
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error general en configurarVotacion:', error);
    return res.status(500).json({
      error: 'Error del servidor',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
};

// Buscar la configuración que ya existe para una propuesta
async function buscarConfiguracion(proposalid) {
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
    }

    // Organizar los datos de manera más simple para el frontend
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
    console.error('Error buscando configuración:', error);
    throw error;
  }
}

// Traer todos los datos que se necesitan para configurar una votación
async function traerDatosConfiguracion() {
  try {
    // Buscar todo en paralelo para ser más rápido
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
    console.error('Error trayendo datos de configuración:', error);
    throw error;
  }
}

// Verificar que los datos que mandaron están completos y son válidos
function verificarDatos(data) {
  const errores = [];

  // Campos obligatorios
  if (!data.proposalid) errores.push('Falta el ID de la propuesta');
  if (!data.userid) errores.push('Falta el ID del usuario');
  if (!data.startdate) errores.push('Falta la fecha de inicio');
  if (!data.enddate) errores.push('Falta la fecha de fin');
  if (!data.votingtypeId) errores.push('Falta el tipo de votación');

  // Verificar fechas
  if (data.startdate && data.enddate) {
    const fechaInicio = new Date(data.startdate);
    const fechaFin = new Date(data.enddate);
    const ahora = new Date();

    if (fechaInicio <= ahora) {
      errores.push('La fecha de inicio debe ser en el futuro');
    }

    if (fechaFin <= fechaInicio) {
      errores.push('La fecha de fin debe ser después de la fecha de inicio');
    }
  }

  // Verificar opciones de votación
  if (!data.opciones || !Array.isArray(data.opciones) || data.opciones.length < 2) {
    errores.push('Se necesitan al menos 2 opciones para votar');
  }

  // Verificar preguntas
  if (!data.preguntas || !Array.isArray(data.preguntas) || data.preguntas.length === 0) {
    errores.push('Se necesita al menos una pregunta');
  }

  // Verificar IPs permitidas si las mandaron
  if (data.allowedIPs) {
    if (!Array.isArray(data.allowedIPs)) {
      errores.push('Las IPs permitidas deben ser una lista');
    } else {
      const ipsInvalidas = data.allowedIPs.filter(ip => !esIPValida(ip));
      if (ipsInvalidas.length > 0) {
        errores.push(`IPs inválidas: ${ipsInvalidas.join(', ')}`);
      }
    }
  }

  // Verificar IPs restringidas si las mandaron
  if (data.restrictedIPs) {
    if (!Array.isArray(data.restrictedIPs)) {
      errores.push('Las IPs restringidas deben ser una lista');
    } else {
      const ipsInvalidas = data.restrictedIPs.filter(ip => !esIPValida(ip));
      if (ipsInvalidas.length > 0) {
        errores.push(`IPs inválidas: ${ipsInvalidas.join(', ')}`);
      }
    }
  }

  // Verificar horarios de acceso si los mandaron
  if (data.accessSchedule) {
    const horarios = data.accessSchedule;
    if (!horarios.startTime || !horarios.endTime) {
      errores.push('Los horarios deben tener hora de inicio y fin');
    }
    
    if (horarios.daysOfWeek && !Array.isArray(horarios.daysOfWeek)) {
      errores.push('Los días de la semana deben ser una lista');
    }
  }

  // Verificar turnos si los mandaron
  if (data.votingShifts && Array.isArray(data.votingShifts)) {
    for (const turno of data.votingShifts) {
      if (!turno.name || !turno.startTime || !turno.endTime) {
        errores.push('Cada turno debe tener nombre, hora de inicio y hora de fin');
      }
    }
  }

  return {
    valida: errores.length === 0,
    errores
  };
}

// Verificar si una IP tiene formato válido (IPv4, IPv6 o CIDR)
function esIPValida(ip) {
  // Formato IPv4: 192.168.1.1
  const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
  
  // Formato IPv6: 2001:db8::1 (básico)
  const ipv6Regex = /^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$/;
  
  // Formato CIDR: 192.168.1.0/24
  const cidrRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/(?:3[0-2]|[1-2]?[0-9])$/;
  
  return ipv4Regex.test(ip) || ipv6Regex.test(ip) || cidrRegex.test(ip);
}

// Crear una configuración completa de votación (todo junto en una transacción)
async function crearConfiguracionCompleta(prismaClient, data) {
  try {
    // 1. Verificar que la propuesta existe
    const propuesta = await prismaClient.PV_Proposals.findUnique({
      where: { proposalid: data.proposalid },
      include: {
        PV_ProposalStatus: true
      }
    });

    if (!propuesta) {
      return {
        success: false,
        error: 'La propuesta no existe',
        details: `No hay propuesta con ID ${data.proposalid}`
      };
    }

    // 2. Verificar que el usuario puede configurar votaciones
    const puedeConfigurar = await verificarPermisos(data.userid, data.proposalid);
    if (!puedeConfigurar.permitido) {
      return {
        success: false,
        error: 'No tienes permisos para hacer esto',
        details: puedeConfigurar.razon
      };
    }

    // 3. Verificar que no hay otra configuración activa para esta propuesta
    const configExistente = await prismaClient.PV_VotingConfigurations.findFirst({
      where: { 
        proposalid: data.proposalid,
        statusid: { in: [1, 2, 3] } // Estados activos
      }
    });

    if (configExistente) {
      return {
        success: false,
        error: 'Ya hay una configuración activa para esta propuesta',
        details: `Configuración ID: ${configExistente.votingconfigid}`
      };
    }

    // 4. Crear la configuración principal
    const checksum = crearChecksumConfiguracion(data);
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

    // 5. Crear las preguntas
    const preguntasCreadas = [];
    for (const pregunta of data.preguntas) {
      const nuevaPregunta = await prismaClient.PV_VotingQuestions.create({
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

    // 6. Crear las opciones de votación
    const opcionesCreadas = [];
    for (let i = 0; i < data.opciones.length; i++) {
      const opcion = data.opciones[i];
      const nuevaOpcion = await prismaClient.PV_VotingOptions.create({
        data: {
          votingconfigid: nuevaConfiguracion.votingconfigid,
          optiontext: opcion.optiontext,
          optionorder: i + 1,
          questionId: preguntasCreadas[opcion.questionIndex || 0].questionId,
          mediafileId: opcion.mediafileId || null,
          checksum: Buffer.from(
            crypto.createHash('sha256')
              .update(`${opcion.optiontext}-${nuevaConfiguracion.votingconfigid}-${i}`)
              .digest('hex'), 
            'hex'
          )
        }
      });
      opcionesCreadas.push(nuevaOpcion);
    }

    // 7. Configurar a qué grupos de personas va dirigida la votación
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
    }

    // 8. Crear las métricas iniciales
    await crearMetricasIniciales(prismaClient, nuevaConfiguracion.votingconfigid);

    // Convertir checksums a texto para que se puedan leer
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
    console.error('Error creando configuración completa:', error);
    return {
      success: false,
      error: 'Error al crear la configuración',
      details: error.message
    };
  }
}

// Actualizar una configuración que ya existe
async function actualizarConfiguracion(prismaClient, votingconfigid, data) {
  try {
    // 1. Buscar la configuración actual
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
        error: 'No se encontró la configuración'
      };
    }

    // 2. Crear nuevo checksum
    const checksum = crearChecksumConfiguracion(data);

    // 3. Actualizar la configuración principal
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

    // 4. Borrar opciones viejas y crear nuevas
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
          mediafileId: opcion.mediafileId || null,
          checksum: Buffer.from(
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
    }

    // Convertir checksums a texto legible
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
    console.error('Error actualizando configuración:', error);
    return {
      success: false,
      error: 'Error al actualizar la configuración',
      details: error.message
    };
  }
}

// Borrar una configuración de votación
async function borrarConfiguracion(prismaClient, votingconfigid) {
  try {
    // Borrar en orden para evitar problemas de dependencias
    
    // 1. Borrar segmentos objetivo
    await prismaClient.PV_VotingTargetSegments.deleteMany({
      where: { votingconfigid }
    });

    // 2. Borrar opciones de votación
    await prismaClient.PV_VotingOptions.deleteMany({
      where: { votingconfigid }
    });

    // 3. Borrar métricas
    await prismaClient.PV_VotingMetrics.deleteMany({
      where: { votingconfigid }
    });

    // 4. Borrar configuración principal
    await prismaClient.PV_VotingConfigurations.delete({
      where: { votingconfigid }
    });

    return {
      success: true
    };

  } catch (error) {
    console.error('Error borrando configuración:', error);
    return {
      success: false,
      error: 'Error al borrar la configuración',
      details: error.message
    };
  }
}

// Verificar si se puede modificar una configuración (que no haya empezado la votación)
async function puedeModificarConfiguracion(votingconfigid) {
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
        razon: 'No se encontró la configuración'
      };
    }

    // No permitir modificación si ya empezó la votación
    const ahora = new Date();
    if (configuracion.startdate <= ahora) {
      return {
        permitida: false,
        razon: 'No se puede modificar una votación que ya empezó'
      };
    }

    // No permitir si está finalizada o cancelada
    if (configuracion.statusid >= 4) { // 4+ son estados finales
      return {
        permitida: false,
        razon: 'No se puede modificar una votación finalizada o cancelada'
      };
    }

    return {
      permitida: true
    };

  } catch (error) {
    console.error('Error verificando si se puede modificar:', error);
    return {
      permitida: false,
      razon: 'Error al verificar permisos'
    };
  }
}

// Verificar si se puede borrar una configuración (que no haya votos y no haya empezado)
async function puedeBorrarConfiguracion(votingconfigid) {
  try {
    const configuracion = await prisma.PV_VotingConfigurations.findUnique({
      where: { votingconfigid },
      include: {
        PV_Votes: {
          take: 1 // Solo verificar si hay algún voto
        }
      }
    });

    if (!configuracion) {
      return {
        permitida: false,
        razon: 'No se encontró la configuración'
      };
    }

    // No permitir borrar si ya hay votos
    if (configuracion.PV_Votes.length > 0) {
      return {
        permitida: false,
        razon: 'No se puede borrar una configuración que ya tiene votos'
      };
    }

    // No permitir borrar si ya empezó la votación
    const ahora = new Date();
    if (configuracion.startdate <= ahora) {
      return {
        permitida: false,
        razon: 'No se puede borrar una votación que ya empezó'
      };
    }

    return {
      permitida: true
    };

  } catch (error) {
    console.error('Error verificando si se puede borrar:', error);
    return {
      permitida: false,
      razon: 'Error al verificar permisos'
    };
  }
}

// Verificar si un usuario puede configurar votaciones para una propuesta
async function verificarPermisos(userid, proposalid) {
  try {
    // 1. Buscar el usuario y ver que esté activo
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

    // 2. Verificar si tiene permiso directo para configurar votaciones
    const permisoConfigVotacion = 'CONF_VOT'; // Código de permiso
    
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
      razon: 'El usuario no tiene permisos para configurar votaciones'
    };

  } catch (error) {
    console.error('Error verificando permisos:', error);
    return {
      permitido: false,
      razon: 'Error al verificar permisos'
    };
  }
}

// Crear las métricas iniciales para una configuración de votación
async function crearMetricasIniciales(prismaClient, votingconfigid) {
  try {
    // Buscar qué tipos de métricas hay disponibles
    const tiposMetricas = await prismaClient.PV_VotingMetricsType.findMany();

    // Crear una métrica inicial para cada tipo (todo en 0)
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
    console.error('Error creando métricas iniciales:', error);
    throw error;
  }
}

// Crear un hash único para la configuración (para verificar integridad)
function crearChecksumConfiguracion(data) {
  const contenido = JSON.stringify({
    proposalid: data.proposalid,
    startdate: data.startdate,
    enddate: data.enddate,
    votingtypeId: data.votingtypeId,
    opciones: data.opciones,
    timestamp: Date.now()
  });

  // Crear hash y convertir a Buffer para guardarlo en la base de datos
  const hashHex = crypto.createHash('sha256').update(contenido).digest('hex');
  return Buffer.from(hashHex, 'hex');
}

// Guardar un registro de lo que se hizo (para auditoría)
async function guardarLogConfiguracion(userid, votingconfigid, accion, datos) {
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
        value2: JSON.stringify(datos).substring(0, 250) // Máximo 250 caracteres
      }
    });
  } catch (error) {
    console.error('Error guardando log:', error);
    // No hacer fallar la operación por un error en el log
  }
}
