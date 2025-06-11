const { prisma } = require('./src/config/prisma');

async function checkMetrics() {
  try {
    console.log('📊 Checking Voting Metrics...\n');
    
    // Check voting metrics
    const metrics = await prisma.PV_VotingMetrics.findMany({
      where: { votingconfigid: 1 },
      orderBy: { calculateddate: 'desc' }
    });
    
    console.log('📈 Voting Metrics for Configuration 1:');
    metrics.forEach(metric => {
      console.log(`   Metric ID: ${metric.metricid}, Type: ${metric.metrictypeId}, Value: ${metric.metricvalue}, Date: ${metric.calculateddate}`);
    });
    
    // Check recent votes
    const votes = await prisma.PV_Votes.findMany({
      where: { votingconfigid: 1 },
      orderBy: { votedate: 'desc' },
      take: 10
    });
    
    console.log('\n🗳️  Recent Votes for Configuration 1:');
    votes.forEach(vote => {
      console.log(`   Vote ID: ${vote.voteid}, User: ${vote.userId}, Decision: ${vote.publicResult || 'encrypted'}, Date: ${vote.votedate}`);
    });
    
    // Count votes by decision
    const votesByDecision = await prisma.PV_Votes.groupBy({
      by: ['publicResult'],
      where: { votingconfigid: 1 },
      _count: { voteid: true }
    });
    
    console.log('\n📊 Vote Counts by Decision:');
    votesByDecision.forEach(group => {
      console.log(`   ${group.publicResult || 'encrypted'}: ${group._count.voteid} votes`);
    });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

checkMetrics();
