# Set driver folder path
$driverPath = Join-Path $PSScriptRoot "Driver"

# Check if folder exists
if (-not (Test-Path $driverPath)) {
    Write-Host "`nFolder not found: $driverPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Search for .exe files
Write-Host "`nSearching for driver files..." -ForegroundColor Cyan
$driverFiles = Get-ChildItem -Path $driverPath -Filter "*.exe"

# Check if files were found
if ($driverFiles.Count -eq 0) {
    Write-Host "`nNo .exe files found in the folder" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Show list of found files
Write-Host "`nFound $($driverFiles.Count) driver files:" -ForegroundColor Green
foreach ($file in $driverFiles) {
    Write-Host "- $($file.Name)" -ForegroundColor White
}

# Ask for confirmation
$confirm = Read-Host "`nInstall all drivers? (Y/N)"

if ($confirm -ne "Y") {
    Write-Host "`nInstallation cancelled" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

# List of common silent install arguments for ASUS installers
$silentArgs = @(
    "/silent /norestart /accepteula",
    "/quiet /norestart /accepteula",
    "/verysilent /norestart /accepteula",
    "/s /norestart /accepteula",
    "-silent -norestart -accepteula",
    "-quiet -norestart -accepteula",
    "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP- /ACCEPTEULA",
    "/SILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP- /ACCEPTEULA"
)

# Start installation
Write-Host "`nStarting installation..." -ForegroundColor Cyan

foreach ($file in $driverFiles) {
    Write-Host "`nInstalling: $($file.Name)" -ForegroundColor Yellow
    $installed = $false
    
    # Try each set of arguments until one works
    foreach ($args in $silentArgs) {
        try {
            Write-Host "Trying installation with arguments: $args" -ForegroundColor Gray
            $process = Start-Process -FilePath $file.FullName -ArgumentList $args -Wait -PassThru -ErrorAction Stop
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Successfully installed: $($file.Name)" -ForegroundColor Green
                $installed = $true
                break
            }
        }
        catch {
            Write-Host "Attempt failed, trying next method..." -ForegroundColor Yellow
            continue
        }
    }
    
    if (-not $installed) {
        Write-Host "Warning: Could not install $($file.Name) automatically. You may need to install it manually." -ForegroundColor Red
    }
    
    # Wait a bit between installations
    Start-Sleep -Seconds 2
}

Write-Host "`nDriver Installation Complete" -ForegroundColor Green
$restart = Read-Host "Restart computer now? (Y/N)"

if ($restart -eq "Y") {
    Restart-Computer -Force
}
else {
    Read-Host "Press Enter to exit"
}