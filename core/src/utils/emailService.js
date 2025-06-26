/**
 * Utilitario de Email con Nodemailer
 * Para envío de códigos de verificación calculados (no almacenados)
 */

//Importamos las funciones necesarias
const nodemailer = require('nodemailer');
const crypto = require('crypto');

// Secret para generar códigos (debe estar en .env en producción)
const VERIFICATION_SECRET = process.env.VERIFICATION_SECRET || 'default-secret-change-in-production';


const generateVerificationCode = (email, timestamp = Date.now()) => {
  // Redondeamos a intervalos de 10 minutos, para la validacion de códigos
  const roundedTime = Math.floor(timestamp / 600000) * 600000; 
  
  // Creamos un hash con algunos datos
  const data = `${email}:${roundedTime}:${VERIFICATION_SECRET}`;
  const hash = crypto.createHash('sha256').update(data).digest('hex');
  
  // Usamos el hash para generar un código de 6 dígitos
  const code = parseInt(hash.substring(0, 8), 16) % 1000000;
  
  // Aseguramos que tenga 6 dígitos
  return code.toString().padStart(6, '0');
};


const validateVerificationCode = (email, inputCode, maxAgeMinutes = 30) => {
  const now = Date.now();
  
  // Verificamos los ultimos 3 intervalos de 10 minutos
  const intervals = Math.ceil(maxAgeMinutes / 10);
  
  //Interamos sobre los ultimos 3 intervalos de 10 minutos
  for (let i = 0; i < intervals; i++) {
    //Retrocedemos el tiempo en intervalos de 10 minutos
    const testTime = now - (i * 600000);
    // Generamos el código esperado para este intervalo
    const expectedCode = generateVerificationCode(email, testTime);
    // Comparamos el código esperado con el ingresado
    if (expectedCode === inputCode) {
      console.log(`✅ Código válido en intervalo ${i} (${i * 10} minutos atrás)`);
      return true;
    }
  }
  
  console.log(`❌ Código no encontrado en ${intervals} intervalos`);
  return false;
};

// Configuración del transporter de Nodemailer para enviar emails 
const createTransporter = () => {
  //Configuramos el puerto
  const smtpPort = parseInt(process.env.SMTP_PORT) || 587;
  const isSecure = smtpPort === 465; 
  //Creamos y retornamos el transporter con la configuración adecuada
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: smtpPort,
    secure: isSecure, 
    auth: {
      // Usamos las variables de entorno para las credenciales
      user: process.env.SMTP_EMAIL,
      pass: process.env.SMTP_PASSWORD
    },

    connectionTimeout: 60000, 
    greetingTimeout: 30000,  
    socketTimeout: 60000,     
  
  });
};

// Función para crear el template básico del email de verificación
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

//Funcion para crear el template personalizado
const getVerificationEmailTemplate = (firstName, verificationCode, customTemplate = null) => {
  // Si se proporciona un template personalizado, lo usamos
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
  // Sino usamos el template básico por defecto
  return getBasicVerificationTemplate(firstName, verificationCode);
};

// Función para enviar el email de verificación
const sendVerificationEmail = async (email, firstName, verificationCode, customTemplate = null) => {
  try {
    //Llamamos a las funciones creadas anteriormente
    const transporter = createTransporter();
    const template = getVerificationEmailTemplate(firstName, verificationCode, customTemplate);

    const mailOptions = {
      //Los datos del email
      from: `"Voto Pura Vida" <${process.env.SMTP_EMAIL}>`,
      to: email,
      subject: template.subject,
      html: template.html,
      text: template.text
    };

    //Enviamos el email usando el transporter
    const result = await transporter.sendMail(mailOptions);
    console.log(`✅ Email enviado a ${email}: ${result.messageId}`);
    return { success: true, messageId: result.messageId };

  } catch (error) {
    console.error(`❌ Error enviando email a ${email}:`, error);
    return { success: false, error: error.message };
  }
};

// Validamos que las variables de entorno necesarias esten configuradas
const validateSMTPConfig = () => {
  //Declaramos las variables requeridas
  const required = ['SMTP_EMAIL', 'SMTP_PASSWORD'];
  //Verificamos cuales faltan
  const missing = required.filter(env => !process.env[env]);
  
  if (missing.length > 0) {
    throw new Error(`Variables de entorno faltantes: ${missing.join(', ')}`);
  }
  
  return true;
};

// Exportamos las funciones para que puedan ser usadas en otros archivos
module.exports = {
  generateVerificationCode,
  validateVerificationCode,
  sendVerificationEmail,
  validateSMTPConfig,
  getVerificationEmailTemplate,
  getBasicVerificationTemplate
};
