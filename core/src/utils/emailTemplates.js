/**
 * Templates de Email para Voto Pura Vida
 * Ejemplos de templates personalizados para diferentes tipos de emails
 */

// Template profesional completo
const PROFESSIONAL_TEMPLATE = {
  subject: '🔐 Voto Pura Vida - Verifica tu cuenta',
  html: `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #0891b2, #0d9488); color: white; text-align: center; padding: 30px; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .code-box { background: #fff; border: 2px dashed #0891b2; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px; }
        .code { font-size: 32px; font-weight: bold; color: #0891b2; letter-spacing: 5px; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        .feature-list { background: #e0f7fa; padding: 15px; border-radius: 8px; margin: 15px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🗳️ Voto Pura Vida</h1>
          <p>¡Bienvenido/a a la plataforma de votación segura!</p>
        </div>
        <div class="content">
          <h2>¡Hola {{firstName}}!</h2>
          <p>Gracias por registrarte en <strong>Voto Pura Vida</strong>. Para completar la verificación de tu cuenta, usa el siguiente código:</p>
          
          <div class="code-box">
            <p style="margin: 0; font-size: 14px; color: #666;">Código de Verificación:</p>
            <div class="code">{{verificationCode}}</div>
            <p style="margin: 10px 0 0 0; font-size: 12px; color: #999;">Este código expira en 15 minutos</p>
          </div>

          <div class="feature-list">
            <p><strong>¿Qué sigue después de verificar?</strong></p>
            <ul style="margin: 10px 0; padding-left: 20px;">
              <li>✅ Tu cuenta será activada inmediatamente</li>
              <li>🔐 Se habilitará la autenticación de dos factores</li>
              <li>🛡️ Tendrás acceso a votaciones seguras</li>
              <li>🗳️ Podrás participar en la democracia digital</li>
            </ul>
          </div>

          <p><strong>🔒 Seguridad:</strong> Tus claves criptográficas RSA-2048 han sido generadas y cifradas con tu contraseña. Solo tú tienes acceso a ellas.</p>
          
          <p style="color: #666; font-size: 14px;">Si no solicitaste este registro, puedes ignorar este mensaje de forma segura.</p>
        </div>
        <div class="footer">
          <p>© 2025 Voto Pura Vida - Plataforma de Votación Democrática Segura</p>
          <p>🇨🇷 Hecho en Costa Rica con ❤️</p>
        </div>
      </div>
    </body>
    </html>
  `,
  text: `
¡Hola {{firstName}}!

Gracias por registrarte en Voto Pura Vida.

Tu código de verificación es: {{verificationCode}}

Este código expira en 15 minutos.

¿Qué sigue después de verificar?
✅ Tu cuenta será activada inmediatamente
🔐 Se habilitará la autenticación de dos factores
🛡️ Tendrás acceso a votaciones seguras
🗳️ Podrás participar en la democracia digital

🔒 Seguridad: Tus claves criptográficas RSA-2048 han sido generadas y cifradas con tu contraseña.

Si no solicitaste este registro, puedes ignorar este mensaje.

Voto Pura Vida - Votación Democrática Segura
© 2025 - Hecho en Costa Rica con ❤️
  `
};

// Template minimalista
const MINIMAL_TEMPLATE = {
  subject: '🔐 Código de verificación',
  html: `
    <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 20px;">
      <h2 style="color: #333;">Código de verificación</h2>
      <p>Hola {{firstName}},</p>
      <div style="background: #f8f9fa; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
        <span style="font-size: 28px; font-weight: bold; color: #0891b2; letter-spacing: 3px;">{{verificationCode}}</span>
      </div>
      <p style="color: #666; font-size: 14px;">Este código expira en 15 minutos.</p>
    </div>
  `,
  text: `
Código de verificación

Hola {{firstName}},

Tu código es: {{verificationCode}}

Este código expira en 15 minutos.
  `
};

// Template oscuro/moderno
const DARK_TEMPLATE = {
  subject: '🌙 Voto Pura Vida - Verificación',
  html: `
    <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #1a1a1a; color: #ffffff; border-radius: 12px; overflow: hidden;">
      <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center;">
        <h1 style="margin: 0; font-size: 28px;">🗳️ Voto Pura Vida</h1>
        <p style="margin: 10px 0 0 0; opacity: 0.9;">Democracia Digital Segura</p>
      </div>
      <div style="padding: 40px;">
        <h2 style="color: #ffffff; margin-top: 0;">¡Hola {{firstName}}! 👋</h2>
        <p style="color: #cccccc; line-height: 1.6;">Tu código de verificación está listo:</p>
        
        <div style="background: #2d2d2d; border: 2px solid #667eea; padding: 25px; text-align: center; margin: 25px 0; border-radius: 12px;">
          <p style="margin: 0; color: #999; font-size: 14px;">CÓDIGO DE VERIFICACIÓN</p>
          <div style="font-size: 36px; font-weight: bold; color: #667eea; letter-spacing: 6px; margin: 10px 0;">{{verificationCode}}</div>
          <p style="margin: 0; color: #999; font-size: 12px;">⏱️ Expira en 15 minutos</p>
        </div>

        <p style="color: #cccccc; font-size: 14px;">Una vez verificado, tendrás acceso completo a la plataforma de votación más segura de Costa Rica.</p>
      </div>
      <div style="background: #0d0d0d; padding: 20px; text-align: center;">
        <p style="margin: 0; color: #666; font-size: 12px;">© 2025 Voto Pura Vida 🇨🇷</p>
      </div>
    </div>
  `,
  text: `
🌙 VOTO PURA VIDA

¡Hola {{firstName}}!

Tu código de verificación: {{verificationCode}}

⏱️ Expira en 15 minutos

Una vez verificado, tendrás acceso completo a la plataforma.

© 2025 Voto Pura Vida 🇨🇷
  `
};

module.exports = {
  PROFESSIONAL_TEMPLATE,
  MINIMAL_TEMPLATE,
  DARK_TEMPLATE
};
