const sql = require('mssql');
const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

module.exports = async (req, res) => {
  // El usuario ya está autenticado por JWT, el email viene en req.user
  const email = req.user.email;

  try {
    await sql.connect(config);
    // Ejecutar el SP solo si el usuario está autenticado y tiene permisos
    const dashboardResult = await sql.query`
      EXEC SP_Dashboard @email = ${email}
    `;
    res.json(dashboardResult.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  } finally {
    try { await sql.close(); } catch {}
  }
};
