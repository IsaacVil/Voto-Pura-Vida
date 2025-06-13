const os = require('os');
const { PrismaClient } = require('../../src/generated/prisma');
const { createHash } = require('crypto');

const prisma = new PrismaClient();

async function crearLogComentario(log) {
  await prisma.pV_Logs.create({
    data: {
      description: log.description,
      name: log.name,
      posttime: log.posttime,
      computer: log.computer,
      trace: log.trace,
      referenceid1: log.referenceid1,
      referenceid2: log.referenceid2,
      checksum: log.checksum,
      value1: log.value1,
      value2: log.value2,
      logtypeid: log.logtypeid,
      logsourceid: log.logsourceid,
      logseverityid: log.logseverityid
    }
  });
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido, solo POST' });
  }

  const { userid, commentData, documentos, validadoestructura, validadocontenidoadjunto } = req.body || {};
  const proposalid = commentData?.proposalid;
  const comment = commentData?.comment;
  const statusid = commentData?.statusid;
  const reviewedby = commentData?.reviewedby || null;
  const reviewdate = commentData?.reviewdate || null;

  if (!userid || !proposalid || !comment || !statusid) {
    return res.status(400).json({ error: 'Debe enviar userid y commentData con proposalid, comment y statusid en el body.' });
  }

  // Parámetros fijos para los logs
  const logtypeid = 2;
  const logsourceid = 1;
  const logseverityid = 1;

  try {
    // Verifica usuario
    const usuario = await prisma.pV_Users.findUnique({
      where: { userid },
      select: { userid: true, PV_UserStatus: true }
    });
    if (!usuario || !usuario.PV_UserStatus?.active) {
      return res.status(403).json({ error: 'Usuario no encontrado o inactivo.' });
    }

    // Verifica propuesta
    const propuesta = await prisma.pV_Proposals.findUnique({
      where: { proposalid },
      select: { proposalid: true, title: true }
    });
    if (!propuesta) {
      return res.status(404).json({ error: 'Propuesta no encontrada.' });
    }

    const archivosGuardados = await Promise.all((documentos || []).map(async (doc) => {
      const mediafile = await prisma.pV_mediafiles.create({
        data: {
          mediapath: doc.url,
          sizeMB: doc.size,
          encoding: doc.encoding || null,
          samplerate: doc.samplerate || null,
          languagecode: doc.languagecode || null,
          mediatypeid: doc.mediatypeid || null,
          deleted: false,
          lastupdate: new Date(),
          userid: userid
        }
      });
      return {
        mediafile,
        validadoestructura: doc.validadoestructura,
        validadocontenidoadjunto: doc.validadocontenidoadjunto
      };
    }));

    const logTypeRun = await prisma.pV_LogTypes.findFirst({ where: { name: 'Run Workflow Media' } });
    const logTypeEnd = await prisma.pV_LogTypes.findFirst({ where: { name: 'End Workflow Media' } });
    const logSource = await prisma.pV_LogSource.findFirst({ where: { name: 'Workflow' } });

    if (!logTypeRun || !logTypeEnd || !logSource) {
      return res.status(500).json({ error: 'No se encontraron los tipos o source de log requeridos.' });
    }


    const logTypeRunValidez = await prisma.pV_LogTypes.findFirst({ where: { name: 'Run Workflow Validez' } });
    const logTypeEndValidez = await prisma.pV_LogTypes.findFirst({ where: { name: 'End Workflow Validez' } });

    if (!logTypeRunValidez || !logTypeEndValidez) {
      return res.status(500).json({ error: 'No se encontraron los tipos de log requeridos para validez.' });
    }




    const statusPendiente = await prisma.pV_ProposasalCommentStatus.findFirst({
      where: { status: "pendiente" }
    });
    if (!statusPendiente) {
      return res.status(400).json({ error: 'No se encontró el status "pendiente".' });
    }

    const comentarioCreado = await prisma.pV_ProposalComments.create({
      data: {
        comment: comment,
        userid: userid,
        proposalid: proposalid,
        statusid: statusPendiente.statusCommentId,
        reviewedby: null,
        reviewdate: null,
        commentdate: new Date()
      }
    });


    let algunarchivoconerror = false;
    for (const archivo of archivosGuardados) {
      const { mediafile, validadoestructura, validadocontenidoadjunto } = archivo;

      // 1. Simular envío al workflow 1
      const workflowParams = {
        mediafileid: mediafile.mediafileid,
        validationLevel: "strict",
        notifyOnFail: true
      };

      // Log del run del workflow esperando a la respuesta del workflow
      await prisma.pV_Logs.create({
        data: {
          description: `Ejecutando Workflow de Verificacion de estructura de documentos para mediafile ${mediafile.mediafileid} con params: ${JSON.stringify(workflowParams)}`,
          name: "WorkflowStart",
          posttime: new Date(),
          computer: os.hostname(),
          trace: JSON.stringify({
            workflow: 1,
            params: workflowParams,
            usuario: userid,
            timestamp: new Date().toISOString()
          }),
          referenceid1: mediafile.mediafileid,
          referenceid2: null,
          checksum: createHash('sha256').update(JSON.stringify(workflowParams)).digest(),
          value1: new Date().toISOString(),
          value2: JSON.stringify(workflowParams),
          PV_LogSeverity: { connect: { logseverityid } },
          PV_LogTypes: { connect: { logtypeid: logTypeRun.logtypeid } },
          PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
        }
      });

      // 2. Resultado del workflow de estructura
      let estructuravalidationresult;
      if (validadoestructura === true) {
        estructuravalidationresult = "Validado";
        await prisma.pV_Logs.create({
          data: {
            description: `Workflow de Verificacion de estructura de documentos finalizado exitosamente para mediafile ${mediafile.mediafileid}`,
            name: "WorkflowSuccess",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 1,
              resultado: estructuravalidationresult,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: mediafile.mediafileid,
            referenceid2: null,
            checksum: createHash('sha256').update(`success-estructura-${mediafile.mediafileid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Exitoso",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeEnd.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      } else {
        estructuravalidationresult = "Rechazado";
        await prisma.pV_Logs.create({
          data: {
            description: `Workflow de Verificacion de estructura de documentos detecto fallos para mediafile ${mediafile.mediafileid}`,
            name: "WorkflowFailed",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 1,
              resultado: estructuravalidationresult,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: mediafile.mediafileid,
            referenceid2: null,
            checksum: createHash('sha256').update(`fail-estructura-${mediafile.mediafileid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Fallido",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeEnd.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      }

      // 3. Log de inicio de workflow de validez
      const workflowParamsValidez = {
        mediafileid: mediafile.mediafileid,
        commentid: comentarioCreado.commentid,
        proposalid: proposalid,
        validationLevel: "strict",
        notifyOnFail: true
      };

      await prisma.pV_Logs.create({
        data: {
          description: `Ejecutando Workflow de Validez para mediafile ${mediafile.mediafileid} con params: ${JSON.stringify(workflowParamsValidez)}`,
          name: "WorkflowStart",
          posttime: new Date(),
          computer: os.hostname(),
          trace: JSON.stringify({
            workflow: 1,
            params: workflowParamsValidez,
            usuario: userid,
            timestamp: new Date().toISOString()
          }),
          referenceid1: mediafile.mediafileid,
          referenceid2: comentarioCreado.commentid,
          checksum: createHash('sha256').update(JSON.stringify(workflowParamsValidez)).digest(),
          value1: new Date().toISOString(),
          value2: JSON.stringify(workflowParamsValidez),
          PV_LogSeverity: { connect: { logseverityid } },
          PV_LogTypes: { connect: { logtypeid: logTypeRunValidez.logtypeid } },
          PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
        }
      });

      // 4. Resultado del workflow de validez (contenido adjunto)
      let contenidoValidationResult;
      if (validadocontenidoadjunto === true) {
        contenidoValidationResult = "Validado";
        await prisma.pV_Logs.create({
          data: {
            description: `Workflow de Validez finalizado exitosamente para mediafile ${mediafile.mediafileid}`,
            name: "WorkflowSuccess",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 1,
              resultado: contenidoValidationResult,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: mediafile.mediafileid,
            referenceid2: comentarioCreado.commentid,
            checksum: createHash('sha256').update(`success-validez-${mediafile.mediafileid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Exitoso",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeEndValidez.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      } else {
        contenidoValidationResult = "Rechazado";
        await prisma.pV_Logs.create({
          data: {
            description: `Workflow de Validez detectó contenido adjunto RECHAZADO para mediafile ${mediafile.mediafileid}`,
            name: "WorkflowFailed",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 1,
              resultado: contenidoValidationResult,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: mediafile.mediafileid,
            referenceid2: comentarioCreado.commentid,
            checksum: createHash('sha256').update(`fail-validez-${mediafile.mediafileid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Rechazado",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeEndValidez.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      }

      // 5. Determinar estado final del documento
      let aivalidationstatus, aivalidationresult;
      if (contenidoValidationResult === "Validado" && estructuravalidationresult === "Validado") {
        aivalidationstatus = "Completado";
        aivalidationresult = "Validado";
      } else {
        aivalidationstatus = "Completado";
        aivalidationresult = "Rechazado";
        algunarchivoconerror = true;
      }

      // 6. Crear documento
      const documentoCreado = await prisma.pV_Documents.create({
        data: {
          humanvalidationrequired: false,
          aivalidationstatus: aivalidationstatus,
          aivalidationresult: aivalidationresult,
          documenthash: createHash('sha256')
            .update(`${mediafile.mediafileid}-${proposalid}-${userid}`)
            .digest(),
          PV_mediafiles: { connect: { mediafileid: mediafile.mediafileid } },
          version: 1
        }
      });

      await prisma.pV_proposalCommentDocuments.create({
        data: {
          commentId: comentarioCreado.commentid,
          documentId: documentoCreado.documentid
        }
      });
    }

    const statusRechazado = await prisma.pV_ProposasalCommentStatus.findFirst({
      where: { status: "Rechazado" }
    });
    if (!statusRechazado) {
      return res.status(400).json({ error: 'No se encontró el status "Rechazado".' });
    }

    const statusAprobado = await prisma.pV_ProposasalCommentStatus.findFirst({
      where: { status: "Aprobado" }
    });
    if (!statusAprobado) {
      return res.status(400).json({ error: 'No se encontró el status "Aprobado".' });
    }

    if (algunarchivoconerror) {
      // Si al menos un archivo tiene error, actualiza el comentario a "Rechazado"
      await prisma.pV_ProposalComments.update({
        where: { commentid: comentarioCreado.commentid },
        data: {
          statusid: statusRechazado.statusCommentId, // <-- Cambiado aquí
          reviewdate: new Date()
        }
      });
    }
    else {
      // Si todo está bien, actualiza el comentario a "Aprobado"
      await prisma.pV_ProposalComments.update({
        where: { commentid: comentarioCreado.commentid },
        data: {
          statusid: statusAprobado.statusCommentId, // <-- Cambiado aquí
          reviewdate: new Date() 
        }
      });
    }

    // Si todo sale bien, responde OK
    return res.status(200).json(algunarchivoconerror);

  } catch (err) {
    console.error("Error:", err);
    return res.status(500).json({ error: "Error interno del servidor", details: err.message });
  } finally {
    await prisma.$disconnect();
  }
};