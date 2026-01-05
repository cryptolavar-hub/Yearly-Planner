# =========================================================================
# START_ALL.ps1
# Yearly Planner - Automated Startup Script with Pre-flight Checks
# =========================================================================
# This script:
# 1. Runs verification checks (dependencies + configuration)
# 2. Runs optional pre-launch checks (tests/build) when requested
# 3. Starts backend + frontend if checks pass
# =========================================================================
#
# Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
# Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
#
# Role: Relay (DevOps/SRE)
#

[CmdletBinding()]
param(
    [ValidateSet("dev", "prelaunch")]
    [string]$Mode = "dev",

    [switch]$OpenBrowser
)

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "  Yearly Planner - START ALL (PowerShell)" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0
$WarningCount = 0

$RepoRoot = $PSScriptRoot
$BackendDir = Join-Path $RepoRoot "backend"
$FrontendDir = Join-Path $RepoRoot "frontend"
$DocsDir = Join-Path $RepoRoot "docs"

$BackendPort = 5000
$FrontendPort = 3000

function Write-DocHint {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
    Write-Host "Read: docs/DEPLOYMENT.md" -ForegroundColor Gray
    Write-Host "Read: docs/ENVIRONMENT_VARIABLES.md" -ForegroundColor Gray
    Write-Host "Read: docs/TESTING_REPORT.md" -ForegroundColor Gray
}

function Test-PortFree {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return (-not $connection)
}

function Test-ServiceListening {
    param(
        [int]$Port,
        [int]$MaxAttempts = 10,
        [int]$WaitSeconds = 2
    )
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        $connection = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
        if ($connection) { return $true }
        Start-Sleep -Seconds $WaitSeconds
    }
    return $false
}

function Ensure-NpmDeps {
    param(
        [string]$WorkingDir,
        [string]$Label
    )

    if (-not (Test-Path (Join-Path $WorkingDir "package.json"))) {
        Write-Host "  [ERROR] Missing package.json in $Label ($WorkingDir)" -ForegroundColor Red
        return $false
    }

    if (Test-Path (Join-Path $WorkingDir "node_modules")) {
        Write-Host "  [OK] npm dependencies present for $Label" -ForegroundColor Green
        return $true
    }

    Write-Host "  [INFO] Installing npm dependencies for $Label (first run)..." -ForegroundColor Yellow
    Push-Location $WorkingDir
    try {
        & npm install --no-fund --no-audit
        if ($LASTEXITCODE -ne 0) { return $false }
        return $true
    } finally {
        Pop-Location
    }
}

function Get-PwshExe {
    $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return "powershell"
}

function Start-ServiceInWindow {
    param(
        [string]$Title,
        [string]$WorkingDir,
        [string]$Command,
        [hashtable]$Env = @{}
    )

    Write-Host "Starting: $Title" -ForegroundColor Cyan
    Write-Host "  Directory: $WorkingDir" -ForegroundColor Gray
    Write-Host "  Command: $Command" -ForegroundColor Gray

    $envLines = ""
    foreach ($k in $Env.Keys) {
        $v = $Env[$k]
        $escaped = $v -replace "'", "''"
        $envLines += "`$env:$k='$escaped'`n"
    }

    $scriptBlock = @"
Set-Location '$WorkingDir'
$envLines
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ' $Title' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
$Command
"@

    $shell = Get-PwshExe
    Start-Process $shell -ArgumentList "-NoExit", "-Command", $scriptBlock
    Start-Sleep -Seconds 2
}

# =========================================================================
# PHASE 1: PRE-FLIGHT VERIFICATION CHECKS
# =========================================================================

Write-Host "PHASE 1: Running Pre-flight Verification Checks..." -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Gray
Write-Host ""

# Check 1: Working directory structure
Write-Host "[1/9] Checking required directories..." -ForegroundColor White
if (-not (Test-Path $BackendDir)) { Write-Host "  [ERROR] Missing: backend/" -ForegroundColor Red; $ErrorCount++ } else { Write-Host "  [OK] Found: backend/" -ForegroundColor Green }
if (-not (Test-Path $FrontendDir)) { Write-Host "  [ERROR] Missing: frontend/" -ForegroundColor Red; $ErrorCount++ } else { Write-Host "  [OK] Found: frontend/" -ForegroundColor Green }
if (-not (Test-Path $DocsDir)) { Write-Host "  [ERROR] Missing: docs/" -ForegroundColor Red; $ErrorCount++ } else { Write-Host "  [OK] Found: docs/" -ForegroundColor Green }
Write-Host ""

