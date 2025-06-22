/**
 * Utilidades para manejo de contraseñas y hashing
 * Integración con el sistema existente de llaves criptográficas
 */

const crypto = require('crypto');
const bcrypt = require('bcryptjs');

/**
 * Genera un hash seguro para contraseñas
 * @param {string} password - Contraseña en texto plano
 * @returns {Promise<string>} Hash de la contraseña
 */
async function hashPassword(password) {
  const saltRounds = 12;
  return await bcrypt.hash(password, saltRounds);
}

/**
 * Verifica una contraseña contra su hash
 * @param {string} password - Contraseña en texto plano
 * @param {string} hash - Hash almacenado
 * @returns {Promise<boolean>} True si la contraseña coincide
 */
async function verifyPassword(password, hash) {
  return await bcrypt.compare(password, hash);
}

/**
 * Genera una contraseña temporal segura
 * @param {number} length - Longitud de la contraseña (default: 12)
 * @returns {string} Contraseña temporal
 */
function generateTempPassword(length = 12) {
  const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  let password = '';
  
  for (let i = 0; i < length; i++) {
    password += charset.charAt(Math.floor(Math.random() * charset.length));
  }
  
  return password;
}

/**
 * Valida la fortaleza de una contraseña
 * @param {string} password - Contraseña a validar
 * @returns {object} Resultado de la validación
 */
function validatePasswordStrength(password) {
  const result = {
    isValid: true,
    errors: [],
    score: 0
  };

  // Longitud mínima
  if (password.length < 8) {
    result.isValid = false;
    result.errors.push('Debe tener al menos 8 caracteres');
  } else if (password.length >= 12) {
    result.score += 2;
  } else {
    result.score += 1;
  }

  // Mayúsculas
  if (!/[A-Z]/.test(password)) {
    result.isValid = false;
    result.errors.push('Debe contener al menos una letra mayúscula');
  } else {
    result.score += 1;
  }

  // Minúsculas
  if (!/[a-z]/.test(password)) {
    result.isValid = false;
    result.errors.push('Debe contener al menos una letra minúscula');
  } else {
    result.score += 1;
  }

  // Números
  if (!/\d/.test(password)) {
    result.isValid = false;
    result.errors.push('Debe contener al menos un número');
  } else {
    result.score += 1;
  }

  // Caracteres especiales
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
    result.errors.push('Se recomienda incluir caracteres especiales');
  } else {
    result.score += 2;
  }

  // Patrones comunes (débiles)
  const commonPatterns = [
    /123456/,
    /password/i,
    /qwerty/i,
    /abc123/i,
    /admin/i
  ];

  for (const pattern of commonPatterns) {
    if (pattern.test(password)) {
      result.isValid = false;
      result.errors.push('No debe contener patrones comunes o predecibles');
      break;
    }
  }

  return result;
}

/**
 * Genera un token seguro para reset de contraseña
 * @returns {string} Token seguro
 */
function generateResetToken() {
  return crypto.randomBytes(32).toString('hex');
}

/**
 * Cifra datos usando AES-256-GCM
 * @param {string} data - Datos a cifrar
 * @param {string} password - Contraseña para cifrar
 * @returns {object} Datos cifrados con IV y auth tag
 */
function encryptData(data, password) {
  const algorithm = 'aes-256-gcm';
  const key = crypto.scryptSync(password, 'voto-pura-vida-salt', 32);
  const iv = crypto.randomBytes(16);
  
  const cipher = crypto.createCipher(algorithm, key);
  cipher.setAAD(Buffer.from('voto-pura-vida', 'utf8'));
  
  let encrypted = cipher.update(data, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag();
  
  return {
    encrypted,
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex')
  };
}

/**
 * Descifra datos usando AES-256-GCM
 * @param {object} encryptedData - Datos cifrados con IV y auth tag
 * @param {string} password - Contraseña para descifrar
 * @returns {string} Datos descifrados
 */
function decryptData(encryptedData, password) {
  const algorithm = 'aes-256-gcm';
  const key = crypto.scryptSync(password, 'voto-pura-vida-salt', 32);
  
  const decipher = crypto.createDecipher(algorithm, key);
  decipher.setAAD(Buffer.from('voto-pura-vida', 'utf8'));
  decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
  
  let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}

/**
 * Genera un hash consistente para identificadores únicos
 * @param {string} input - Entrada a hashear
 * @returns {string} Hash SHA-256
 */
function generateConsistentHash(input) {
  return crypto.createHash('sha256').update(input).digest('hex');
}

/**
 * Genera un salt aleatorio
 * @param {number} bytes - Número de bytes (default: 16)
 * @returns {string} Salt en hexadecimal
 */
function generateSalt(bytes = 16) {
  return crypto.randomBytes(bytes).toString('hex');
}

module.exports = {
  hashPassword,
  verifyPassword,
  generateTempPassword,
  validatePasswordStrength,
  generateResetToken,
  encryptData,
  decryptData,
  generateConsistentHash,
  generateSalt
};
