@echo off
cls
color 0A
title Kukuri Setup Installer

:menu
cls
echo ================================
echo      Kukuri Setup Installer
echo ================================
echo.
echo 1. Install Main Drivers
echo 2. Install Extra Drivers
echo 3. Install Programs
echo 4. Install Visual C++ Runtime
echo 5. Install All
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    echo.
    echo Running Main Driver Installer...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0DriverInstall.ps1"""' -Verb RunAs"
    goto menu
)
if "%choice%"=="2" (
    echo.
    echo Running Extra Driver Installer...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0ExtraDriverInstall.ps1"""' -Verb RunAs"
    goto menu
)
if "%choice%"=="3" (
    echo.
    echo Running Program Installer...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0ProgramInstall.ps1"""' -Verb RunAs"
    goto menu
)
if "%choice%"=="4" (
    echo.
    echo Running Visual C++ Runtime Installer...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0VCRuntimeInstall.ps1"""' -Verb RunAs"
    goto menu
)
if "%choice%"=="5" (
    echo.
    echo Installing Everything...
    echo.
    echo Step 1/4: Installing Main Drivers...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0DriverInstall.ps1"""' -Verb RunAs"
    echo Step 2/4: Installing Extra Drivers...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0ExtraDriverInstall.ps1"""' -Verb RunAs"
    echo Step 3/4: Installing Programs...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0ProgramInstall.ps1"""' -Verb RunAs"
    echo Step 4/4: Installing Visual C++ Runtime...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """%~dp0VCRuntimeInstall.ps1"""' -Verb RunAs"
    echo.
    echo All installations complete!
    timeout /t 5 >nul
    goto menu
)
if "%choice%"=="6" (
    echo.
    echo Thank you for using Kukuri Setup Installer
    timeout /t 3 >nul
    exit
)

echo.
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto menu