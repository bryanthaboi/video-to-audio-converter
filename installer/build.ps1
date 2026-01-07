# Build script for Video to Audio Converter Installer
# PowerShell version - handles paths with parentheses better

Write-Host "Building Video to Audio Converter Installer..." -ForegroundColor Cyan
Write-Host ""

# Check if NSIS is in PATH
$makensis = Get-Command makensis -ErrorAction SilentlyContinue
if ($makensis) {
    Write-Host "Found NSIS in PATH: $($makensis.Source)" -ForegroundColor Green
    & makensis convert-audio.nsi
    $buildResult = $LASTEXITCODE
} else {
    Write-Host "NSIS not found in PATH." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Trying default NSIS location..." -ForegroundColor Yellow
    Write-Host ""
    
    # Try default locations
    $nsisPaths = @(
        "C:\Program Files (x86)\NSIS\makensis.exe",
        "C:\Program Files\NSIS\makensis.exe"
    )
    
    $found = $false
    foreach ($nsisPath in $nsisPaths) {
        if (Test-Path $nsisPath) {
            Write-Host "Using NSIS from: $nsisPath" -ForegroundColor Green
            & $nsisPath convert-audio.nsi
            $buildResult = $LASTEXITCODE
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Write-Host ""
        Write-Host "ERROR: Could not find makensis.exe" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please either:" -ForegroundColor Yellow
        Write-Host "  1. Install NSIS from https://nsis.sourceforge.io/Download"
        Write-Host "  2. Add NSIS to your PATH, or"
        Write-Host "  3. Edit this script to set NSIS path"
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Check result
if ($buildResult -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "Installer created: VideoToAudioConverter-Installer.exe" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"
