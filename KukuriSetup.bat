@echo off
title Kukuri Setup Installer
color 0A
setlocal EnableDelayedExpansion

REM Check for Admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator!
    echo Right-click on the script and select "Run as administrator"
    pause
    exit /b 1
)

:menu
cls
echo ================================
echo      Kukuri Setup Installer
echo ================================
echo.
echo [1] Install Drivers
echo [2] Install Programs
echo [3] Install Extra Drivers
echo [4] Install Visual C++ Runtime
echo [5] Install All
echo [6] Exit
echo [7] Uninstall Driver Booster
echo.
set /p choice=Enter your choice (1-7): 

if "%choice%"=="1" (
    call :install_drivers
    goto menu
)
if "%choice%"=="2" (
    call :install_programs
    goto menu
)
if "%choice%"=="3" (
    call :install_extra_drivers
    goto menu
)
if "%choice%"=="4" (
    call :install_vcruntime
    goto menu
)
if "%choice%"=="5" (
    call :install_all
    goto menu
)
if "%choice%"=="6" (
    goto :exit_program
)
if "%choice%"=="7" (
    call :uninstall_driver_booster
    goto menu
)

echo Invalid choice!
timeout /t 2 >nul
goto menu

:try_install
if "%~1"=="" (
    echo Error: No file specified
    pause
    goto :eof
)

set "installer=%~1"
echo.
echo Installing: %installer%
echo.

if not exist "%installer%" (
    echo Error: File not found - %installer%
    pause
    goto :eof
)

REM Try silent install first
echo Attempting silent installation...
start /wait "" "%installer%" /silent /norestart
if %ERRORLEVEL% EQU 0 (
    echo Successfully installed %installer%
    goto :eof
)

echo Trying alternate silent method...
start /wait "" "%installer%" /quiet /norestart
if %ERRORLEVEL% EQU 0 (
    echo Successfully installed %installer%
    goto :eof
)

echo Trying very silent method...
start /wait "" "%installer%" /verysilent /norestart
if %ERRORLEVEL% EQU 0 (
    echo Successfully installed %installer%
    goto :eof
)

REM If silent install fails, try normal install
echo Silent installation failed
echo Attempting normal installation...
start /wait "" "%installer%"
if %ERRORLEVEL% EQU 0 (
    echo Successfully installed %installer%
) else (
    echo Warning: Installation might not have completed successfully
    echo Press any key to continue...
    pause >nul
)
goto :eof

:uninstall_driver_booster
cls
echo ================================
echo   Uninstalling Driver Booster
echo ================================
echo.

echo Step 1: Checking if Driver Booster is running...
tasklist /fi "imagename eq DriverBooster.exe" | find "DriverBooster.exe" >nul
if %errorlevel% equ 0 (
    echo Driver Booster is running. Terminating process...
    taskkill /f /im "DriverBooster.exe" >nul 2>&1
    timeout /t 2 /nobreak >nul
) else (
    echo Driver Booster is not running.
)

echo.
echo Step 2: Removing version.dll...
set "dll_path=C:\Program Files (x86)\IObit\Driver Booster\12.0.0\version.dll"
if exist "%dll_path%" (
    del /f /q "%dll_path%" >nul 2>&1
    if errorlevel 1 (
        echo Error: Could not delete version.dll
        pause
        goto :eof
    )
    echo Successfully removed version.dll
) else (
    echo version.dll not found
)

echo.
echo Step 3: Starting Driver Booster...
start "" "C:\Program Files (x86)\IObit\Driver Booster\12.0.0\DriverBooster.exe"
echo Waiting 3 seconds...
timeout /t 3 /nobreak >nul

echo.
echo Step 4: Terminating Driver Booster...
taskkill /f /im "DriverBooster.exe" >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo Step 5: Uninstalling Driver Booster...
REM Checking uninstaller
set "uninstaller=C:\Program Files (x86)\IObit\Driver Booster\12.0.0\unins000.exe"
if exist "%uninstaller%" (
    echo Running uninstaller...
    start /wait "" "%uninstaller%" /SILENT
    echo Driver Booster uninstalled successfully.
) else (
    echo Attempting to uninstall through Control Panel...
    wmic product where "name like '%%Driver Booster%%'" call uninstall /nointeractive
)

echo.
echo ================================
echo Uninstallation Complete!
echo - Driver Booster process terminated
echo - version.dll removed
echo - Program uninstalled
echo ================================
echo.
pause
goto :eof

:install_drivers
cls
echo ================================
echo      Installing Drivers
echo ================================
echo.

cd /d "%~dp0"

