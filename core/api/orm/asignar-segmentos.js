/**
 * Endpoint para asignar segmentos a un usuario autenticado (por JWT)
 * POST /api/orm/asignar-segmentos
 * Body: { segmentids: number[] }
 * Protegido: requiere autenticación
 */
const { prisma } = require('../../src/config/prisma');

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido. Solo POST.' });
  }
  const userid = req.user && req.user.userId;
  const { segmentnames } = req.body;
  if (!userid || !Array.isArray(segmentnames) || segmentnames.length === 0) {
    // Si no se envían nombres, mostrar los disponibles
    const allSegments = await prisma.PV_PopulationSegments.findMany({ select: { segmentid: true, name: true } });
    return res.status(400).json({
      error: 'Faltan datos requeridos: segmentnames[] (y JWT válido)',
      availableSegments: allSegments
    });
  }
  try {
    // Buscar los segmentos por nombre
    const foundSegments = await prisma.PV_PopulationSegments.findMany({
      where: { name: { in: segmentnames } },
      select: { segmentid: true, name: true }
    });
    if (foundSegments.length !== segmentnames.length) {
      const allSegments = await prisma.PV_PopulationSegments.findMany({ select: { segmentid: true, name: true } });
      return res.status(400).json({
        error: 'Uno o más nombres de segmento no son válidos',
        availableSegments: allSegments
      });
    }
    // Desactivar todos los segmentos actuales del usuario
    await prisma.PV_UserSegments.updateMany({
      where: { userid: parseInt(userid) },
      data: { isactive: false }
    });
    // Asignar los nuevos segmentos
    const asignados = [];
    for (const seg of foundSegments) {
      const existente = await prisma.PV_UserSegments.findFirst({
        where: { userid: parseInt(userid), segmentid: seg.segmentid }
      });
      if (existente) {
        await prisma.PV_UserSegments.update({
          where: { usersegmentid: existente.usersegmentid },
          data: { isactive: true }
        });
        asignados.push(seg.name);
      } else {
        await prisma.PV_UserSegments.create({
          data: { userid: parseInt(userid), segmentid: seg.segmentid, isactive: true }
        });
        asignados.push(seg.name);
      }
    }
    return res.status(200).json({ success: true, message: 'Segmentos asignados', asignados });
  } catch (error) {
    console.error('Error asignando segmentos:', error.message);
    return res.status(500).json({ success: false, error: error.message });
  }
};
