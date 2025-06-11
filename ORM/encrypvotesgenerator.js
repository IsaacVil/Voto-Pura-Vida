const { createHash, createCipheriv, createDecipheriv, randomBytes, publicEncrypt } = require('crypto');
const sql = require('mssql');

// Parámetros de conexión SQL Server
const config = {
  user: 'usuario_conexion',
  password: 'TuContraseñaSegura123',
  server: 'localhost',
  database: 'VotoPuraVida',
  options: { encrypt: true, trustServerCertificate: true }
};

// Desencripta la clave privada/pública
function decryptWithPassword(encrypted, password) {
  // Asegura que encrypted es un Buffer
  const buf = Buffer.isBuffer(encrypted) ? encrypted : Buffer.from(encrypted, 'base64');
  const iv = buf.slice(0, 16);
  if (iv.length !== 16) throw new Error('IV inválido');
  const data = buf.slice(16);
  const seed = createHash('sha512').update(password).digest().slice(0, 32);
  const decipher = createDecipheriv('aes-256-cbc', seed, iv);
  return Buffer.concat([
    decipher.update(data),
    decipher.final()
  ]).toString('utf8');
}

async function insertVotes() {
  await sql.connect(config);

  // Obtén todos los usuarios y sus claves
  const users = await sql.query`
    SELECT u.userid, k.encryptedpublickey, k.encryptedprivatekey
    FROM [dbo].[PV_Users] u
    JOIN [dbo].[PV_CryptoKeys] k ON u.userid = k.userid
  `;

  // Obtén todas las votaciones activas
  const votings = await sql.query`SELECT votingconfigid FROM [dbo].[PV_VotingConfigurations]`;

  for (const user of users.recordset) {
    // Usa la contraseña que claramente no deberia de tener uno
    const password = 'holasoylapasswordquenoseguardarianormalmente';

    // Desencripta la clave pública del usuario
    let publicKeyPem;
    try {
      publicKeyPem = decryptWithPassword(user.encryptedpublickey, password);
    } catch (err) {
      console.error(`Error desencriptando la clave pública del usuario ${user.userid}:`, err.message);
      continue;
    }

    for (const voting of votings.recordset) {
      // Genera un voto aleatorio (puedes ajustar el contenido)
      const voteValue = Math.random() < 0.5 ? 'SI' : 'NO';

      // Cifra el voto con la clave pública
      let encryptedVote;
      try {
        encryptedVote = publicEncrypt(
          {
            key: publicKeyPem,
            padding: require('crypto').constants.RSA_PKCS1_OAEP_PADDING
          },
          Buffer.from(voteValue, 'utf8')
        );
      } catch (err) {
        console.error(`Error cifrando el voto para usuario ${user.userid}:`, err.message);
        continue;
      }

      // Decide si el voto será público (10%) o no (90%)
      const isPublic = Math.random() < 0.1;
      const publicResult = isPublic ? voteValue : null;

      // Inserta el voto
      await sql.query`
        INSERT INTO [dbo].[PV_Votes] (
          votingconfigid,
          votercommitment,
          encryptedvote,
          votehash,
          nullifierhash,
          votedate,
          blockhash,
          merkleproof,
          blockchainId,
          checksum,
          userId,
          publicResult
        ) VALUES (
          ${voting.votingconfigid},
          ${randomBytes(32)},
          ${encryptedVote},
          ${randomBytes(32)},
          ${randomBytes(32)},
          GETDATE(),
          ${randomBytes(32)},
          NULL,
          NULL,
          ${randomBytes(32)},
          ${user.userid},
          ${publicResult}
        )
      `;
      console.log(`Voto insertado para usuario ${user.userid} en votación ${voting.votingconfigid} (${isPublic ? 'público' : 'privado'})`);
      console.log('Padding usado:', require('crypto').constants.RSA_PKCS1_OAEP_PADDING);
      console.log('Encrypted vote (base64):', encryptedVote.toString('base64'));
    }
  }

  await sql.close();
}

insertVotes();