if not exist "Driver" if not exist "driver" (
    echo Error: Driver folder not found!
    echo Looking in: %CD%
    pause
    goto :eof
)

echo Scanning for driver files...
set "found_files=0"

REM Try both capitalized and lowercase folder names
if exist "Driver" (
    set "driver_folder=Driver"
) else (
    set "driver_folder=driver"
)

echo Looking in: %driver_folder%
echo.

REM First scan root folder
for %%f in ("%driver_folder%\*.exe") do (
    echo Found: %%f
    set /a "found_files+=1"
    call :try_install "%%f"
)

REM Then scan subfolders
for /d %%d in ("%driver_folder%\*") do (
    echo Scanning subfolder: %%d
    for %%f in ("%%d\*.exe") do (
        echo Found: %%f
        set /a "found_files+=1"
        call :try_install "%%f"
    )
)

if !found_files! equ 0 (
    echo No driver files found!
    pause
) else (
    echo.
    echo Driver installation complete! Installed !found_files! files.
)
pause
goto :eof

:install_programs
cls
echo ================================
echo      Installing Programs
echo ================================
echo.

cd /d "%~dp0"

if not exist "Program" if not exist "program" (
    echo Error: Program folder not found!
    echo Looking in: %CD%
    pause
    goto :eof
)

echo Scanning for program files...
set "found_files=0"

REM Try both capitalized and lowercase folder names
if exist "Program" (
    set "program_folder=Program"
) else (
    set "program_folder=program"
)

echo Looking in: %program_folder%
echo.

REM First scan root folder
for %%f in ("%program_folder%\*.exe" "%program_folder%\*.msi") do (
    echo Found: %%f
    set /a "found_files+=1"
    call :try_install "%%f"
)

REM Then scan subfolders
for /d %%d in ("%program_folder%\*") do (
    echo Scanning subfolder: %%d
    for %%f in ("%%d\*.exe" "%%d\*.msi") do (
        echo Found: %%f
        set /a "found_files+=1"
        call :try_install "%%f"
    )
)

if !found_files! equ 0 (
    echo No program files found!
    pause
) else (
    echo.
    echo Program installation complete! Installed !found_files! files.
)
pause
goto :eof

:install_extra_drivers
cls
echo ================================
echo    Installing Extra Drivers
echo ================================
echo.

cd /d "%~dp0"

if not exist "Extra_Driver" if not exist "extra_driver" (
    echo Error: Extra Driver folder not found!
    echo Looking in: %CD%
    pause
    goto :eof
)

REM Set folder name
if exist "Extra_Driver" (
    set "extra_folder=Extra_Driver"
) else (
    set "extra_folder=extra_driver"
)

echo Step 1: Installing Driver Booster silently...
echo Please wait...

REM Install Driver Booster in silent mode
if exist "%extra_folder%\setup_files\driver_booster_setup.exe" (
    start /wait "" "%extra_folder%\setup_files\driver_booster_setup.exe" /S
    echo Silent installation complete.
    echo Waiting 5 seconds...
    timeout /t 5 /nobreak >nul
) else (
    echo Error: Driver Booster installer not found!
    pause
    goto :eof
)

echo Step 2: Terminating Driver Booster if running...
taskkill /f /im "Driver Booster.exe" >nul 2>&1
timeout /t 2 /nobreak >nul

echo Step 3: Copying DLL file...
REM Check if DLL exists
if not exist "%extra_folder%\dll\version.dll" (
    echo Error: version.dll not found!
    pause
    goto :eof
)

REM Create directory if it doesn't exist
if not exist "C:\Program Files (x86)\IObit\Driver Booster\12.0.0" (
    mkdir "C:\Program Files (x86)\IObit\Driver Booster\12.0.0"
)

REM Copy DLL
copy /Y "%extra_folder%\dll\version.dll" "C:\Program Files (x86)\IObit\Driver Booster\12.0.0" >nul
if errorlevel 1 (
    echo Error copying DLL file!
    pause
    goto :eof
)
echo DLL file copied successfully.

echo Step 4: Starting Driver Booster...
start "" "C:\Program Files (x86)\IObit\Driver Booster\12.0.0\Driver Booster.exe"

echo.
echo ================================
echo Installation Complete!
echo - Driver Booster installed
echo - DLL file copied
echo - Program started
echo ================================
echo.
pause
goto :eof

:install_vcruntime
cls
echo ================================
echo  Installing Visual C++ Runtime
echo ================================
echo.
echo Microsoft Visual C++ All-In-One Runtimes
echo.

