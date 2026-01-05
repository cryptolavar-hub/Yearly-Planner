@echo off
setlocal enabledelayedexpansion
REM =========================================================================
REM START_APP_DEBUG.bat
REM Yearly Planner - Debug Version with Detailed Logging
REM =========================================================================
REM This version provides maximum logging for troubleshooting
REM =========================================================================

set "LOG_FILE=startup_debug.log"
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%QUICK_START.ps1"

echo ========================================================================== > "%LOG_FILE%"
echo   Yearly Planner - Debug Startup Log >> "%LOG_FILE%"
echo   Date: %DATE% %TIME% >> "%LOG_FILE%"
echo   User: %USERNAME% >> "%LOG_FILE%"
echo   Computer: %COMPUTERNAME% >> "%LOG_FILE%"
echo ========================================================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo DEBUG MODE - Detailed logging enabled
echo Log file: %LOG_FILE%
echo.

echo [DEBUG] Script directory: %SCRIPT_DIR% >> "%LOG_FILE%"
echo [DEBUG] PowerShell script: %PS_SCRIPT% >> "%LOG_FILE%"
echo [DEBUG] Current directory: %CD% >> "%LOG_FILE%"
echo [DEBUG] PATH: %PATH% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Check script exists
if not exist "%PS_SCRIPT%" (
    echo [ERROR] Script not found: %PS_SCRIPT% >> "%LOG_FILE%"
    echo ERROR: Script not found!
    dir "%SCRIPT_DIR%" >> "%LOG_FILE%" 2>&1
    type "%LOG_FILE%"
    pause
    exit /b 1
)
echo [DEBUG] Script exists >> "%LOG_FILE%"

REM Try PowerShell Core
echo [DEBUG] Checking pwsh... >> "%LOG_FILE%"
where pwsh >> "%LOG_FILE%" 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [DEBUG] Using pwsh >> "%LOG_FILE%"
    echo Using PowerShell Core...
    pwsh -NoProfile -ExecutionPolicy Bypass -Command "& { Write-Host 'PowerShell Core Version:'; $PSVersionTable.PSVersion; Write-Host ''; Write-Host 'Script Path:'; '%PS_SCRIPT%'; Write-Host ''; Write-Host 'Running script...'; & '%PS_SCRIPT%' -OpenBrowser }" 2>&1 | tee "%LOG_FILE%"
    goto :end
)

REM Try Windows PowerShell
echo [DEBUG] Checking powershell... >> "%LOG_FILE%"
where powershell >> "%LOG_FILE%" 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [DEBUG] Using powershell >> "%LOG_FILE%"
    echo Using Windows PowerShell...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& { Write-Host 'PowerShell Version:'; $PSVersionTable.PSVersion; Write-Host ''; Write-Host 'Script Path:'; '%PS_SCRIPT%'; Write-Host ''; Write-Host 'Running script...'; & '%PS_SCRIPT%' -OpenBrowser }" 2>&1 | tee "%LOG_FILE%"
    goto :end
)

echo [ERROR] No PowerShell found >> "%LOG_FILE%"
echo ERROR: No PowerShell found
type "%LOG_FILE%"
pause
exit /b 1

:end
echo.
echo Check %LOG_FILE% for detailed logs
pause

