; convert-audio.nsi
; NSIS installer script for Video to Audio Converter
; Adds context menu options to convert videos to MP3 or WAV

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "WinVer.nsh"

;--------------------------------
; General

Name "Video to Audio Converter"
OutFile "VideoToAudioConverter-Installer.exe"
Unicode True

; Default installation directory (per-user)
InstallDir "$LOCALAPPDATA\VideoToAudioTools"

; Request application privileges
RequestExecutionLevel user

;--------------------------------
; Variables

Var FFmpegPath
Var FFmpegDownloaded

;--------------------------------
; Interface Settings

!define MUI_ABORTWARNING

; Custom icons - change these paths to your icon files
; If icons don't exist, NSIS will use defaults
!if /FileExists "assets\installer.ico"
    !define MUI_ICON "assets\installer.ico"
!else
    !define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!endif

!if /FileExists "assets\uninstaller.ico"
    !define MUI_UNICON "assets\uninstaller.ico"
!else
    !define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!endif

;--------------------------------
; Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Installer Sections

Section "MainSection" SecMain

    SetOutPath "$INSTDIR"
    
    ; Install PowerShell scripts
    SetOutPath "$INSTDIR\scripts"
    File "scripts\ffmpeg-check.ps1"
    File "scripts\convert-to-mp3.ps1"
    File "scripts\convert-to-wav.ps1"
    
    ; Install icons if they exist
    !if /FileExists "assets\mp3-icon.ico"
        SetOutPath "$INSTDIR\icons"
        File "assets\mp3-icon.ico"
    !endif
    !if /FileExists "assets\wav-icon.ico"
        SetOutPath "$INSTDIR\icons"
        File "assets\wav-icon.ico"
    !endif
    
    ; Check for existing ffmpeg
    Call CheckFFmpeg
    
    ; Download ffmpeg if not found
    ${If} $FFmpegPath == ""
        Call DownloadFFmpeg
    ${EndIf}
    
    ; Register context menu entries
    Call RegisterContextMenu
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Write registry keys for Add/Remove Programs
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\VideoToAudioConverter" \
        "DisplayName" "Video to Audio Converter"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\VideoToAudioConverter" \
        "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\VideoToAudioConverter" \
        "Publisher" "VideoToAudioTools"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\VideoToAudioConverter" \
        "InstallLocation" "$INSTDIR"
    
SectionEnd

;--------------------------------
; Functions

Function CheckFFmpeg
    ; Check if ffmpeg is in PATH using PowerShell
    ; Note: $ signs in PowerShell command must be escaped as $$ for NSIS
    nsExec::ExecToStack 'powershell -NoProfile -Command "$$cmd = Get-Command ffmpeg.exe -ErrorAction SilentlyContinue; if ($$cmd) { Write-Output $$cmd.Source }"'
    Pop $0
    Pop $1
    ${If} $0 == "0"
    ${AndIf} $1 != ""
        StrCpy $FFmpegPath $1
        DetailPrint "Found ffmpeg in PATH: $FFmpegPath"
        Return
    ${EndIf}
    
    ; Check common installation locations
    ${If} ${FileExists} "$PROGRAMFILES\ffmpeg\bin\ffmpeg.exe"
        StrCpy $FFmpegPath "$PROGRAMFILES\ffmpeg\bin\ffmpeg.exe"
        DetailPrint "Found ffmpeg: $FFmpegPath"
        Return
    ${EndIf}
    ${If} ${FileExists} "$PROGRAMFILES64\ffmpeg\bin\ffmpeg.exe"
        StrCpy $FFmpegPath "$PROGRAMFILES64\ffmpeg\bin\ffmpeg.exe"
        DetailPrint "Found ffmpeg: $FFmpegPath"
        Return
    ${EndIf}
    ${If} ${FileExists} "$LOCALAPPDATA\ffmpeg\bin\ffmpeg.exe"
        StrCpy $FFmpegPath "$LOCALAPPDATA\ffmpeg\bin\ffmpeg.exe"
        DetailPrint "Found ffmpeg: $FFmpegPath"
        Return
    ${EndIf}
    
    ; Check if we already downloaded it
    ${If} ${FileExists} "$INSTDIR\bin\ffmpeg.exe"
        StrCpy $FFmpegPath "$INSTDIR\bin\ffmpeg.exe"
        DetailPrint "Found previously downloaded ffmpeg: $FFmpegPath"
        Return
    ${EndIf}
    
    ; Not found
    StrCpy $FFmpegPath ""
    DetailPrint "ffmpeg not found"
FunctionEnd

