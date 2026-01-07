# ffmpeg-check.ps1
# Resolves ffmpeg.exe from PATH or installation directory

param(
    [string]$InstallDir = $PSScriptRoot
)

# First check if ffmpeg is in PATH
$ffmpegInPath = Get-Command ffmpeg.exe -ErrorAction SilentlyContinue
if ($ffmpegInPath) {
    return $ffmpegInPath.Source
}

# Check in installation directory
$ffmpegLocal = Join-Path $InstallDir "ffmpeg.exe"
if (Test-Path $ffmpegLocal) {
    return $ffmpegLocal
}

# Check in bin subdirectory
$ffmpegBin = Join-Path $InstallDir "bin\ffmpeg.exe"
if (Test-Path $ffmpegBin) {
    return $ffmpegBin
}

# Not found
return $null
