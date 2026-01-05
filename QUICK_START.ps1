# =========================================================================
# QUICK_START.ps1
# Yearly Planner - Simple Startup Script with Enhanced Logging
# =========================================================================
# Quick and easy way to start the application
# For comprehensive checks, use START_ALL.ps1 instead
# =========================================================================
#
# Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
# Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
#
# Role: Relay (DevOps/SRE)
#

param(
    [switch]$OpenBrowser
)

$ErrorActionPreference = "Continue"
$LogFile = Join-Path $PSScriptRoot "quickstart.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logMessage
    if ($Level -eq "ERROR") {
        Write-Host $logMessage -ForegroundColor Red
    } elseif ($Level -eq "WARNING") {
        Write-Host $logMessage -ForegroundColor Yellow
    } else {
        Write-Host $logMessage
    }
}

try {
    Write-Log "=== Quick Start Script Started ===" "INFO"
    Write-Log "Script Root: $PSScriptRoot" "INFO"
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)" "INFO"

    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "  Yearly Planner - Quick Start" -ForegroundColor Cyan
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host ""

    $RepoRoot = $PSScriptRoot
    $BackendDir = Join-Path $RepoRoot "backend"
    $FrontendDir = Join-Path $RepoRoot "frontend"

    Write-Log "Repository Root: $RepoRoot" "INFO"
    Write-Log "Backend Directory: $BackendDir" "INFO"
    Write-Log "Frontend Directory: $FrontendDir" "INFO"

    $BackendPort = 5000
    $FrontendPort = 3000

    # Check for required environment variables
    Write-Host "Checking environment variables..." -ForegroundColor Yellow
    Write-Log "Checking environment variables" "INFO"
    
    $mongoUri = [Environment]::GetEnvironmentVariable("MONGO_URI")
    $jwtSecret = [Environment]::GetEnvironmentVariable("JWT_SECRET")

    if ([string]::IsNullOrWhiteSpace($mongoUri)) {
        Write-Log "MONGO_URI environment variable is not set" "ERROR"
        Write-Host "  [ERROR] MONGO_URI environment variable is not set" -ForegroundColor Red
        Write-Host "  Please set it before starting the application" -ForegroundColor Yellow
        Write-Host "  Example: `$env:MONGO_URI='mongodb://localhost:27017/yearly_planner'" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  See docs/ENVIRONMENT_VARIABLES.md for more information" -ForegroundColor Gray
        Read-Host "Press Enter to exit"
        exit 1
    } else {
        Write-Log "MONGO_URI is set (value hidden for security)" "INFO"
    }

    if ([string]::IsNullOrWhiteSpace($jwtSecret)) {
        Write-Log "JWT_SECRET environment variable is not set" "ERROR"
        Write-Host "  [ERROR] JWT_SECRET environment variable is not set" -ForegroundColor Red
        Write-Host "  Please set it before starting the application" -ForegroundColor Yellow
        Write-Host "  Example: `$env:JWT_SECRET='your-secret-key-here'" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  See docs/ENVIRONMENT_VARIABLES.md for more information" -ForegroundColor Gray
        Read-Host "Press Enter to exit"
        exit 1
    } else {
        Write-Log "JWT_SECRET is set (value hidden for security)" "INFO"
    }

    Write-Host "  [OK] Environment variables found" -ForegroundColor Green
    Write-Host ""

    # Check Node.js
    Write-Host "Checking Node.js..." -ForegroundColor Yellow
    Write-Log "Checking Node.js installation" "INFO"
    try {
        $nodeVersion = node --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Node.js found: $nodeVersion" "INFO"
            Write-Host "  [OK] Node.js $nodeVersion" -ForegroundColor Green
        } else {
            throw "Node.js not found"
        }
    } catch {
        Write-Log "Node.js check failed: $_" "ERROR"
        Write-Host "  [ERROR] Node.js not found. Please install Node.js 18+" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host ""

    # Check if ports are available
    Write-Host "Checking ports..." -ForegroundColor Yellow
    Write-Log "Checking port availability" "INFO"
    function Test-PortFree {
        param([int]$Port)
        try {
            $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
            return (-not $connection)
        } catch {
            Write-Log "Port check error for port $Port : $_" "WARNING"
            return $true
        }
    }

    if (-not (Test-PortFree -Port $BackendPort)) {
        Write-Log "Port $BackendPort is already in use" "WARNING"
        Write-Host "  [WARNING] Port $BackendPort is already in use" -ForegroundColor Yellow
        Write-Host "  Backend may already be running" -ForegroundColor Gray
    } else {
        Write-Log "Port $BackendPort is available" "INFO"
        Write-Host "  [OK] Port $BackendPort is available (Backend)" -ForegroundColor Green
    }

    if (-not (Test-PortFree -Port $FrontendPort)) {
        Write-Log "Port $FrontendPort is already in use" "WARNING"
        Write-Host "  [WARNING] Port $FrontendPort is already in use" -ForegroundColor Yellow
        Write-Host "  Frontend may already be running" -ForegroundColor Gray
    } else {
        Write-Log "Port $FrontendPort is available" "INFO"
        Write-Host "  [OK] Port $FrontendPort is available (Frontend)" -ForegroundColor Green
    }
    Write-Host ""

    # Install dependencies if needed
    Write-Host "Checking dependencies..." -ForegroundColor Yellow
    Write-Log "Checking npm dependencies" "INFO"
    
    if (-not (Test-Path (Join-Path $BackendDir "node_modules"))) {
        Write-Log "Backend node_modules not found, installing dependencies" "INFO"
        Write-Host "  Installing backend dependencies..." -ForegroundColor Yellow
        Push-Location $BackendDir
        try {
            $output = npm install --no-fund --no-audit 2>&1
            Write-Log "Backend npm install output: $output" "INFO"
            if ($LASTEXITCODE -ne 0) {
                Write-Log "Backend npm install failed with exit code $LASTEXITCODE" "ERROR"
                throw "npm install failed"
            }
            Write-Log "Backend dependencies installed successfully" "INFO"
            Write-Host "  [OK] Backend dependencies installed" -ForegroundColor Green
        } catch {
            Write-Log "Backend dependency installation error: $_" "ERROR"
            Write-Host "  [ERROR] Failed to install backend dependencies" -ForegroundColor Red
            Write-Host "  Error: $_" -ForegroundColor Red
            Pop-Location
            Read-Host "Press Enter to exit"
            exit 1
        }
        Pop-Location
    } else {
        Write-Log "Backend dependencies found" "INFO"
        Write-Host "  [OK] Backend dependencies found" -ForegroundColor Green
    }

    if (-not (Test-Path (Join-Path $FrontendDir "node_modules"))) {
        Write-Log "Frontend node_modules not found, installing dependencies" "INFO"
        Write-Host "  Installing frontend dependencies..." -ForegroundColor Yellow
        Push-Location $FrontendDir
        try {
            $output = npm install --no-fund --no-audit 2>&1
            Write-Log "Frontend npm install output: $output" "INFO"
            if ($LASTEXITCODE -ne 0) {
                Write-Log "Frontend npm install failed with exit code $LASTEXITCODE" "ERROR"
                throw "npm install failed"
            }
            Write-Log "Frontend dependencies installed successfully" "INFO"
            Write-Host "  [OK] Frontend dependencies installed" -ForegroundColor Green
        } catch {
            Write-Log "Frontend dependency installation error: $_" "ERROR"
            Write-Host "  [ERROR] Failed to install frontend dependencies" -ForegroundColor Red
            Write-Host "  Error: $_" -ForegroundColor Red
            Pop-Location
            Read-Host "Press Enter to exit"
            exit 1
        }
        Pop-Location
    } else {
        Write-Log "Frontend dependencies found" "INFO"
        Write-Host "  [OK] Frontend dependencies found" -ForegroundColor Green
    }
    Write-Host ""

    # Start Backend
    Write-Host "Starting Backend..." -ForegroundColor Cyan
    Write-Log "Starting backend service" "INFO"
    $backendScript = @"
Set-Location '$BackendDir'
`$env:PORT='$BackendPort'
`$env:NODE_ENV='development'
`$env:CORS_ORIGINS='http://localhost:$FrontendPort'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ' Backend API (Port $BackendPort)' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
npm run dev
"@

    try {
        $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
        if ($pwsh) {
            Write-Log "Starting backend with PowerShell Core" "INFO"
            Start-Process $pwsh.Source -ArgumentList "-NoExit", "-Command", $backendScript
        } else {
            Write-Log "Starting backend with Windows PowerShell" "INFO"
            Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendScript
        }
        Start-Sleep -Seconds 3
        Write-Log "Backend process started" "INFO"
    } catch {
        Write-Log "Failed to start backend: $_" "ERROR"
        Write-Host "  [ERROR] Failed to start backend: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Start Frontend
    Write-Host "Starting Frontend..." -ForegroundColor Cyan
    Write-Log "Starting frontend service" "INFO"
    $frontendScript = @"
Set-Location '$FrontendDir'
`$env:REACT_APP_API_BASE_URL='http://localhost:$BackendPort'
`$env:BROWSER='none'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ' Frontend UI (Port $FrontendPort)' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
npm start
"@

    try {
        if ($pwsh) {
            Write-Log "Starting frontend with PowerShell Core" "INFO"
            Start-Process $pwsh.Source -ArgumentList "-NoExit", "-Command", $frontendScript
        } else {
            Write-Log "Starting frontend with Windows PowerShell" "INFO"
            Start-Process powershell -ArgumentList "-NoExit", "-Command", $frontendScript
        }
        Start-Sleep -Seconds 2
        Write-Log "Frontend process started" "INFO"
    } catch {
        Write-Log "Failed to start frontend: $_" "ERROR"
        Write-Host "  [ERROR] Failed to start frontend: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Host ""
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host "  Application Started!" -ForegroundColor Green
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URLs:" -ForegroundColor White
    Write-Host "  Frontend: http://localhost:$FrontendPort" -ForegroundColor Cyan
    Write-Host "  Backend:  http://localhost:$BackendPort/api/health" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To stop the application, run: .\STOP_ALL.ps1" -ForegroundColor Gray
    Write-Host ""

    if ($OpenBrowser) {
        Start-Sleep -Seconds 2
        try {
            Start-Process "http://localhost:$FrontendPort" | Out-Null
            Write-Log "Browser opened successfully" "INFO"
            Write-Host "Browser opened!" -ForegroundColor Green
        } catch {
            Write-Log "Failed to open browser: $_" "WARNING"
            Write-Host "  [WARNING] Failed to open browser: $_" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "Services are running in separate windows." -ForegroundColor White
    Write-Host "Close those windows to stop the services, or run STOP_ALL.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Log "Quick start script completed successfully" "INFO"
    Write-Host "Log file: $LogFile" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit this window (services will keep running)"

} catch {
    Write-Log "Fatal error in quick start script: $_" "ERROR"
    Write-Log "Error details: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Host ""
    Write-Host "FATAL ERROR: $_" -ForegroundColor Red
    Write-Host "Check $LogFile for details" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}
