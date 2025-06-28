const { sendVoteMfaEmail } = require('../../src/utils/emailService');
const jwt = require('jsonwebtoken');

// Clave secreta para firmar los JWT (debería estar en .env)
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_firmar_tokens';

/**
 * Endpoint GET para enviar el código MFA por email antes de votar
 * GET /api/orm/send-vote-mfa
 * Header: Authorization: Bearer <token>
 */
module.exports = async function sendVoteMfa(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Método no permitido' });
  }
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token JWT requerido en Authorization' });
  }
  const token = authHeader.replace('Bearer ', '');
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const email = decoded.email;
    const firstName = decoded.nombres || decoded.firstname || email;
    if (!email) {
      return res.status(400).json({ error: 'El JWT no contiene email' });
    }
    const result = await sendVoteMfaEmail(email, firstName);
    if (result.success) {
      return res.status(200).json({ message: 'Código MFA enviado por email', messageId: result.messageId });
    } else {
      return res.status(500).json({ error: result.error });
    }
  } catch (err) {
    console.error('Error enviando MFA para votar:', err);
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }
};
