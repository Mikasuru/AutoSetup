# Set VCRuntime folder path
$runtimePath = Join-Path $PSScriptRoot "VCRuntime"

# Check if folder exists
if (-not (Test-Path $runtimePath)) {
    Write-Host "`nFolder not found: $runtimePath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Search for installation files
Write-Host "`nSearching for Visual C++ Runtime installers..." -ForegroundColor Cyan
$runtimeFiles = Get-ChildItem -Path $runtimePath -Filter "*.exe"

# Check if files were found
if ($runtimeFiles.Count -eq 0) {
    Write-Host "`nNo .exe files found in the folder" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Sort files by name to ensure consistent installation order
$runtimeFiles = $runtimeFiles | Sort-Object Name

# Show list of found files
Write-Host "`nFound $($runtimeFiles.Count) Visual C++ Runtime installers:" -ForegroundColor Green
foreach ($file in $runtimeFiles) {
    Write-Host "- $($file.Name)" -ForegroundColor White
}

# Ask for confirmation
$confirm = Read-Host "`nInstall all Visual C++ Runtimes? (Y/N)"

if ($confirm -ne "Y") {
    Write-Host "`nInstallation cancelled" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

# List of common silent install arguments for VC++ Runtime
$silentArgs = @(
    "/install /quiet /norestart",
    "/quiet /norestart",
    "/s /norestart",
    "-silent -norestart",
    "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART",
    "/SILENT /SUPPRESSMSGBOXES /NORESTART"
)

# Start installation
Write-Host "`nStarting Visual C++ Runtime installation..." -ForegroundColor Cyan

foreach ($file in $runtimeFiles) {
    Write-Host "`nInstalling: $($file.Name)" -ForegroundColor Yellow
    $installed = $false
    
    # Try each set of arguments until one works
    foreach ($args in $silentArgs) {
        try {
            Write-Host "Trying installation with arguments: $args" -ForegroundColor Gray
            $process = Start-Process -FilePath $file.FullName -ArgumentList $args -Wait -PassThru -ErrorAction Stop
            
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                # ExitCode 3010 means success but requires restart
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
    
    # Wait between installations
    Start-Sleep -Seconds 2
}

Write-Host "`nVisual C++ Runtime Installation Complete" -ForegroundColor Green
$restart = Read-Host "Some installations may require a restart. Restart computer now? (Y/N)"

if ($restart -eq "Y") {
    Restart-Computer -Force
}
else {
    Read-Host "Press Enter to exit"
}