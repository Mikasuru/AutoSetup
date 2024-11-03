# Set program folder path
$programPath = Join-Path $PSScriptRoot "Program"

# Check if folder exists
if (-not (Test-Path $programPath)) {
    Write-Host "`nFolder not found: $programPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Search for installation files
Write-Host "`nSearching for program files..." -ForegroundColor Cyan
$programFiles = Get-ChildItem -Path $programPath -Filter "*.exe"

# Check if files were found
if ($programFiles.Count -eq 0) {
    Write-Host "`nNo .exe files found in the folder" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Show list of found files with numbers
Write-Host "`nFound $($programFiles.Count) programs:" -ForegroundColor Green
for ($i = 0; $i -lt $programFiles.Count; $i++) {
    Write-Host "[$($i + 1)] $($programFiles[$i].Name)" -ForegroundColor White
}

Write-Host "`n[A] Install All Programs"
Write-Host "[Q] Exit`n"

$choice = Read-Host "Enter your choice (number, 'A' for all, or 'Q' to quit)"

# List of common silent install arguments
$silentArgs = @(
    "/silent /norestart",
    "/quiet /norestart",
    "/verysilent /norestart",
    "/s /norestart",
    "-silent -norestart",
    "-quiet -norestart",
    "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP-",
    "/SILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP-"
)

function Install-Program {
    param (
        [System.IO.FileInfo]$file
    )
    
    Write-Host "`nInstalling: $($file.Name)" -ForegroundColor Yellow
    $installed = $false
    
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
    
    Start-Sleep -Seconds 2
}

# Process user choice
switch ($choice) {
    "A" {
        Write-Host "`nInstalling all programs..." -ForegroundColor Cyan
        foreach ($file in $programFiles) {
            Install-Program -file $file
        }
    }
    "Q" {
        Write-Host "`nInstallation cancelled" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit
    }
    default {
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $programFiles.Count) {
            Install-Program -file $programFiles[$index]
        }
        else {
            Write-Host "`nInvalid choice" -ForegroundColor Red
        }
    }
}

Write-Host "`nProgram Installation Complete" -ForegroundColor Green
Read-Host "Press Enter to exit"