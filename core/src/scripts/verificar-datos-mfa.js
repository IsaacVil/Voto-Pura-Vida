/**
 * Script para verificar y crear datos de prueba para MFA
 */

const { prisma } = require('../../src/config/prisma');

async function verificarDatosMFA() {
  console.log('🔍 Verificando datos de MFA en la base de datos...\n');

  try {
    // 1. Verificar usuarios
    const usuarios = await prisma.PV_Users.findMany({
      take: 5,
      include: {
        PV_UserStatus: true
      }
    });
    console.log(`👥 Usuarios encontrados: ${usuarios.length}`);
    if (usuarios.length > 0) {
      console.log('Primer usuario:', {
        userid: usuarios[0].userid,
        email: usuarios[0].email,
        active: usuarios[0].PV_UserStatus?.active
      });
    }

    // 2. Verificar métodos MFA disponibles
    const metodosMFA = await prisma.PV_MFAMethods.findMany();
    console.log(`\n🔐 Métodos MFA disponibles: ${metodosMFA.length}`);
    metodosMFA.forEach(m => {
      console.log(`  - ${m.methodId}: ${m.name} (${m.description})`);
    });

    // 3. Verificar configuraciones MFA existentes
    const configMFA = await prisma.PV_MFA.findMany({
      include: {
        PV_MFAMethods: true
      }
    });
    console.log(`\n🛡️ Configuraciones MFA existentes: ${configMFA.length}`);

    // 4. Verificar propuestas
    const propuestas = await prisma.PV_Proposals.findMany({
      take: 3,
      include: {
        PV_ProposalStatus: true
      }
    });
    console.log(`\n📋 Propuestas disponibles: ${propuestas.length}`);
    if (propuestas.length > 0) {
      console.log('Primera propuesta:', {
        proposalid: propuestas[0].proposalid,
        title: propuestas[0].title,
        status: propuestas[0].PV_ProposalStatus?.name
      });
    }

    // 5. Verificar configuraciones de votación
    const configVotacion = await prisma.PV_VotingConfigurations.findMany({
      take: 3,
      include: {
        PV_VotingStatus: true
      }
    });
    console.log(`\n🗳️ Configuraciones de votación: ${configVotacion.length}`);

  } catch (error) {
    console.error('❌ Error verificando datos:', error.message);
  }
}

async function crearDatosDePrueba() {
  console.log('\n🛠️ Creando datos de prueba...\n');

  try {
    // Intentar crear un usuario de prueba con MFA
    const testUser = await prisma.PV_Users.findFirst({
      where: { email: 'test@votopuravida.com' }
    });

    if (!testUser) {
      console.log('No se puede crear datos sin esquema completo');
      console.log('Necesitas poblar la BD manualmente o usar datos existentes');
    } else {
      console.log('✅ Usuario de prueba ya existe:', testUser.userid);
    }

  } catch (error) {
    console.error('❌ Error creando datos:', error.message);
  }
}

async function main() {
  await verificarDatosMFA();
  await crearDatosDePrueba();
  
  console.log('\n📝 RECOMENDACIONES:');
  console.log('1. Usar el modo bypass para desarrollo (recomendado)');
  console.log('2. Poblar la BD con datos reales');
  console.log('3. Usar las validaciones con códigos de prueba específicos');
  
  await prisma.$disconnect();
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { verificarDatosMFA };
