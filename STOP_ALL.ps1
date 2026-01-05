# =========================================================================
# STOP_ALL.ps1
# Yearly Planner - Intelligent Service Shutdown Script
# =========================================================================
# This script:
# 1. Detects which services are currently running
# 2. Stops only the services that are running (by port)
# 3. Verifies shutdown and prints next steps
# =========================================================================
#
# Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
# Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
#
# Role: Relay (DevOps/SRE)
#

[CmdletBinding()]
param()

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "  Yearly Planner - STOP ALL (PowerShell)" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""

$ServicesStopped = 0
$ServicesNotRunning = 0

$ServicePorts = @{
    5000 = "Backend API"
    3000 = "Frontend UI"
}

Write-Host "PHASE 1: Detecting Running Services..." -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Gray
Write-Host ""

$RunningServices = @{}
foreach ($port in $ServicePorts.Keys | Sort-Object) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    $serviceName = $ServicePorts[$port]

    if ($connection) {
        Write-Host "  [RUNNING] Port $port - $serviceName" -ForegroundColor Green
        $RunningServices[$port] = $serviceName
    } else {
        Write-Host "  [STOPPED] Port $port - $serviceName (not running)" -ForegroundColor Gray
        $ServicesNotRunning++
    }
}

Write-Host ""

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "  Detection Summary" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Services Running:     $($RunningServices.Count)" -ForegroundColor $(if ($RunningServices.Count -gt 0) { "Green" } else { "Gray" })
Write-Host "  Services Not Running: $ServicesNotRunning" -ForegroundColor Gray
Write-Host ""

if ($RunningServices.Count -eq 0) {
    Write-Host "No services are running. Nothing to stop." -ForegroundColor Gray
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Services to stop:" -ForegroundColor White
foreach ($port in $RunningServices.Keys | Sort-Object) {
    Write-Host "  - Port $port : $($RunningServices[$port])" -ForegroundColor Gray
}
Write-Host ""

$confirmation = Read-Host "Stop all running services? (y/n)"
if ($confirmation -ne "y" -and $confirmation -ne "Y") {
    Write-Host "Shutdown cancelled by user." -ForegroundColor Yellow
    exit 0
}

function Stop-ProcessByPort {
    param(
        [int]$Port,
        [string]$ServiceName
    )

    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if (-not $connection) {
            Write-Host "  [INFO] Port $Port not in use (already stopped)" -ForegroundColor Gray
            return $true
        }

        $processId = $connection.OwningProcess
        if (-not $processId -or $processId -eq 0) {
            Write-Host "  [ERROR] Could not find PID for port $Port" -ForegroundColor Red
            return $false
        }

        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "  Found process: $($process.ProcessName) (PID: $processId)" -ForegroundColor Gray
        }

        Stop-Process -Id $processId -Force -ErrorAction Stop
        Start-Sleep -Seconds 2

        $stillRunning = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if (-not $stillRunning) {
            Write-Host "  [OK] $ServiceName stopped successfully" -ForegroundColor Green
            return $true
        }

        Write-Host "  [WARNING] Port $Port still in use after stop attempt" -ForegroundColor Yellow
        return $false
    } catch {
        Write-Host "  [ERROR] Failed to stop $ServiceName: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host ""
Write-Host "PHASE 2: Stopping Services..." -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Gray
Write-Host ""

$serviceIndex = 1
foreach ($port in $RunningServices.Keys | Sort-Object) {
    Write-Host "[$serviceIndex/$($RunningServices.Count)] Stopping $($RunningServices[$port]) (port $port)..." -ForegroundColor White
    if (Stop-ProcessByPort -Port $port -ServiceName $RunningServices[$port]) {
        $ServicesStopped++
    }
    Write-Host ""
    $serviceIndex++
}

Write-Host "PHASE 3: Verifying Shutdown..." -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Gray
Write-Host ""

$stillRunning = @()
foreach ($port in $ServicePorts.Keys | Sort-Object) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "  [WARNING] Port $port still in use - $($ServicePorts[$port])" -ForegroundColor Yellow
        $stillRunning += $port
    } else {
        Write-Host "  [OK] Port $port available - $($ServicePorts[$port]) stopped" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "  Shutdown Summary" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Services Stopped:     $ServicesStopped" -ForegroundColor Green
Write-Host "  Still Running:        $($stillRunning.Count)" -ForegroundColor $(if ($stillRunning.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($stillRunning.Count -gt 0) {
    Write-Host "Manual cleanup options:" -ForegroundColor White
    Write-Host "  - Close PowerShell windows manually" -ForegroundColor Gray
    Write-Host "  - Kill all node processes (caution):" -ForegroundColor Gray
    Write-Host "    Get-Process | Where-Object { `$_.ProcessName -eq 'node' } | Stop-Process -Force" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "All Yearly Planner services have been shut down." -ForegroundColor White
    Write-Host "To start again: run START_ALL.ps1" -ForegroundColor Gray
    Write-Host ""
}

Read-Host "Press Enter to close this window"


