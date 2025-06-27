/**
 * Endpoint: /api/configurarVotacion
 * Permite configurar votaciones para propuestas
 * Requiere JWT y verifica que el usuario sea el creador de la propuesta
 */

const sql = require('mssql');
const crypto = require('crypto');
const { PrismaClient } = require('@prisma/client');

// Crear instancia de Prisma
const prisma = new PrismaClient();

// Usar la misma configuración que funciona en el resto del sistema
const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

// Función helper para ejecutar operaciones en transacciones
async function executeTransaction(callback) {
  try {
    return await prisma.$transaction(callback);
  } catch (error) {
    console.error('Error en transacción:', error);
    throw error;
  }
}

// Endpoint principal para configurar votaciones
// Solo maneja POST
module.exports = async (req, res) => {
  try {
    const { method } = req;
    
    // 🔐 VERIFICAR AUTENTICACIÓN JWT
    if (!req.user || !req.user.userId) {
      return res.status(401).json({
        error: 'Usuario no autenticado',
        details: 'El middleware JWT no estableció req.user.userId',
        timestamp: new Date().toISOString()
      });
    }
    
    const userId = req.user.userId;
    console.log(`Usuario autenticado: ${userId}, Método: ${method}`);

    // Solo POST permitido
    if (method !== 'POST') {
      return res.status(405).json({
        error: `Método ${method} no permitido`,
        allowedMethods: ['POST'],
        timestamp: new Date().toISOString()
      });
    }

    // POST: Crear nueva configuración de votación
    const userid = req.user.userId;
    const datosConfiguracion = { ...req.body, userid }; // Agregar userid a los datos

    // 🔐 VERIFICAR QUE EL USUARIO ES EL CREADOR DE LA PROPUESTA
    if (!datosConfiguracion.proposalid) {
      return res.status(400).json({
        error: 'Falta el ID de la propuesta',
        timestamp: new Date().toISOString()
      });
    }

    try {
      const propuesta = await prisma.PV_Proposals.findUnique({
        where: { proposalid: parseInt(datosConfiguracion.proposalid) }
      });

      if (!propuesta) {
        return res.status(404).json({
          error: 'La propuesta no existe',
          timestamp: new Date().toISOString()
        });
      }

      if (propuesta.createdby !== userid) {
        return res.status(403).json({
          error: 'No tienes permisos para configurar votación en esta propuesta',
          details: 'Solo el creador de la propuesta puede configurar su votación',
          timestamp: new Date().toISOString()
        });
      }

      console.log(`✅ Usuario ${userid} autorizado para configurar votación de propuesta ${datosConfiguracion.proposalid}`);

    } catch (error) {
      console.error('Error verificando creador de propuesta:', error);
      return res.status(500).json({
        error: 'Error verificando permisos',
        details: error.message,
        timestamp: new Date().toISOString()
      });
    }

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

  } catch (error) {
    console.error('Error general en configurarVotacion:', error);
    return res.status(500).json({
      error: 'Error del servidor',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
};

// Verificar que los datos que mandaron están completos y son válidos
function verificarDatos(data) {
  const errores = [];
  // Campos obligatorios
  if (!data.proposalid) errores.push('Falta el ID de la propuesta');
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

  return {
    valida: errores.length === 0,
    errores
  };
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

    // 2. Verificar que no hay otra configuración activa para esta propuesta
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

    // 3. Crear la configuración principal
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

    // 4. Crear las preguntas
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

    // 5. Crear las opciones de votación
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

    // 6. Configurar segmentos objetivo si se proporcionaron
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

    return {
      success: true,
      data: {
        votingconfigid: nuevaConfiguracion.votingconfigid,
        configuracion: {
          ...nuevaConfiguracion,
          checksum: nuevaConfiguracion.checksum.toString('hex')
        },
        preguntas: preguntasCreadas.map(pregunta => ({
          ...pregunta,
          checksum: pregunta.checksum.toString('hex')
        })),
        opciones: opcionesCreadas.map(opcion => ({
          ...opcion,
          checksum: opcion.checksum.toString('hex')
        })),
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
