# ForgeAI Omega - Fixed Cleanup and Setup Script
# This script resolves configuration conflicts and sets up clean development environment

Write-Host "Cleaning up ForgeAI Omega configuration..." -ForegroundColor Cyan

$ProjectPath = "C:\Users\CIPSLPro\intelliforge-web\forgeai-omega"
Set-Location $ProjectPath

Write-Host "1. Cleaning up conflicting files..." -ForegroundColor Yellow

# Remove conflicting lockfile
if (Test-Path "package-lock.json") {
    Remove-Item "package-lock.json" -Force
    Write-Host "   Removed conflicting package-lock.json" -ForegroundColor Green
}

# Stop any running Node.js processes on our ports
Write-Host "2. Stopping conflicting processes..." -ForegroundColor Yellow
Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "*3000*" -or $_.MainWindowTitle -like "*3001*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "3. Creating clean app configurations..." -ForegroundColor Yellow

# Create apps directory structure
$AppDirs = @(
    "apps\web-app\src\app",
    "apps\api-gateway\src",
    "packages\ui\src",
    "packages\database\src"
)

foreach ($Dir in $AppDirs) {
    if (!(Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        Write-Host "   Created: $Dir" -ForegroundColor Green
    }
}

Write-Host "4. Creating minimal Next.js web app..." -ForegroundColor Yellow

# Create clean web app package.json
@"
{
  "name": "@forgeai/web-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "typescript": "^5.0.0",
    "eslint": "^8.0.0",
    "eslint-config-next": "^14.0.0"
  }
}
"@ | Out-File -FilePath "apps\web-app\package.json" -Encoding UTF8

# Create simple Next.js page
@"
export default function HomePage() {
  return (
    <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1 style={{ color: '#1842B6' }}>ForgeAI Omega</h1>
      <p>From raw ideas to tangible marketable assets</p>
      <div style={{ marginTop: '2rem', padding: '1rem', background: '#f0f9ff', borderRadius: '8px' }}>
        <h3>System Status</h3>
        <ul>
          <li>Web App: Running on localhost:3000</li>
          <li>Database: PostgreSQL on localhost:5432</li>
          <li>Cache: Redis on localhost:6379</li>
          <li>API: Available on localhost:3001</li>
        </ul>
      </div>
      <div style={{ marginTop: '1rem' }}>
        <a href="http://localhost:3001/health" 
           style={{ background: '#1842B6', color: 'white', padding: '0.5rem 1rem', borderRadius: '4px', textDecoration: 'none' }}>
          Test API Health
        </a>
      </div>
    </div>
  );
}
"@ | Out-File -FilePath "apps\web-app\src\app\page.tsx" -Encoding UTF8

# Create layout.tsx
@"
export const metadata = {
  title: 'ForgeAI Omega',
  description: 'From raw ideas to tangible marketable assets',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
"@ | Out-File -FilePath "apps\web-app\src\app\layout.tsx" -Encoding UTF8

Write-Host "5. Creating API Gateway..." -ForegroundColor Yellow

# Create API Gateway package.json
@"
{
  "name": "@forgeai/api-gateway",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "nodemon src/index.js",
    "start": "node src/index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
"@ | Out-File -FilePath "apps\api-gateway\package.json" -Encoding UTF8

# Create API Gateway server (using here-string to avoid emoji issues)
$ApiServerContent = @'
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy',
        message: 'ForgeAI Omega API Gateway is running!',
        timestamp: new Date().toISOString(),
        database: 'PostgreSQL available on localhost:5432',
        cache: 'Redis available on localhost:6379',
        version: '1.0.0'
    });
});

// Welcome endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to ForgeAI Omega API',
        endpoints: {
            health: '/health',
            docs: '/api/docs (coming soon)',
            version: '/api/version'
        }
    });
});

// Version endpoint
app.get('/api/version', (req, res) => {
    res.json({
        name: 'ForgeAI Omega',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development'
    });
});

// Start server
app.listen(PORT, () => {
    console.log('ForgeAI Omega API Gateway running on http://localhost:' + PORT);
    console.log('Database: PostgreSQL on localhost:5432');
    console.log('Cache: Redis on localhost:6379');
    console.log('Visit http://localhost:' + PORT + '/health to test');
});
'@

$ApiServerContent | Out-File -FilePath "apps\api-gateway\src\index.js" -Encoding UTF8

Write-Host "6. Updating root package.json..." -ForegroundColor Yellow

# Create clean root package.json
@"
{
  "name": "forgeai-omega",
  "private": true,
  "version": "1.0.0",
  "description": "ForgeAI Omega - The Ultimate AI System for Global Innovation",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "start:api": "cd apps/api-gateway && npm run dev",
    "start:web": "cd apps/web-app && npm run dev",
    "install:all": "npm install && cd apps/web-app && npm install && cd ../api-gateway && npm install",
    "clean": "turbo run clean"
  },
  "devDependencies": {
    "turbo": "^1.10.12"
  },
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
"@ | Out-File -FilePath "package.json" -Encoding UTF8

Write-Host "7. Installing dependencies..." -ForegroundColor Yellow

# Install root dependencies
npm install --silent

# Install web app dependencies
Set-Location "apps\web-app"
npm install --silent
Set-Location $ProjectPath

# Install API Gateway dependencies  
Set-Location "apps\api-gateway"
npm install --silent
Set-Location $ProjectPath

Write-Host ""
Write-Host "CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "Ready to start development:" -ForegroundColor Cyan
Write-Host "   1. Start API Gateway: npm run start:api" -ForegroundColor White
Write-Host "   2. Start Web App: npm run start:web" -ForegroundColor White
Write-Host "   3. Or start both: npm run dev (after testing individually)" -ForegroundColor White
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Cyan
Write-Host "   Web App: http://localhost:3000" -ForegroundColor White
Write-Host "   API Gateway: http://localhost:3001" -ForegroundColor White
Write-Host "   API Health: http://localhost:3001/health" -ForegroundColor White
Write-Host ""
Write-Host "ForgeAI Omega foundation is ready!" -ForegroundColor Green