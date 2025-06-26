const sql = require('mssql');
const { decryptWithPassword } = require('../../src/utils/encrypvotesgenerator');

const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

module.exports = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña requeridos' });
  }

  try {
    await sql.connect(config);

    // Buscar usuario y clave privada
    const userResult = await sql.query`
      SELECT u.userid, k.encryptedprivatekey
      FROM PV_Users u
      JOIN PV_CryptoKeys k ON u.userid = k.userid
      WHERE u.email = ${email}
    `;
    if (userResult.recordset.length === 0) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }
    const user = userResult.recordset[0];

    // Validar contraseña desencriptando la clave privada
    try {
      decryptWithPassword(user.encryptedprivatekey, password);
    } catch {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    // Ejecutar el SP solo si la contraseña es válida
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
