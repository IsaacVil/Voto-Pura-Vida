/**
 * Utilitario de Email con Nodemailer
 * Para envío de códigos de verificación calculados (no almacenados)
 */

const nodemailer = require('nodemailer');
const crypto = require('crypto');

// Secret para generar códigos (debe estar en .env en producción)
const VERIFICATION_SECRET = process.env.VERIFICATION_SECRET || 'default-secret-change-in-production';


const generateVerificationCode = (email, timestamp = Date.now()) => {
  const roundedTime = Math.floor(timestamp / 300000) * 300000;
  
  const emailHash = crypto.createHash('md5').update(email).digest('hex').substring(0, 8);
  const timeVariation = Math.floor(timestamp / 60000); 
  
  const data = `${email}:${roundedTime}:${emailHash}:${timeVariation}:${VERIFICATION_SECRET}`;
  const hash = crypto.createHash('sha256').update(data).digest('hex');
  
  const hashPart1 = parseInt(hash.substring(0, 8), 16);
  const hashPart2 = parseInt(hash.substring(8, 16), 16);
  const combined = hashPart1 ^ hashPart2; 
  
  // Extraer 6 dígitos del resultado combinado
  const code = Math.abs(combined) % 1000000;
  
  // Asegurar que tenga 6 dígitos
  return code.toString().padStart(6, '0');
};


const validateVerificationCode = (email, inputCode, maxAgeMinutes = 15) => {
  const now = Date.now();
  
  // Verificar códigos de los últimos N intervalos de 5 minutos
  const intervals = Math.ceil(maxAgeMinutes / 5);
  
  for (let i = 0; i < intervals; i++) {
    const testTime = now - (i * 300000); // 5 minutos hacia atrás
    const expectedCode = generateVerificationCode(email, testTime);
    
    if (expectedCode === inputCode) {
      return true;
    }
  }
  
  return false;
};

// Configuración del transporter (usará variables de entorno)
const createTransporter = () => {
  const smtpPort = parseInt(process.env.SMTP_PORT) || 587;
  const isSecure = smtpPort === 465; // SSL para puerto 465, STARTTLS para 587
  
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: smtpPort,
    secure: isSecure, // true para puerto 465 (SSL), false para 587 (STARTTLS)
    auth: {
      user: process.env.SMTP_EMAIL,
      pass: process.env.SMTP_PASSWORD
    },

    connectionTimeout: 60000, 
    greetingTimeout: 30000,  
    socketTimeout: 60000,     
  
  });
};

const getBasicVerificationTemplate = (firstName, verificationCode) => {
  return {
    subject: '🔐 Voto Pura Vida - Verifica tu cuenta',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #0891b2; text-align: center;">🗳️ Voto Pura Vida</h1>
        <h2>¡Hola ${firstName}!</h2>
        <p>Tu código de verificación es:</p>
        <div style="background: #f0f0f0; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
          <span style="font-size: 32px; font-weight: bold; color: #0891b2; letter-spacing: 5px;">${verificationCode}</span>
        </div>
        <p>Este código expira en 15 minutos.</p>
        <p>Si no solicitaste este registro, ignora este mensaje.</p>
        <hr style="margin-top: 30px;">
        <p style="color: #666; font-size: 12px; text-align: center;">© 2025 Voto Pura Vida</p>
      </div>
    `,
    text: `
Hola ${firstName}!

Tu código de verificación es: ${verificationCode}

Este código expira en 15 minutos.

Si no solicitaste este registro, ignora este mensaje.

Voto Pura Vida
    `
  };
};


const getVerificationEmailTemplate = (firstName, verificationCode, customTemplate = null) => {
  if (customTemplate) {
    return {
      subject: customTemplate.subject || '🔐 Verificación de cuenta',
      html: customTemplate.html
        .replace('{{firstName}}', firstName)
        .replace('{{verificationCode}}', verificationCode),
      text: customTemplate.text
        .replace('{{firstName}}', firstName)
        .replace('{{verificationCode}}', verificationCode)
    };
  }
  
  // Usar template básico por defecto
  return getBasicVerificationTemplate(firstName, verificationCode);
};


const sendVerificationEmail = async (email, firstName, verificationCode, customTemplate = null) => {
  try {
    const transporter = createTransporter();
    const template = getVerificationEmailTemplate(firstName, verificationCode, customTemplate);

    const mailOptions = {
      from: `"Voto Pura Vida" <${process.env.SMTP_EMAIL}>`,
      to: email,
      subject: template.subject,
      html: template.html,
      text: template.text
    };

    const result = await transporter.sendMail(mailOptions);
    console.log(`✅ Email enviado a ${email}: ${result.messageId}`);
    return { success: true, messageId: result.messageId };

  } catch (error) {
    console.error(`❌ Error enviando email a ${email}:`, error);
    return { success: false, error: error.message };
  }
};

// Validar configuración SMTP
const validateSMTPConfig = () => {
  const required = ['SMTP_EMAIL', 'SMTP_PASSWORD'];
  const missing = required.filter(env => !process.env[env]);
  
  if (missing.length > 0) {
    throw new Error(`Variables de entorno faltantes: ${missing.join(', ')}`);
  }
  
  return true;
};

module.exports = {
  generateVerificationCode,
  validateVerificationCode,
  sendVerificationEmail,
  validateSMTPConfig,
  getVerificationEmailTemplate,
  getBasicVerificationTemplate
};
