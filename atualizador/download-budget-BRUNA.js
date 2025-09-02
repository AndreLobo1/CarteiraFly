const api = require('@actual-app/api');

async function main() {
  // Configurações
  const serverURL = 'https://carteira-muiezinha-647499.fly.dev/'; 
  const syncId = '8f5d3fa0-5b3a-4c51-b123-a88bf6dcb6c5'; // Este é o ID correto pra download
  const password = '@Andre0803'; // Sua senha do app web
  const dataDir = './data';

  // Inicializa conexão
  await api.init({
    serverURL,
    password,
    dataDir,
  });

  console.log(`📥 Baixando orçamento...`);
  try {
    // Baixa o orçamento com o Sync ID
    await api.downloadBudget(syncId, {
      password // Se seu orçamento for criptografado
    });
    console.log(`✅ Banco baixado em: ${dataDir}/${syncId}.sqlite`);
  } catch (err) {
    console.error(`❌ Erro ao baixar orçamento:`, err.message);
  } finally {
    await api.shutdown();
  }
}

main().catch(console.error);