Function DownloadFFmpeg
    DetailPrint "ffmpeg not found. Downloading from gyan.dev..."
    
    ; Create bin directory
    CreateDirectory "$INSTDIR\bin"
    
    ; Use PowerShell to download and extract ffmpeg
    ; This avoids needing external NSIS plugins
    ; Note: All $ signs in PowerShell code must be escaped as $$ for NSIS
    FileOpen $0 "$TEMP\download-ffmpeg.ps1" w
    FileWrite $0 'param([string]$$InstallDir)$\r$\n'
    FileWrite $0 '$\r$\n'
    FileWrite $0 '$$ErrorActionPreference = "Stop"$\r$\n'
    FileWrite $0 'try {$\r$\n'
    FileWrite $0 '    $$zipPath = "$$env:TEMP\ffmpeg.zip"$\r$\n'
    FileWrite $0 '    $$extractPath = "$$env:TEMP\ffmpeg_extract"$\r$\n'
    FileWrite $0 '    $$url = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"$\r$\n'
    FileWrite $0 '    $$targetPath = Join-Path $$InstallDir "bin\ffmpeg.exe"$\r$\n'
    FileWrite $0 '$\r$\n'
    FileWrite $0 '    Write-Host "Downloading ffmpeg..."$\r$\n'
    FileWrite $0 '    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12$\r$\n'
    FileWrite $0 '    Invoke-WebRequest -Uri $$url -OutFile $$zipPath -UseBasicParsing$\r$\n'
    FileWrite $0 '$\r$\n'
    FileWrite $0 '    Write-Host "Extracting ffmpeg..."$\r$\n'
    FileWrite $0 '    if (Test-Path $$extractPath) { Remove-Item $$extractPath -Recurse -Force }$\r$\n'
    FileWrite $0 '    Expand-Archive -Path $$zipPath -DestinationPath $$extractPath -Force$\r$\n'
    FileWrite $0 '$\r$\n'
    FileWrite $0 '    # Find ffmpeg.exe in extracted folder$\r$\n'
    FileWrite $0 '    $$ffmpegExe = Get-ChildItem -Path $$extractPath -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1$\r$\n'
    FileWrite $0 '    if ($$ffmpegExe) {$\r$\n'
    FileWrite $0 '        $$binDir = Split-Path $$targetPath -Parent$\r$\n'
    FileWrite $0 '        if (-not (Test-Path $$binDir)) { New-Item -ItemType Directory -Path $$binDir -Force | Out-Null }$\r$\n'
    FileWrite $0 '        Copy-Item $$ffmpegExe.FullName $$targetPath -Force$\r$\n'
    FileWrite $0 '        Write-Host "SUCCESS"$\r$\n'
    FileWrite $0 '    } else {$\r$\n'
    FileWrite $0 '        Write-Host "ERROR: ffmpeg.exe not found in archive"$\r$\n'
    FileWrite $0 '        exit 1$\r$\n'
    FileWrite $0 '    }$\r$\n'
    FileWrite $0 '$\r$\n'
    FileWrite $0 '    # Cleanup$\r$\n'
    FileWrite $0 '    Remove-Item $$extractPath -Recurse -Force -ErrorAction SilentlyContinue$\r$\n'
    FileWrite $0 '    Remove-Item $$zipPath -Force -ErrorAction SilentlyContinue$\r$\n'
    FileWrite $0 '} catch {$\r$\n'
    FileWrite $0 '    Write-Host "ERROR: $$_"$\r$\n'
    FileWrite $0 '    exit 1$\r$\n'
    FileWrite $0 '}$\r$\n'
    FileClose $0
    
    ; Execute the PowerShell script with install directory as parameter
    nsExec::ExecToStack 'powershell -NoProfile -ExecutionPolicy Bypass -File "$TEMP\download-ffmpeg.ps1" -InstallDir "$INSTDIR"'
    Pop $0
    Pop $1
    
    ${If} $0 == "0"
    ${AndIf} $1 == "SUCCESS"
        StrCpy $FFmpegPath "$INSTDIR\bin\ffmpeg.exe"
        StrCpy $FFmpegDownloaded "1"
        ; Store flag in registry for uninstaller
        WriteRegStr HKCU "Software\VideoToAudioConverter" "FFmpegDownloaded" "1"
        DetailPrint "Successfully downloaded and installed ffmpeg"
    ${Else}
        DetailPrint "Failed to download ffmpeg. Error: $1"
        MessageBox MB_OK|MB_ICONEXCLAMATION "Failed to download ffmpeg.$\n$\nError: $1$\n$\nPlease install ffmpeg manually and re-run the installer, or check your internet connection."
    ${EndIf}
    
    ; Cleanup script
    Delete "$TEMP\download-ffmpeg.ps1"
FunctionEnd

Function RegisterContextMenu
    DetailPrint "Registering context menu entries..."
    
    ; Video file extensions to register
    ; Common extensions: mp4, avi, mkv, mov, wmv, flv, webm, m4v, 3gp, ogv
    
    ; Define extensions array
    StrCpy $R0 "mp4"
    Call RegisterExtension
    StrCpy $R0 "avi"
    Call RegisterExtension
    StrCpy $R0 "mkv"
    Call RegisterExtension
    StrCpy $R0 "mov"
    Call RegisterExtension
    StrCpy $R0 "wmv"
    Call RegisterExtension
    StrCpy $R0 "flv"
    Call RegisterExtension
    StrCpy $R0 "webm"
    Call RegisterExtension
    StrCpy $R0 "m4v"
    Call RegisterExtension
    StrCpy $R0 "3gp"
    Call RegisterExtension
    StrCpy $R0 "ogv"
    Call RegisterExtension
    
