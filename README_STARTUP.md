# Quick Startup Guide

Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com

<!-- Role: Relay (DevOps/SRE) -->

## Quick Start

### Option 1: Direct PowerShell (Recommended)

```powershell
.\QUICK_START.ps1 -OpenBrowser
```

### Option 2: Batch File

Double-click `START_APP.bat` or run:
```cmd
START_APP.bat
```

### Option 3: Comprehensive Startup

```powershell
.\START_ALL.ps1 -Mode dev -OpenBrowser
```

## Prerequisites

1. **Set Environment Variables** (required):
   ```powershell
   $env:MONGO_URI='mongodb://localhost:27017/yearly_planner'
   $env:JWT_SECRET='your-secret-key-here-min-32-characters-long'
   ```

2. **MongoDB** must be running

3. **Node.js 18+** installed

## Application URLs

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000/api/health

## Stop Application

```powershell
.\STOP_ALL.ps1
```

## Troubleshooting

If you get errors:
1. Make sure MongoDB is running
2. Verify environment variables are set (MONGO_URI, JWT_SECRET)
3. Check that ports 3000 and 5000 are not in use
4. Run `.\START_ALL.ps1` for detailed diagnostics

For more information, see:
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
- [docs/ENVIRONMENT_VARIABLES.md](docs/ENVIRONMENT_VARIABLES.md)

