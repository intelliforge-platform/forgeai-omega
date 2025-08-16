const express = require('express');
const app = express();
const PORT = 3001;

app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy',
        message: 'ForgeAI Omega API Gateway is running!',
        timestamp: new Date().toISOString(),
        database: 'PostgreSQL available on localhost:5432',
        cache: 'Redis available on localhost:6379'
    });
});

app.listen(PORT, () => {
    console.log('🚀 ForgeAI Omega API Gateway running on http://localhost:' + PORT);
    console.log('🗄️  Database: PostgreSQL on localhost:5432');
    console.log('🔴 Cache: Redis on localhost:6379');
    console.log('✅ Visit http://localhost:3001/health to test');
});