if not exist "VCRuntime" (
    echo Error: VCRuntime folder not found!
    pause
    goto :eof
)

CD /d "%~dp0\VCRuntime"

set IS_X64=0 && if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set IS_X64=1) else (if "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set IS_X64=1))

if "%IS_X64%" == "1" goto vcruntime_x64

echo Installing 32-bit runtimes...
echo.

echo 2005...
if exist "vcredist2005_x86.exe" (start /wait vcredist2005_x86.exe /q) else (echo File not found: vcredist2005_x86.exe)

echo 2008...
if exist "vcredist2008_x86.exe" (start /wait vcredist2008_x86.exe /qb) else (echo File not found: vcredist2008_x86.exe)

echo 2010...
if exist "vcredist2010_x86.exe" (start /wait vcredist2010_x86.exe /passive /norestart) else (echo File not found: vcredist2010_x86.exe)

echo 2012...
if exist "vcredist2012_x86.exe" (start /wait vcredist2012_x86.exe /passive /norestart) else (echo File not found: vcredist2012_x86.exe)

echo 2013...
if exist "vcredist2013_x86.exe" (start /wait vcredist2013_x86.exe /passive /norestart) else (echo File not found: vcredist2013_x86.exe)

echo 2015 - 2022...
if exist "vcredist2015_2017_2019_2022_x86.exe" (
    start /wait vcredist2015_2017_2019_2022_x86.exe /passive /norestart
) else (
    echo File not found: vcredist2015_2017_2019_2022_x86.exe
)

goto vcruntime_end

:vcruntime_x64
echo Installing 64-bit runtimes...
echo.

echo 2005...
if exist "vcredist2005_x86.exe" (start /wait vcredist2005_x86.exe /q) else (echo File not found: vcredist2005_x86.exe)
if exist "vcredist2005_x64.exe" (start /wait vcredist2005_x64.exe /q) else (echo File not found: vcredist2005_x64.exe)

echo 2008...
if exist "vcredist2008_x86.exe" (start /wait vcredist2008_x86.exe /qb) else (echo File not found: vcredist2008_x86.exe)
if exist "vcredist2008_x64.exe" (start /wait vcredist2008_x64.exe /qb) else (echo File not found: vcredist2008_x64.exe)

echo 2010...
if exist "vcredist2010_x86.exe" (start /wait vcredist2010_x86.exe /passive /norestart) else (echo File not found: vcredist2010_x86.exe)
if exist "vcredist2010_x64.exe" (start /wait vcredist2010_x64.exe /passive /norestart) else (echo File not found: vcredist2010_x64.exe)

echo 2012...
if exist "vcredist2012_x86.exe" (start /wait vcredist2012_x86.exe /passive /norestart) else (echo File not found: vcredist2012_x86.exe)
if exist "vcredist2012_x64.exe" (start /wait vcredist2012_x64.exe /passive /norestart) else (echo File not found: vcredist2012_x64.exe)

echo 2013...
if exist "vcredist2013_x86.exe" (start /wait vcredist2013_x86.exe /passive /norestart) else (echo File not found: vcredist2013_x86.exe)
if exist "vcredist2013_x64.exe" (start /wait vcredist2013_x64.exe /passive /norestart) else (echo File not found: vcredist2013_x64.exe)

echo 2015 - 2022...
if exist "vcredist2015_2017_2019_2022_x86.exe" (
    start /wait vcredist2015_2017_2019_2022_x86.exe /passive /norestart
) else (
    echo File not found: vcredist2015_2017_2019_2022_x86.exe
)
if exist "vcredist2015_2017_2019_2022_x64.exe" (
    start /wait vcredist2015_2017_2019_2022_x64.exe /passive /norestart
) else (
    echo File not found: vcredist2015_2017_2019_2022_x64.exe
)

:vcruntime_end
echo.
echo Visual C++ Runtime installation complete!
CD /d "%~dp0"
pause
goto :eof

:install_all
cls
echo ================================
echo     Installing Everything
echo ================================
echo.

echo Step 1/4: Installing Drivers...
call :install_drivers

echo Step 2/4: Installing Programs...
call :install_programs

echo Step 3/4: Installing Extra Drivers...
call :install_extra_drivers

echo Step 4/4: Installing Visual C++ Runtime...
call :install_vcruntime

echo.
echo All installations complete!
echo Do you want to restart your computer now? (Y/N)
set /p restart=
if /i "%restart%"=="Y" (
    shutdown /r /t 0
)
goto :eof

:exit_program
echo.
echo Thank you for using Kukuri Setup Installer
timeout /t 3
exit /b 0