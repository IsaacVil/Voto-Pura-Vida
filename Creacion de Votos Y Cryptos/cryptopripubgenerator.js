const { generateKeyPairSync, createHash, createCipheriv, randomBytes } = require('crypto');
const sql = require('mssql');

const config = {
  user: 'sa',
  password: 'VotoPuraVida123#',
  server: 'localhost',      
  port: 14333,              
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

// Función para cifrar y concatenar IV (Vector de inicializacion) al inicio, este vector es necesario para el descifrado porque da aleatoriedad al cifrado
// El concatenarlo es una practica común para que el descifrado y recomendada para la criptografía simétrica
// El IV se asegura que se cifre el mismo dato con la misma clave y el resultado cifrado sea diferente cada vez
function encryptWithPassword(data, password) {
  const seed = createHash('sha512').update(password).digest().slice(0, 32);
  const iv = randomBytes(16);
  const cipher = createCipheriv('aes-256-cbc', seed, iv); // Aca ciframos la seed para luego usarla de hash para cifrar el dato (ya sea private o public key)
  const encrypted = Buffer.concat([
    cipher.update(data, 'utf8'),
    cipher.final()
  ]);
  // Concatenar IV + encrypted
  return Buffer.concat([iv, encrypted]);
}

// Función para generar y encriptar claves para un usuario
function generateAndEncryptKeys(password) {
  const { publicKey, privateKey } = generateKeyPairSync('rsa', { modulusLength: 2048 }); // Genera un par de claves RSA de 2048 bits

  const encryptedPrivateKey = encryptWithPassword(privateKey.export({ type: 'pkcs8', format: 'pem' }), password); // Llamamos a la funcion encriptadora y encriptamos la clave privada del par que generamos

  const encryptedPublicKey = encryptWithPassword(publicKey.export({ type: 'spki', format: 'pem' }), password); // Llamamos a la funcion desencriptadora y encriptamos la clave privada del par que generamos

  return {encryptedPublicKey,encryptedPrivateKey}; // Las devolvemos listas para guardar en la base de datos
}

async function processAllUsers() {
  try {
    await sql.connect(config);
    // Obtén todos los usuarios
    const result = await sql.query`SELECT userid FROM [dbo].[PV_Users]`;

    for (const row of result.recordset) {
      // Usa una contraseña predeterminada para todos (solo para pruebas)
      const userPassword = 'holasoylapasswordquenoseguardarianormalmente';
      const keys = generateAndEncryptKeys(userPassword);

      await sql.query`
        INSERT INTO [dbo].[PV_CryptoKeys] (
          encryptedpublickey,
          encryptedprivatekey,
          createdAt,
          userid,
          organizationid,
          expirationdate,
          status
        ) VALUES (
          ${keys.encryptedPublicKey},
          ${keys.encryptedPrivateKey},
          GETDATE(),
          ${row.userid},
          NULL,
          DATEADD(year, 1, GETDATE()),
          'active'
        )
      `;
      console.log(`Claves insertadas para usuario ${row.userid}`);
    }
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await sql.close();
  }
}

processAllUsers();