@echo off
REM =========================================================================
REM START_APP.bat - Simple Batch File Startup Script
REM Yearly Planner
REM =========================================================================
REM Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
REM Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
REM Role: Relay (DevOps/SRE)
REM =========================================================================

echo ==========================================================================
echo   Yearly Planner - Starting Application
echo ==========================================================================
echo.

cd /d "%~dp0"

if exist "QUICK_START.ps1" (
    echo Found QUICK_START.ps1
    echo.
    echo Attempting to run with PowerShell...
    echo.
    
    REM Try PowerShell Core first
    pwsh -ExecutionPolicy Bypass -File "%~dp0QUICK_START.ps1" -OpenBrowser
    if %ERRORLEVEL% EQU 0 goto :end
    
    REM Try Windows PowerShell
    powershell -ExecutionPolicy Bypass -File "%~dp0QUICK_START.ps1" -OpenBrowser
    if %ERRORLEVEL% EQU 0 goto :end
    
    echo.
    echo ERROR: Failed to run PowerShell script
    echo Please run QUICK_START.ps1 directly in PowerShell
    goto :error
) else (
    echo ERROR: QUICK_START.ps1 not found in current directory
    echo Current directory: %CD%
    goto :error
)

:end
echo.
pause
exit /b 0

:error
echo.
pause
exit /b 1
