/**
 * Endpoint: /api/stored-procedures/crearReporteFinanciero
 * Permite crear un reporte financiero aprobado y con fondos disponibles para una propuesta.
 * Solo para pruebas/desarrollo.
 */


const sql = require('mssql');
const jwt = require('jsonwebtoken');
const { getDbConfig } = require('../../src/config/database');
const config = getDbConfig();

require('dotenv').config();
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_firmar_tokens';

// Helper: Extract userid from JWT
async function getUserIdFromJWT(req) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('No se encontró el token de autenticación en los headers.');
  }
  const token = authHeader.split(' ')[1];
  const decoded = jwt.verify(token, JWT_SECRET);
  const userid = decoded.sub || decoded.userid || decoded.userId || decoded.id;
  if (!userid) throw new Error('El token no contiene userid.');
  return userid;
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST']);
    return res.status(405).json({ error: 'Método no permitido. Solo POST.' });
  }

  const { proposalid, availablefordividends, totalrevenue, totalexpenses, netprofit } = req.body;
  if (!proposalid || !availablefordividends) {
    return res.status(400).json({ error: 'proposalid y availablefordividends son requeridos.' });
  }


  let pool;
  try {
    pool = await sql.connect(config);
    const now = new Date();

    // 1. Insertar reporte financiero aprobado
    const result = await pool.request()
      .input('proposalid', sql.Int, parseInt(proposalid))
      .input('availablefordividends', sql.Decimal(18,2), availablefordividends)
      .input('submitteddate', sql.DateTime, now)
      .input('approveddate', sql.DateTime, now)
      .input('reportperiod', sql.NVarChar(50), 'Prueba')
      .input('totalrevenue', sql.Decimal(18,2), totalrevenue || availablefordividends)
      .input('totalexpenses', sql.Decimal(18,2), totalexpenses || 0)
      .input('netprofit', sql.Decimal(18,2), netprofit || availablefordividends)
      .query(`INSERT INTO PV_FinancialReports
        (proposalid, availablefordividends, submitteddate, approveddate, reportperiod, totalrevenue, totalexpenses, netprofit)
        OUTPUT INSERTED.*
        VALUES (@proposalid, @availablefordividends, @submitteddate, @approveddate, @reportperiod, @totalrevenue, @totalexpenses, @netprofit)`);

    const financialReport = result.recordset[0];

    // 2. Obtener userid del JWT para reportedby
    let reportedby;
    try {
      reportedby = await getUserIdFromJWT(req);
    } catch (err) {
      return res.status(401).json({ error: 'Token inválido o expirado.', details: err.message });
    }

    // 3. Obtener statusid para "Aprobada" (TOP 1)
    const statusResult = await pool.request()
      .input('statusName', sql.VarChar(30), 'Aprobada')
      .query(`SELECT TOP 1 statusid FROM PV_ProposalStatus WHERE name = @statusName ORDER BY statusid ASC`);
    if (!statusResult.recordset.length) {
      throw new Error('No se encontró status "Aprobada" en PV_ProposalStatus');
    }
    const aprobadaStatusId = statusResult.recordset[0].statusid;

    // 4. Obtener un reporttypeId válido (el primero disponible)
    const reportTypeResult = await pool.request()
      .query(`SELECT TOP 1 reportTypeId FROM PV_ReportTypes ORDER BY reportTypeId ASC`);
    if (!reportTypeResult.recordset.length) {
      throw new Error('No hay tipos de reporte en PV_ReportTypes');
    }
    const reporttypeId = reportTypeResult.recordset[0].reportTypeId;

    // 5. Insertar en PV_ProjectMonitoring
    const monitoringDescription = `Creación automática tras reporte financiero. Monto disponible: ${availablefordividends}`;
    const monitoringResult = await pool.request()
      .input('proposalid', sql.Int, parseInt(proposalid))
      .input('reportedby', sql.Int, reportedby)
      .input('reportdate', sql.DateTime, now)
      .input('reporttypeId', sql.Int, reporttypeId)
      .input('description', sql.Text, monitoringDescription)
      .input('evidence', sql.Text, null)
      .input('statusid', sql.Int, aprobadaStatusId)
      .input('reviewedby', sql.Int, null)
      .input('reviewdate', sql.DateTime, null)
      .input('executionPlanId', sql.Int, null)
      .query(`INSERT INTO PV_ProjectMonitoring
        (proposalid, reportedby, reportdate, reporttypeId, description, evidence, statusid, reviewedby, reviewdate, executionPlanId)
        OUTPUT INSERTED.*
        VALUES (@proposalid, @reportedby, @reportdate, @reporttypeId, @description, @evidence, @statusid, @reviewedby, @reviewdate, @executionPlanId)`);

    const monitoringRecord = monitoringResult.recordset[0];

    return res.status(201).json({
      success: true,
      message: 'Reporte financiero y monitoreo creados',
      report: financialReport,
      monitoring: monitoringRecord
    });
  } catch (error) {
    console.error('Error creando reporte financiero o monitoreo:', error);
    return res.status(500).json({ error: 'Error creando reporte financiero o monitoreo', details: error.message });
  } finally {
    if (pool) {
      try { await pool.close(); } catch {}
    }
  }
};