FunctionEnd

Function RegisterExtension
    ; $R0 contains the extension
    
    ; Register "Convert to MP3" - Windows 11 compatible registration
    ; Using both SystemFileAssociations (for Windows 10/11 compatibility) and direct extension registration
    WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToMP3" "" "Convert to MP3"
    WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToMP3\Command" "" \
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\scripts\convert-to-mp3.ps1" "%1"'
    ; Add icon if it exists
    !if /FileExists "assets\mp3-icon.ico"
        WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToMP3" "Icon" "$INSTDIR\icons\mp3-icon.ico"
    !endif
    ; Windows 11: Ensure item appears in main menu (not extended/submenu)
    ; Position = Top means it appears higher in the menu
    WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToMP3" "Position" "Top"
    
    ; Also register directly under the extension for better Windows 11 compatibility
    WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToMP3" "" "Convert to MP3"
    WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToMP3\Command" "" \
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\scripts\convert-to-mp3.ps1" "%1"'
    !if /FileExists "assets\mp3-icon.ico"
        WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToMP3" "Icon" "$INSTDIR\icons\mp3-icon.ico"
    !endif
    WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToMP3" "Position" "Top"
    
    ; Register "Convert to WAV" - Windows 11 compatible registration
    WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToWAV" "" "Convert to WAV"
    WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToWAV\Command" "" \
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\scripts\convert-to-wav.ps1" "%1"'
    ; Add icon if it exists
    !if /FileExists "assets\wav-icon.ico"
        WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToWAV" "Icon" "$INSTDIR\icons\wav-icon.ico"
    !endif
    WriteRegStr HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToWAV" "Position" "Top"
    
    ; Also register directly under the extension
    WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToWAV" "" "Convert to WAV"
    WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToWAV\Command" "" \
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\scripts\convert-to-wav.ps1" "%1"'
    !if /FileExists "assets\wav-icon.ico"
        WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToWAV" "Icon" "$INSTDIR\icons\wav-icon.ico"
    !endif
    WriteRegStr HKCU "Software\Classes\.$R0\Shell\ConvertToWAV" "Position" "Top"
    
FunctionEnd

;--------------------------------
; Uninstaller Section

Section "Uninstall"
    
    ; Remove context menu entries
    Call un.RegisterContextMenu
    
    ; Remove files
    Delete "$INSTDIR\scripts\ffmpeg-check.ps1"
    Delete "$INSTDIR\scripts\convert-to-mp3.ps1"
    Delete "$INSTDIR\scripts\convert-to-wav.ps1"
    RMDir "$INSTDIR\scripts"
    
    ; Remove icons
    Delete "$INSTDIR\icons\mp3-icon.ico"
    Delete "$INSTDIR\icons\wav-icon.ico"
    RMDir "$INSTDIR\icons"
    
    ; Remove ffmpeg if we downloaded it
    ReadRegStr $0 HKCU "Software\VideoToAudioConverter" "FFmpegDownloaded"
    ${If} $0 == "1"
        Delete "$INSTDIR\bin\ffmpeg.exe"
        RMDir "$INSTDIR\bin"
        DeleteRegValue HKCU "Software\VideoToAudioConverter" "FFmpegDownloaded"
    ${EndIf}
    
    ; Remove registry key if empty
    DeleteRegKey HKCU "Software\VideoToAudioConverter"
    
    ; Remove uninstaller
    Delete "$INSTDIR\Uninstall.exe"
    
    ; Remove installation directory if empty
    RMDir "$INSTDIR"
    
    ; Remove registry entries
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\VideoToAudioConverter"
    
SectionEnd

Function un.RegisterContextMenu
    ; Remove context menu entries for all extensions
    
    StrCpy $R0 "mp4"
    Call un.RemoveExtension
    StrCpy $R0 "avi"
    Call un.RemoveExtension
    StrCpy $R0 "mkv"
    Call un.RemoveExtension
    StrCpy $R0 "mov"
    Call un.RemoveExtension
    StrCpy $R0 "wmv"
    Call un.RemoveExtension
    StrCpy $R0 "flv"
    Call un.RemoveExtension
    StrCpy $R0 "webm"
    Call un.RemoveExtension
    StrCpy $R0 "m4v"
    Call un.RemoveExtension
    StrCpy $R0 "3gp"
    Call un.RemoveExtension
    StrCpy $R0 "ogv"
    Call un.RemoveExtension
    
FunctionEnd

Function un.RemoveExtension
    ; $R0 contains the extension
    
    ; Remove from SystemFileAssociations
    DeleteRegKey HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToMP3"
    DeleteRegKey HKCU "Software\Classes\SystemFileAssociations\.$R0\Shell\ConvertToWAV"
    
    ; Remove from direct extension registration
    DeleteRegKey HKCU "Software\Classes\.$R0\Shell\ConvertToMP3"
    DeleteRegKey HKCU "Software\Classes\.$R0\Shell\ConvertToWAV"
    
FunctionEnd
