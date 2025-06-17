const os = require('os');
const fs = require('fs').promises; 
const { PrismaClient } = require('../../src/generated/prisma');
const { createCipheriv, createHash, randomBytes } = require('crypto');

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

  const { userid, commentData, documentos, password, validadoestructura, validadocontenidoadjunto } = req.body || {};
  const proposalid = commentData?.proposalid;
  const comment = commentData?.comment;
  const reviewedby = commentData?.reviewedby || null;
  const reviewdate = commentData?.reviewdate || null;

  if (!userid || !proposalid || !comment || !password) {
    return res.status(400).json({ error: 'Debe enviar userid, password y commentData con proposalid y comment en el body.' });
  }

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

    // Creamos mediafiles para cada uno de los documentos que recibimos
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
        validadoestructura: doc.validadoestructura, // Este campo simula lo que devolverla el workflow de estructura
        // En un caso real, este campo se llenaria con el resultado del workflow de estructura
        validadocontenidoadjunto: doc.validadocontenidoadjunto, // Este campo simula lo que devolverla el workflow de validez
        // En un caso real, este campo se llenaria con el resultado del workflow de validez
        needtobeencrypted: doc.needtobeencrypted // Este campo indica si el archivo necesita ser encriptado
      };
    }));
    //Hace find del primer name que matchee con el nombre del logtype
    //Son para los logs de inicio y fin de workflow de estructura
    const logTypeRun = await prisma.pV_LogTypes.findFirst({ where: { name: 'Run Workflow Media' } });
    const logTypeEnd = await prisma.pV_LogTypes.findFirst({ where: { name: 'End Workflow Media' } });
    const logSource = await prisma.pV_LogSource.findFirst({ where: { name: 'Workflow' } });

    //Simplemente verifica que existan esos valores, si no, devuelve un error 500 con un mensaje.
    if (!logTypeRun || !logTypeEnd || !logSource) {
      return res.status(500).json({ error: 'No se encontraron los tipos o source de log requeridos.' });
    }

    //Hace find del primer name que matchee con el nombre del logtype
    //Son para los logs de inicio y fin de workflow de validez
    const logTypeRunValidez = await prisma.pV_LogTypes.findFirst({ where: { name: 'Run Workflow Validez' } });
    const logTypeEndValidez = await prisma.pV_LogTypes.findFirst({ where: { name: 'End Workflow Validez' } });
    //Simplemente verifica que existan esos valores, si no, devuelve un error 500 con un mensaje.
    if (!logTypeRunValidez || !logTypeEndValidez) {
      return res.status(500).json({ error: 'No se encontraron los tipos de log requeridos para validez.' });
    }

    // Verifica si el usuario tiene una cryptokey asociada ademas obtiene el keyid en caso de ocupar encriptacion mandarlo al workflow de encriptación
    const userCryptoKey = await prisma.PV_CryptoKeys.findFirst({
      where: { userid: usuario.userid }
    });
    if (!userCryptoKey) {
      throw new Error('No se encontró una cryptokey asociada al usuario.');
    }
    const cryptokeyid = userCryptoKey.keyid;

    //Buscamos el status "pendiente" para el comentario (despues se pondra si fue rechazado o aprobado)
    const statusPendiente = await prisma.pV_ProposasalCommentStatus.findFirst({
      where: { status: "pendiente" }
    });
    if (!statusPendiente) {
      return res.status(400).json({ error: 'No se encontró el status "pendiente".' });
    }

    // Creamos el comentario en la base de datos (no importa si no se acepta solo se pondra status = rechazado)
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


    // Estas variables son para devolver cuales errores ocurrieron para que la API pueda mostrar un mensaje adecuado
    let algunarchivoconerror = false;
    let algunarchivoinvalido = false;
    let algunarchivomalaestructura = false;

    // Se itera por cada archivo que recibimos por la API para verificas su estructura y validez.
    // Si solo uno de ellos falla ocasionara que se rechace el comentario y se devuelva que archivo tiene el error
    for (const archivo of archivosGuardados) {
      const { mediafile, validadoestructura, validadocontenidoadjunto } = archivo;

      // Esto simularia lo que le enviariamos al workflow como parametros (y vamos a simular su respuesta y proceso)
      const workflowParams = {
        mediafileid: mediafile.mediafileid,
        commentid: comentarioCreado.commentid,
        validationLevel: "strict",
        notifyOnFail: true
      };

      // Log de cuando llamamos al workflow de estructura y documentos requeridos
      // Lo asociamos a un tipo de log que indicara que se guareda en cada parte del log
      // asociamos mediafileid, commentid, fecha de inicio del workflow y los parametros que le enviamos.
      await prisma.pV_Logs.create({
        data: {
          description: `Ejecutando Workflow de Verificacion de estructura de documentos para mediafile ${mediafile.mediafileid} con params: ${JSON.stringify(workflowParams)} y si son los documentos requeridos para sustentar el comentario`,
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
          referenceid2: comentarioCreado.commentid,
          checksum: createHash('sha256').update(JSON.stringify(workflowParams)).digest(),
          value1: new Date().toISOString(),
          value2: JSON.stringify(workflowParams),
          PV_LogSeverity: { connect: { logseverityid } },
          PV_LogTypes: { connect: { logtypeid: logTypeRun.logtypeid } },
          PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
        }
      });

      // Log del resultado del workflow de estructura y documentos requeridos (esto lo elegimos en postman para testear facilmente)
      // En un caso real, este resultado vendria del workflow de estructura y documentos requeridos. Y devolvaria este booleano
      let estructuravalidationresult;
      if (validadoestructura === true) {
        estructuravalidationresult = "Validado";
        await prisma.pV_Logs.create({
          data: {
            description: `Workflow de Verificacion de estructura de documentos finalizado exitosamente para mediafile ${mediafile.mediafileid}, ademas cumple con la documentacion requerida para sustentar el comentario`,
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
            referenceid2: comentarioCreado.commentid,
            checksum: createHash('sha256').update(`success-documentacion-requerida-${mediafile.mediafileid}`).digest(),
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
            description: `Workflow de Verificacion de estructura de documentos finalizado exitosamente para mediafile ${mediafile.mediafileid}, pero no cumple con la documentacion requerida para sustentar el comentario`,
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
            referenceid2: comentarioCreado.commentid,
            checksum: createHash('sha256').update(`fail-documentacion-requerida-${mediafile.mediafileid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Fallido",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeEnd.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
        algunarchivomalaestructura = true;
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
          description: `Ejecutando Workflow de Validez para el mediafile ${mediafile.mediafileid} con params: ${JSON.stringify(workflowParamsValidez)}`,
          name: "WorkflowStart",
          posttime: new Date(),
          computer: os.hostname(),
          trace: JSON.stringify({
            workflow: 2,
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
            description: `Workflow de Validez finalizado exitosamente para el mediafile ${mediafile.mediafileid}`,
            name: "WorkflowSuccess",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 2,
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
            description: `Workflow de Validez detectó contenido adjunto RECHAZADO para el mediafile ${mediafile.mediafileid}`,
            name: "WorkflowFailed",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 2,
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
        algunarchivoinvalido = true;
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







      if (archivo.needtobeencrypted) {
        // Busca los logtypes y el severity correcto
        const logTypeRunEncryp = await prisma.pV_LogTypes.findFirst({ where: { name: 'Run Workflow Encryp' } });
        const logTypeEndEncryp = await prisma.pV_LogTypes.findFirst({ where: { name: 'End Workflow Encryp' } });
        const logSeverityWarning = await prisma.pV_LogSeverity.findFirst({ where: { name: 'Warning' } });

        if (!logTypeRunEncryp || !logTypeEndEncryp || !logSeverityWarning) {
          throw new Error('No se encontraron los tipos de log o el severity "Warning" para encriptación.');
        }

        const workflowParamsEncryp = {
          mediafileid: mediafile.mediafileid,
          cryptokeyid: cryptokeyid
        };
        // Aca deberia tambien ir la contraseña pero como es lo que vamos a guardar en el log, no se la daremos.

        // Log de inicio del workflow de encriptación
        await prisma.pV_Logs.create({
          data: {
            description: `Ejecutando Workflow de Encriptación para mediafile ${mediafile.mediafileid}`,
            name: "WorkflowStart",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 3,
              params: workflowParamsEncryp,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: mediafile.mediafileid,
            referenceid2: cryptokeyid,
            checksum: createHash('sha256').update(JSON.stringify(workflowParamsEncryp)).digest(),
            value1: new Date().toISOString(),
            value2: JSON.stringify(workflowParamsEncryp),
            PV_LogSeverity: { connect: { logseverityid: logSeverityWarning.logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeRunEncryp.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });

        // Aqui se le enviaria el hash de la contraseña al workflow de encriptación junto con los otros parámetros necesarios
        const key = createHash('sha512').update(password).digest().slice(0, 32);
        // Claramente no se envia a ningun workflow, pero se esta simulando que hay uno

        // Log de fin del workflow de encriptación
        await prisma.pV_Logs.create({
          data: {
            description: `Workflow de Encriptación finalizado exitosamente para mediafile ${mediafile.mediafileid}`,
            name: "WorkflowSuccess",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              workflow: 3,
              resultado: "Encriptado",
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: mediafile.mediafileid,
            referenceid2: cryptokeyid,
            checksum: createHash('sha256').update(`success-encryp-${mediafile.mediafileid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Encriptado",
            PV_LogSeverity: { connect: { logseverityid: logSeverityWarning.logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeEndEncryp.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      }




      // 6. Crear documento
      const documentoCreado = await prisma.pV_Documents.create({
        data: {
          humanvalidationrequired: aivalidationresult === "Rechazado", // si el documento es rechazado, el campo humanvalidationrequired se guarde como true. Si no, como false
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

    const logTypeFailedCommentReason = await prisma.pV_LogTypes.findFirst({ where: { name: 'Failed Comment Reason' } });
    if (!logTypeFailedCommentReason) {
      return res.status(500).json({ error: 'No se encontró el tipo de log "Failed Comment Reason".' });
    }

    if (algunarchivoconerror) {
      // Si al menos un archivo tiene error, actualiza el comentario a "Rechazado"
      await prisma.pV_ProposalComments.update({
        where: { commentid: comentarioCreado.commentid },
        data: {
          statusid: statusRechazado.statusCommentId,
          reviewdate: new Date()
        }
      });

      if (algunarchivoinvalido && algunarchivomalaestructura) {
        await prisma.pV_Logs.create({
          data: {
            description: `Al menos un archivo tiene error de estructura y contenido adjunto en la propuesta ${propuesta.title}`,
            name: "Error Estructura y Contenido",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              proposalid,
              commentid: comentarioCreado.commentid,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: proposalid,
            referenceid2: comentarioCreado.commentid,
            checksum: createHash('sha256').update(`error-estructura-contenido-${proposalid}-${comentarioCreado.commentid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Error de estructura y contenido",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeFailedCommentReason.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      } else if (algunarchivomalaestructura) {
        await prisma.pV_Logs.create({
          data: {
            description: `Al menos un archivo tiene error de documentacion requerida en la propuesta ${propuesta.title}`,
            name: "Error Documentacion",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              proposalid,
              commentid: comentarioCreado.commentid,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: proposalid,
            referenceid2: comentarioCreado.commentid,
            checksum: createHash('sha256').update(`error-documentacion-${proposalid}-${comentarioCreado.commentid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Error de documentacion requerida",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeFailedCommentReason.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      } else if (algunarchivoinvalido) {
        await prisma.pV_Logs.create({
          data: {
            description: `Al menos un archivo tiene error de contenido adjunto en la propuesta ${propuesta.title}`,
            name: "Error Contenido",
            posttime: new Date(),
            computer: os.hostname(),
            trace: JSON.stringify({
              proposalid,
              commentid: comentarioCreado.commentid,
              usuario: userid,
              timestamp: new Date().toISOString()
            }),
            referenceid1: proposalid,
            referenceid2: comentarioCreado.commentid,
            checksum: createHash('sha256').update(`error-contenido-${proposalid}-${comentarioCreado.commentid}`).digest(),
            value1: new Date().toISOString(),
            value2: "Error de contenido adjunto, rechazado por invalidez",
            PV_LogSeverity: { connect: { logseverityid } },
            PV_LogTypes: { connect: { logtypeid: logTypeFailedCommentReason.logtypeid } },
            PV_LogSource: { connect: { logsourceid: logSource.logsourceid } }
          }
        });
      }
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

    if (algunarchivoconerror) {
      // Recolectar detalles de archivos rechazados
      const archivosEstructura = archivosGuardados
        .filter(a => a.validadoestructura === false)
        .map(a => a.mediafile.mediapath);

      const archivosValidez = archivosGuardados
        .filter(a => a.validadocontenidoadjunto === false)
        .map(a => a.mediafile.mediapath);

      let motivo = '';
      if (archivosEstructura.length && archivosValidez.length) {
        motivo = 'Rechazado por error de documentacion requerida y contenido invalido adjunto';
      } else if (archivosEstructura.length) {
        motivo = 'Rechazado por error de documentacion requerida';
      } else if (archivosValidez.length) {
        motivo = 'Rechazado por error de contenido invalido adjunto';
      }

      return res.status(200).json({
        status: 'rechazado',
        motivo,
        archivosConErrorDocumental: archivosEstructura,
        archivosConErrorValidez: archivosValidez,
        commentid: comentarioCreado.commentid,
        proposalid,
        userid
      });
    } else {
      return res.status(200).json({
        status: 'admitido',
        mensaje: `Se subió con éxito para el usuario ${userid}, propuesta ${proposalid}, commentid ${comentarioCreado.commentid}`,
        commentid: comentarioCreado.commentid,
        proposalid,
        userid
      });
    }

  } catch (err) {
    console.error("Error:", err);
    return res.status(500).json({ error: "Error interno del servidor", details: err.message });
  } finally {
    await prisma.$disconnect();
  }
};