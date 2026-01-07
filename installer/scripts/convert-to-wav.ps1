# convert-to-wav.ps1
# Converts video files to WAV format

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Files
)

$ErrorActionPreference = "Stop"

# Get installation directory
# When called from context menu, PSScriptRoot should be set correctly
# Fallback to registry or default location
$InstallDir = $null
if ($PSScriptRoot) {
    # PSScriptRoot is $INSTDIR\scripts, so parent is $INSTDIR
    $InstallDir = Split-Path $PSScriptRoot -Parent
}
if (-not $InstallDir -or -not (Test-Path $InstallDir)) {
    # Try registry
    $regPath = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\VideoToAudioConverter" -Name "InstallLocation" -ErrorAction SilentlyContinue).InstallLocation
    if ($regPath -and (Test-Path $regPath)) {
        $InstallDir = $regPath
    } else {
        $InstallDir = Join-Path $env:LOCALAPPDATA "VideoToAudioTools"
    }
}

# Resolve ffmpeg
$ffmpegPath = & "$PSScriptRoot\ffmpeg-check.ps1" -InstallDir $InstallDir

if (-not $ffmpegPath) {
    [System.Windows.Forms.MessageBox]::Show(
        "ffmpeg not found. Please ensure it is installed or re-run the installer.",
        "Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

# Add System.Windows.Forms for message boxes
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$successCount = 0
$errorCount = 0
$errors = @()

foreach ($file in $Files) {
    if (-not (Test-Path $file)) {
        $errors += "File not found: $file"
        $errorCount++
        continue
    }
    
    $inputFile = $file
    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".wav")
    
    try {
        # Convert to WAV (uncompressed PCM)
        # Redirect all output to temp files to suppress ffmpeg messages
        $guid = [System.Guid]::NewGuid().ToString('N').Substring(0,8)
        $nullOut = "$env:TEMP\ffmpeg-out-$guid.tmp"
        $nullErr = "$env:TEMP\ffmpeg-err-$guid.tmp"
        
        $process = Start-Process -FilePath $ffmpegPath -ArgumentList @(
            "-i", "`"$inputFile`"",
            "-vn",
            "-acodec", "pcm_s16le",
            "-ar", "44100",
            "-y",
            "`"$outputFile`""
        ) -Wait -NoNewWindow -PassThru -RedirectStandardOutput $nullOut -RedirectStandardError $nullErr
        
        # Clean up temp files
        if (Test-Path $nullOut) { Remove-Item $nullOut -Force -ErrorAction SilentlyContinue }
        if (Test-Path $nullErr) { Remove-Item $nullErr -Force -ErrorAction SilentlyContinue }
        
        if ($process.ExitCode -eq 0) {
            $successCount++
        } else {
            $errors += "Failed to convert: $file"
            $errorCount++
        }
    } catch {
        $errors += "Error converting $file : $_"
        $errorCount++
    }
}

# Show result notification
if ($successCount -gt 0 -and $errorCount -eq 0) {
    [System.Windows.Forms.MessageBox]::Show(
        "Successfully converted $successCount file(s) to WAV.",
        "Conversion Complete",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
} elseif ($errorCount -gt 0) {
    $errorMsg = "Errors occurred:`n" + ($errors -join "`n")
    if ($successCount -gt 0) {
        $errorMsg = "Successfully converted $successCount file(s).`n`n" + $errorMsg
    }
    [System.Windows.Forms.MessageBox]::Show(
        $errorMsg,
        "Conversion Issues",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
}