# Check 2: Required docs (so we can direct user)
Write-Host "[2/9] Checking required docs..." -ForegroundColor White
$DeployDoc = Join-Path $DocsDir "DEPLOYMENT.md"
$EnvDoc = Join-Path $DocsDir "ENVIRONMENT_VARIABLES.md"
$TestDoc = Join-Path $DocsDir "TESTING_REPORT.md"
foreach ($f in @($DeployDoc, $EnvDoc, $TestDoc)) {
    if (Test-Path $f) {
        Write-Host "  [OK] Found: $(Split-Path $f -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Missing: $(Split-Path $f -Leaf)" -ForegroundColor Yellow
        $WarningCount++
    }
}
Write-Host ""

# Check 3: Node.js
Write-Host "[3/9] Checking Node.js..." -ForegroundColor White
try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $nodeVersion -match "v(\d+)\.") {
        $major = [int]$Matches[1]
        if ($major -ge 18) {
            Write-Host "  [OK] Node.js $nodeVersion (recommended: 18+)" -ForegroundColor Green
        } else {
            Write-Host "  [WARNING] Node.js $nodeVersion detected (recommended: 18+)" -ForegroundColor Yellow
            $WarningCount++
        }
    } else {
        Write-Host "  [ERROR] Node.js not found" -ForegroundColor Red
        $ErrorCount++
    }
} catch {
    Write-Host "  [ERROR] Node.js not available: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# Check 4: npm
Write-Host "[4/9] Checking npm..." -ForegroundColor White
try {
    $npmVersion = npm --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] npm $npmVersion" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] npm not found" -ForegroundColor Red
        $ErrorCount++
    }
} catch {
    Write-Host "  [ERROR] npm not available: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# Check 5: Required env vars (backend)
Write-Host "[5/9] Checking required environment variables..." -ForegroundColor White
$requiredEnv = @("MONGO_URI", "JWT_SECRET")
foreach ($name in $requiredEnv) {
    $val = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($val)) {
        Write-Host "  [ERROR] Missing env var: $name" -ForegroundColor Red
        $ErrorCount++
    } else {
        Write-Host "  [OK] Found env var: $name" -ForegroundColor Green
    }
}
if ($ErrorCount -gt 0) {
    Write-Host ""
    Write-DocHint "Environment configuration is incomplete."
}
Write-Host ""

# Check 6: Port availability
Write-Host "[6/9] Checking port availability..." -ForegroundColor White
foreach ($port in @($BackendPort, $FrontendPort)) {
    if (Test-PortFree -Port $port) {
        Write-Host "  [OK] Port $port is available" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Port $port is already in use" -ForegroundColor Yellow
        $WarningCount++
    }
}
Write-Host ""

# Check 7: Ensure npm deps
Write-Host "[7/9] Checking/installing npm dependencies..." -ForegroundColor White
if (-not (Ensure-NpmDeps -WorkingDir $BackendDir -Label "backend")) {
    Write-Host "  [ERROR] Failed to install backend dependencies" -ForegroundColor Red
    $ErrorCount++
    Write-DocHint "Backend dependency installation failed."
}
if (-not (Ensure-NpmDeps -WorkingDir $FrontendDir -Label "frontend")) {
    Write-Host "  [ERROR] Failed to install frontend dependencies" -ForegroundColor Red
    $ErrorCount++
    Write-DocHint "Frontend dependency installation failed."
}
Write-Host ""

# Check 8: Pre-launch tasks (optional, enforced in prelaunch mode)
Write-Host "[8/9] Pre-launch verification..." -ForegroundColor White
if ($Mode -eq "prelaunch") {
    Write-Host "  Mode=prelaunch: running tests/build before starting services" -ForegroundColor Yellow

    Push-Location $BackendDir
    try {
        Write-Host "  [INFO] backend: npm run lint" -ForegroundColor Gray
        & npm run lint
        if ($LASTEXITCODE -ne 0) { throw "backend lint failed" }

        Write-Host "  [INFO] backend: npm test" -ForegroundColor Gray
        & npm test
        if ($LASTEXITCODE -ne 0) { throw "backend tests failed" }
    } catch {
        Write-Host "  [ERROR] Pre-launch backend checks failed: $($_.Exception.Message)" -ForegroundColor Red
        $ErrorCount++
    } finally {
        Pop-Location
    }

    Push-Location $FrontendDir
    try {
        Write-Host "  [INFO] frontend: npm run build" -ForegroundColor Gray
        & npm run build
        if ($LASTEXITCODE -ne 0) { throw "frontend build failed" }

        Write-Host "  [INFO] frontend: npm test (CI, non-interactive)" -ForegroundColor Gray
        $env:CI = "true"
        & npm test -- --watchAll=false
        if ($LASTEXITCODE -ne 0) { throw "frontend tests failed" }
    } catch {
        Write-Host "  [ERROR] Pre-launch frontend checks failed: $($_.Exception.Message)" -ForegroundColor Red
        $ErrorCount++
    } finally {
        Remove-Item Env:CI -ErrorAction SilentlyContinue
        Pop-Location
    }
} else {
    Write-Host "  Mode=dev: skipping tests/build (run with -Mode prelaunch to enforce)" -ForegroundColor Gray
}
Write-Host ""

