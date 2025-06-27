/**
 * Endpoint para votar - SOLO POST para registrar votos
 * Simplificado al máximo para desarrollo
 */
const { prisma, executeTransaction } = require('../../src/config/prisma');
const crypto = require('crypto');

module.exports = async (req, res) => {
  // Solo aceptar POST (votar)
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido. Solo POST para votar.' });
  }

  // Obtener userid del token JWT (ya verificado por middleware)
  const userid = req.user.userId;
  const { proposalid, optionid, questionid, mfaCode } = req.body;

  // Validar que tenemos todos los datos necesarios (userid ya viene del token)
  if (!proposalid || !optionid || !questionid || !mfaCode) {
    return res.status(400).json({
      error: 'Faltan datos requeridos: proposalid, optionid, questionid, mfaCode'
    });
  }

  try {
    const resultado = await executeTransaction(async (tx) => {
      
      // 1. Verificar que el usuario existe y está activo
      const usuario = await tx.PV_Users.findUnique({
        where: { userid: parseInt(userid) },
        include: { PV_UserStatus: true }
      });

      if (!usuario || !usuario.PV_UserStatus?.active) {
        throw new Error('Usuario no encontrado o inactivo');
      }

      // 2. MFA simple para desarrollo (código fijo)
      if (mfaCode !== '123456') {
        throw new Error('Código de autenticación inválido');
      }

      // 3. Verificar que la propuesta y opción existen
      const propuesta = await tx.PV_Proposals.findUnique({
        where: { proposalid: parseInt(proposalid) },
        include: {
          PV_VotingConfigurations: {
            include: {
              PV_VotingOptions: {
                where: {
                  optionid: parseInt(optionid),
                  questionId: parseInt(questionid)
                },
                include: { PV_VotingQuestions: true }
              }
            }
          }
        }
      });

      if (!propuesta || !propuesta.PV_VotingConfigurations[0]) {
        throw new Error('Propuesta no encontrada');
      }

      const config = propuesta.PV_VotingConfigurations[0];
      const opcion = config.PV_VotingOptions[0];

      if (!opcion) {
        throw new Error('Opción de voto no válida');
      }

      // 4. Verificar que la votación está abierta
      const ahora = new Date();
      if (ahora < new Date(config.startdate) || ahora > new Date(config.enddate)) {
        throw new Error('La votación no está abierta en este momento');
      }

      // 5. Verificar que el usuario no ha votado antes en esta propuesta
      const votoExistente = await tx.PV_Votes.findFirst({
        where: {
          userId: parseInt(userid),
          votingconfigid: config.votingconfigid
        }
      });

      if (votoExistente) {
        throw new Error('Ya has votado en esta propuesta');
      }

      // 6. Registrar el voto con datos simplificados
      const voto = await tx.PV_Votes.create({
        data: {
          votingconfigid: config.votingconfigid,
          userId: parseInt(userid),
          votercommitment: Buffer.from('dev-commitment'),
          encryptedvote: Buffer.from(JSON.stringify({
            userid,
            optionid,
            timestamp: new Date().toISOString()
          })),
          votehash: Buffer.from(crypto.randomBytes(32)),
          nullifierhash: Buffer.from(crypto.randomBytes(32)),
          votedate: new Date(),
          blockhash: Buffer.from(crypto.randomBytes(32)),
          checksum: Buffer.from(crypto.randomBytes(32)),
          publicResult: opcion.optiontext
        }
      });

      return {
        voteId: voto.voteid,
        selectedOption: opcion.optiontext,
        question: opcion.PV_VotingQuestions.question,
        voteDate: voto.votedate
      };
    });

    return res.status(201).json({
      success: true,
      message: 'Voto registrado exitosamente',
      data: resultado
    });

  } catch (error) {
    console.error('Error al votar:', error.message);
    return res.status(400).json({
      success: false,
      error: error.message
    });
  }
};


