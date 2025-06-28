/**
 * Endpoint para votar - SOLO POST para registrar votos
 * Simplificado al máximo para desarrollo
 */
const { prisma, executeTransaction } = require('../../src/config/prisma');
const crypto = require('crypto');
const { validateVerificationCode } = require('../../src/utils/emailService');
const { decryptWithPassword } = require('../../src/utils/encrypvotesgenerator');
module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido. Solo POST para votar.' });
  }

  const userid = req.user.userId;
  const { proposalid, answers, mfaCode, password } = req.body;

  if (!proposalid || !Array.isArray(answers) || answers.length === 0 || !mfaCode || !password) {
    return res.status(400).json({
      error: 'Faltan datos requeridos: proposalid, answers[], mfaCode, password'
    });
  }

  // DEBUG: Prueba directa fuera de la transacción
  try {
    const testMetric = await require('../../src/config/prisma').prisma.PV_VotingMetrics.findFirst({
      where: {
        votingconfigid: 1,
        segmentid: 1,
        optionid: 1
      }
    });
    console.log('DEBUG testMetric fuera de transacción:', testMetric);
  } catch (err) {
    console.error('ERROR testMetric fuera de transacción:', err);
  }

  try {
    const resultados = await executeTransaction(async (tx) => {
      // 1. Verificar usuario
      const usuario = await tx.PV_Users.findUnique({
        where: { userid: parseInt(userid) },
        include: { PV_UserStatus: true }
      });
      if (!usuario || !usuario.PV_UserStatus?.active) {
        throw new Error('Usuario no encontrado o inactivo');
      }
      if (!usuario.email) {
        throw new Error('El usuario no tiene email registrado');
      }
      const mfaValido = validateVerificationCode(usuario.email, mfaCode);
      if (!mfaValido) {
        throw new Error('Código de autenticación inválido o expirado');
      }

      // 2. Obtener segmento activo del usuario
      const userSegment = await tx.PV_UserSegments.findFirst({
        where: { userid: parseInt(userid), isactive: true }
      });
      if (!userSegment) {
        throw new Error('No se encontró segmento activo para el usuario');
      }

      // 3. Obtener propuesta y configuración

      const propuesta = await tx.PV_Proposals.findUnique({
        where: { proposalid: parseInt(proposalid) },
        include: {
          PV_VotingConfigurations: {
            include: {
              PV_VotingOptions: { include: { PV_VotingQuestions: true } }
            }
          }
        }
      });
      if (!propuesta || !propuesta.PV_VotingConfigurations[0]) {
        throw new Error('Propuesta no encontrada');
      }
      const config = propuesta.PV_VotingConfigurations[0];
      const ahora = new Date();
      if (ahora < new Date(config.startdate) || ahora > new Date(config.enddate)) {
        throw new Error('La votación no está abierta en este momento');
      }

      // 4. Validar que el usuario no ha votado antes en esta propuesta
      const votoExistente = await tx.PV_Votes.findFirst({
        where: {
          userId: parseInt(userid),
          votingconfigid: config.votingconfigid
        }
      });
      if (votoExistente) {
        throw new Error('Ya has votado en esta propuesta');
      }

      // 5. Obtener clave pública del usuario
      const userKey = await tx.PV_CryptoKeys.findFirst({
        where: { userid: parseInt(userid), status: 'active' },
        orderBy: { createdAt: 'desc' }
      });
      if (!userKey) {
        throw new Error('No se encontró clave pública activa para el usuario');
      }
      const publicKeyPem = decryptWithPassword(userKey.encryptedpublickey, password);

      // 6. Validar respuestas: deben cubrir todas las preguntas y usar textos
      // Extraer preguntas únicas desde las opciones
      const opciones = config.PV_VotingOptions;
      const preguntasMap = {};
      for (const opcion of opciones) {
        if (opcion.PV_VotingQuestions && opcion.PV_VotingQuestions.questionId) {
          preguntasMap[opcion.PV_VotingQuestions.questionId] = opcion.PV_VotingQuestions;
        }
      }
      const preguntas = Object.values(preguntasMap);
      if (!Array.isArray(preguntas) || preguntas.length === 0) {
        throw new Error('No hay preguntas configuradas para esta propuesta');
      }
      // Mapear respuestas por texto
      const respuestasPorPregunta = {};
      for (const ans of answers) {
        if (!ans.question || !ans.option) {
          throw new Error('Cada respuesta debe tener question y option (texto)');
        }
        respuestasPorPregunta[ans.question] = ans.option;
      }
      // Validar que todas las preguntas estén respondidas
      const preguntasFaltantes = preguntas.filter(q => !(q.question in respuestasPorPregunta));
      if (preguntasFaltantes.length > 0) {
        return {
          error: 'Debes responder todas las preguntas',
          missingQuestions: preguntasFaltantes.map(q => q.question)
        };
      }
      // Validar que las opciones existen para cada pregunta
      const opcionesInvalidas = [];
      const resultadosVotos = [];
      for (const pregunta of preguntas) {
        const textoPregunta = pregunta.question;
        const textoOpcion = respuestasPorPregunta[textoPregunta];
        const opcion = opciones.find(
          o => o.questionId === pregunta.questionId && o.optiontext === textoOpcion
        );
        console.log('DEBUG opcion:', opcion);
        if (!opcion) {
          opcionesInvalidas.push({ question: textoPregunta, option: textoOpcion });
          continue;
        }
        if (!('optionid' in opcion)) {
          throw new Error('La opción encontrada no tiene optionid. Objeto: ' + JSON.stringify(opcion));
        }
        // Cifrar el voto
        let encryptedVote;
        try {
          encryptedVote = crypto.publicEncrypt(
            {
              key: publicKeyPem,
              padding: crypto.constants.RSA_PKCS1_OAEP_PADDING
            },
            Buffer.from(JSON.stringify({
              userid,
              optionid: opcion.optionid,
              questionid: pregunta.questionId,
              timestamp: new Date().toISOString()
            }), 'utf8')
          );
        } catch (err) {
          throw new Error('Error cifrando el voto: ' + err.message);
        }
        // Registrar el voto cifrado
        const voto = await tx.PV_Votes.create({
          data: {
            votingconfigid: config.votingconfigid,
            userId: parseInt(userid),
            votercommitment: Buffer.from('dev-commitment'),
            encryptedvote: encryptedVote,
            votehash: Buffer.from(crypto.randomBytes(32)),
            nullifierhash: Buffer.from(crypto.randomBytes(32)),
            votedate: new Date(),
            blockhash: Buffer.from(crypto.randomBytes(32)),
            checksum: Buffer.from(crypto.randomBytes(32)),
            publicResult: opcion.optiontext
          }
        });
        // Actualizar o crear VoteResults (sin questionid, solo por votingconfigid y optionid)
        let voteResult = await tx.PV_VoteResults.findFirst({
          where: {
            votingconfigid: config.votingconfigid,
            optionid: opcion.optionid
          }
        });
        if (voteResult) {
          voteResult = await tx.PV_VoteResults.update({
            where: { resultid: voteResult.resultid },
            data: { votecount: { increment: 1 } }
          });
        } else {
          voteResult = await tx.PV_VoteResults.create({
            data: {
              votingconfigid: config.votingconfigid,
              optionid: opcion.optionid,
              votecount: 1,
              weightedcount: 1,
              lastupdated: new Date(),
              creationDate: new Date(),
              checksum: Buffer.from(crypto.randomBytes(32))
            }
          });
        }
        // DEBUG antes de consultar VotingMetrics
        console.log('DEBUG votingMetric filter:', {
          votingconfigid: config.votingconfigid,
          segmentid: userSegment.segmentid,
          optionid: opcion.optionid
        });
        let votingMetric = await tx.PV_VotingMetrics.findFirst({
          where: {
            votingconfigid: config.votingconfigid,
            segmentid: userSegment.segmentid,
            optionid: opcion.optionid
          }
        });
        let newVoteCounter;
        if (votingMetric) {
          votingMetric = await tx.PV_VotingMetrics.update({
            where: { metricid: votingMetric.metricid },
            data: { voteCounter: { increment: 1 } }
          });
          newVoteCounter = votingMetric.voteCounter + 1;
        } else {
          votingMetric = await tx.PV_VotingMetrics.create({
            data: {
              votingconfigid: config.votingconfigid,
              segmentid: userSegment.segmentid,
              metrictypeId: 1,
              metricvalue: 0,
              voteCounter: 1,
              optionid: opcion.optionid,
              calculateddate: new Date(),
              isactive: true
            }
          });
          newVoteCounter = 1;
        }
        // Calcular el porcentaje y actualizar metricvalue
        const totaldeVotadores = voteResult.votecount;
        const metricValue = (newVoteCounter / totaldeVotadores) * 100;
        await tx.PV_VotingMetrics.update({
          where: { metricid: votingMetric.metricid },
          data: { metricvalue: metricValue, calculateddate: new Date() }
        });
        resultadosVotos.push({
          voteId: voto.voteid,
          selectedOption: opcion.optiontext,
          question: pregunta.question,
          voteDate: voto.votedate,
          votecount: voteResult.votecount,
          segmentid: userSegment.segmentid,
          metricvalue: metricValue
        });
      }
      if (opcionesInvalidas.length > 0) {
        // Mostrar opciones válidas por pregunta
        const opcionesPorPregunta = {};
        for (const pregunta of preguntas) {
          opcionesPorPregunta[pregunta.question] = opciones
            .filter(o => o.questionId === pregunta.questionId)
            .map(o => o.optiontext);
        }
        return {
          error: 'Una o más opciones no son válidas',
          invalidOptions: opcionesInvalidas,
          validOptions: opcionesPorPregunta
        };
      }
      return resultadosVotos;
    });

    // Si la respuesta es un error de validación, devuélvela como error
    if (resultados.error) {
      return res.status(400).json({ success: false, ...resultados });
    }

    return res.status(201).json({
      success: true,
      message: 'Votos registrados exitosamente',
      data: resultados
    });
  } catch (error) {
    console.error('Error al votar:', error.message);
    return res.status(400).json({
      success: false,
      error: error.message
    });
  }
};