# Check 9: Summary
Write-Host "[9/9] Verification summary" -ForegroundColor White
Write-Host "  Errors:   $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host "  Warnings: $WarningCount" -ForegroundColor $(if ($WarningCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($ErrorCount -gt 0) {
    Write-Host "==========================================================================" -ForegroundColor Red
    Write-Host "  VERIFICATION FAILED - Cannot start services" -ForegroundColor Red
    Write-Host "==========================================================================" -ForegroundColor Red
    Write-Host ""
    Write-DocHint "Fix the errors above, then run START_ALL.ps1 again."
    Read-Host "Press Enter to exit"
    exit 1
}

if ($WarningCount -gt 0) {
    $response = Read-Host "Warnings detected. Continue anyway? (y/n)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Startup cancelled by user." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "==========================================================================" -ForegroundColor Green
Write-Host "  CHECKS PASSED - Starting services..." -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Green
Write-Host ""

# =========================================================================
# PHASE 2: START SERVICES (Dependency Order)
# =========================================================================

Write-Host "PHASE 2: Starting Services..." -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Gray
Write-Host ""

# Service 1: Backend (depends on MongoDB being reachable via MONGO_URI)
if (Test-PortFree -Port $BackendPort) {
    Start-ServiceInWindow -Title "Backend API (Port $BackendPort)" `
        -WorkingDir $BackendDir `
        -Command "npm run dev" `
        -Env @{
            "PORT" = "$BackendPort"
            "NODE_ENV" = "development"
            "CORS_ORIGINS" = "http://localhost:$FrontendPort"
        }

    Write-Host "  Verifying backend startup..." -ForegroundColor Yellow
    if (-not (Test-ServiceListening -Port $BackendPort)) {
        Write-Host "  [ERROR] Backend did not start/listen on port $BackendPort" -ForegroundColor Red
        Write-DocHint "Backend failed to start. Check env vars and MongoDB connectivity."
        exit 1
    }
    Write-Host "  [OK] Backend listening on port $BackendPort" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] Backend port $BackendPort already in use (assuming already running)" -ForegroundColor Cyan
}

Write-Host ""

# Service 2: Frontend (depends on backend)
if (Test-PortFree -Port $FrontendPort) {
    Start-ServiceInWindow -Title "Frontend UI (Port $FrontendPort)" `
        -WorkingDir $FrontendDir `
        -Command "npm start" `
        -Env @{
            "REACT_APP_API_BASE_URL" = "http://localhost:$BackendPort"
            "BROWSER" = "none"
        }

    Write-Host "  Verifying frontend startup..." -ForegroundColor Yellow
    if (-not (Test-ServiceListening -Port $FrontendPort)) {
        Write-Host "  [ERROR] Frontend did not start/listen on port $FrontendPort" -ForegroundColor Red
        Write-DocHint "Frontend failed to start. Check Node/npm and frontend dependencies."
        exit 1
    }
    Write-Host "  [OK] Frontend listening on port $FrontendPort" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] Frontend port $FrontendPort already in use (assuming already running)" -ForegroundColor Cyan
}

Write-Host ""

# =========================================================================
# PHASE 3: OPEN URLS + MENU
# =========================================================================

Write-Host "==========================================================================" -ForegroundColor Green
Write-Host "  SERVICES STARTED" -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs:" -ForegroundColor White
Write-Host "  Frontend: http://localhost:$FrontendPort" -ForegroundColor Cyan
Write-Host "  Backend health: http://localhost:$BackendPort/api/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop services: run STOP_ALL.ps1" -ForegroundColor Gray
Write-Host ""

if ($OpenBrowser) {
    Start-Process "http://localhost:$FrontendPort" | Out-Null
}

function Show-Menu {
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "  Service Management Menu" -ForegroundColor Cyan
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1 - Keep services running and exit" -ForegroundColor White
    Write-Host "  2 - Stop all services now" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "Enter choice (1-2)"
    switch ($choice) {
        "1" { return }
        "2" { & (Join-Path $RepoRoot "STOP_ALL.ps1"); return }
        default { Write-Host "Invalid choice." -ForegroundColor Yellow; Show-Menu }
    }
}

Show-Menu


