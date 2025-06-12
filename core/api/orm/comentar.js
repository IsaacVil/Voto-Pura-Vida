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
      logtypeid: log.logtypeid,
      logsourceid: log.logsourceid,
      logseverityid: log.logseverityid,
      value1: log.value1,
      value2: log.value2
    }
  });
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido, solo POST' });
  }

  const { userid, commentData, documentos } = req.body || {};
  const proposalid = commentData?.proposalid;
  const comment = commentData?.comment;
  const statusid = commentData?.statusid;
  const reviewedby = commentData?.reviewedby || null;
  const reviewdate = commentData?.reviewdate || null;

  // Devuelve lo recibido para depuración
  // Puedes comentar o eliminar esto después de probar
  // return res.status(200).json({ recibido: { userid, proposalid, comment, statusid, reviewedby, reviewdate } });

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

    // Guarda el comentario (nombre correcto del modelo)
    // const nuevoComentario = await prisma.pV_ProposalComments.create({
    // data: {
    //    proposalid,
    //    userid,
    //    comment,
    //    commentdate: new Date(),
    //    statusid,
    //    reviewedby,
    //    reviewdate
    //  }
    //});

    // Guarda los documentos asociados, si hay
    const archivosGuardados = await Promise.all(documentos.map(async (doc) => {
      return prisma.pV_mediafiles.create({
        data: {
          mediapath: doc.url,
          sizeMB: doc.size,
          encoding: doc.encoding || null,
          samplerate: doc.samplerate || null,
          languagecode: doc.languagecode || null,
          mediatypeid: doc.mediatypeid || null, // si tienes el tipo, si no omite
          deleted: false,
          lastupdate: new Date(),
          userid: userid
        }
      });
    }));



    return res.status(200).json({
      success: true,
      mediafiles: archivosGuardados
    });

  } catch (err) {
    console.error("Error:", err);
    return res.status(500).json({ error: "Error interno del servidor", details: err.message });
  } finally {
    await prisma.$disconnect();
  }
};