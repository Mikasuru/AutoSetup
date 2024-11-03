# Set paths
$extraDriverPath = Join-Path $PSScriptRoot "Extra Driver"
$dllSourcePath = Join-Path $extraDriverPath "dll"  # โฟลเดอร์ที่เก็บไฟล์ DLL
$driverBoosterInstaller = Join-Path $extraDriverPath "driver_booster_setup.exe"
$driverBoosterPath = "${env:ProgramFiles(x86)}\IObit\Driver Booster"  # Path ปกติของ Driver Booster

# Function to check if Driver Booster is installed
function Test-DriverBoosterInstalled {
    return Test-Path $driverBoosterPath
}

# Function to install Driver Booster
function Install-DriverBooster {
    Write-Host "`nInstalling Driver Booster..." -ForegroundColor Cyan
    
    if (-not (Test-Path $driverBoosterInstaller)) {
        Write-Host "Error: Driver Booster installer not found at: $driverBoosterInstaller" -ForegroundColor Red
        return $false
    }
    
    $silentArgs = @(
        "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-",
        "/SILENT /SUPPRESSMSGBOXES /NORESTART /SP-",
        "/quiet /norestart",
        "/silent /norestart"
    )
    
    $installed = $false
    foreach ($args in $silentArgs) {
        try {
            Write-Host "Attempting installation with: $args" -ForegroundColor Gray
            $process = Start-Process -FilePath $driverBoosterInstaller -ArgumentList $args -Wait -PassThru -ErrorAction Stop
            
            if ($process.ExitCode -eq 0) {
                $installed = $true
                Write-Host "Driver Booster installation successful!" -ForegroundColor Green
                break
            }
        }
        catch {
            Write-Host "Installation attempt failed, trying next method..." -ForegroundColor Yellow
            continue
        }
    }
    
    return $installed
}

# Function to copy DLL files
function Copy-DriverBoosterDLL {
    if (-not (Test-Path $dllSourcePath)) {
        Write-Host "Warning: DLL source folder not found at: $dllSourcePath" -ForegroundColor Yellow
        return $false
    }
    
    if (-not (Test-Path $driverBoosterPath)) {
        Write-Host "Error: Driver Booster installation folder not found at: $driverBoosterPath" -ForegroundColor Red
        Write-Host "Waiting for installation to complete..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10  # Additional wait time
        
        if (-not (Test-Path $driverBoosterPath)) {
            Write-Host "Installation folder still not found. Please check installation." -ForegroundColor Red
            return $false
        }
    }
    
    Write-Host "`nCopying DLL files..." -ForegroundColor Cyan
    
    try {
        # Get all DLL files from source
        $dllFiles = Get-ChildItem -Path $dllSourcePath -Filter "*.dll"
        
        if ($dllFiles.Count -eq 0) {
            Write-Host "No DLL files found in source folder" -ForegroundColor Yellow
            return $false
        }
        
        # Create backup of existing DLL files
        $backupPath = Join-Path $driverBoosterPath "DLL_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        if (-not (Test-Path $backupPath)) {
            New-Item -ItemType Directory -Path $backupPath | Out-Null
        }
        
        Get-ChildItem -Path $driverBoosterPath -Filter "*.dll" | ForEach-Object {
            Copy-Item $_.FullName -Destination $backupPath -Force
        }
        
        Write-Host "Created backup of existing DLL files at: $backupPath" -ForegroundColor Green
        
        # Copy new DLL files
        foreach ($dll in $dllFiles) {
            $destPath = Join-Path $driverBoosterPath $dll.Name
            Copy-Item -Path $dll.FullName -Destination $destPath -Force
            Write-Host "Copied: $($dll.Name)" -ForegroundColor Green
        }
        
        return $true
    }
    catch {
        Write-Host "Error copying DLL files: $_" -ForegroundColor Red
        return $false
    }
}

# Main installation process
Write-Host "=== Driver Booster Installation and Setup ===" -ForegroundColor Cyan

# Check if Driver Booster is already installed
if (Test-DriverBoosterInstalled) {
    Write-Host "`nDriver Booster is already installed" -ForegroundColor Yellow
    $reinstall = Read-Host "Would you like to reinstall? (Y/N)"
    if ($reinstall -ne "Y") {
        # If not reinstalling, just copy DLL files
        if (Copy-DriverBoosterDLL) {
            Write-Host "`nDLL files updated successfully" -ForegroundColor Green
        }
        else {
            Write-Host "`nFailed to update DLL files" -ForegroundColor Red
        }
        Read-Host "`nPress Enter to exit"
        exit
    }
}

# Install Driver Booster
$installSuccess = Install-DriverBooster

if ($installSuccess) {
    Write-Host "`nWaiting for installation to complete..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15  # Increased wait time for installation
    
    # Copy DLL files
    if (Copy-DriverBoosterDLL) {
        Write-Host "`nInstallation and DLL setup completed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "`nInstallation completed but DLL setup failed" -ForegroundColor Red
        Write-Host "Please check if Driver Booster is installed correctly" -ForegroundColor Yellow
    }
}
else {
    Write-Host "`nDriver Booster installation failed" -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"