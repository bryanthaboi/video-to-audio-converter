# Easy Video to Audio Converter Installer For Windows

This installer adds right-click context menu options to convert video files to MP3 or WAV format using ffmpeg.

## Features

- Automatically detects if ffmpeg is installed
- Downloads and installs ffmpeg from gyan.dev if not found
- Adds "Convert to MP3" and "Convert to WAV" options to video file context menus
- Supports common video formats: MP4, AVI, MKV, MOV, WMV, FLV, WEBM, M4V, 3GP, OGV
- Clean uninstaller that removes all components

## Download

You can always download the latest stable installer from the [Releases page](https://github.com/bryanthaboi/video-to-audio-converter/releases/latest).



## Building the Installer

### Prerequisites

1. **NSIS (Nullsoft Scriptable Install System)**
   - Download from: https://nsis.sourceforge.io/Download
   - Install NSIS (typically to `C:\Program Files (x86)\NSIS\`)
   - Ensure NSIS is in your PATH, or use the full path to `makensis.exe`

2. **NSIS Plugins** (usually included with NSIS):
   - `nsExec.dll` - for executing commands and capturing output
   - These are typically in `NSIS\Plugins\x86-unicode\` or `NSIS\Plugins\x86-ansi\`

### Build Steps

1. Open a command prompt in the `installer` directory
2. Run:
   ```
   makensis convert-audio.nsi
   ```
   Or if NSIS is not in PATH:
   ```
   "C:\Program Files (x86)\NSIS\makensis.exe" convert-audio.nsi
   ```

3. The installer will be created as `VideoToAudioConverter-Installer.exe` in the `installer` directory

### File Structure

```
installer/
├── convert-audio.nsi          # Main NSIS installer script
├── scripts/
│   ├── ffmpeg-check.ps1       # Helper to locate ffmpeg
│   ├── convert-to-mp3.ps1     # MP3 conversion script
│   └── convert-to-wav.ps1     # WAV conversion script
└── README.md                  # This file
```

## Installation

1. Run `VideoToAudioConverter-Installer.exe`
2. Choose installation directory (default: `%LOCALAPPDATA%\VideoToAudioTools`)
3. The installer will:
   - Check for existing ffmpeg installation
   - Download ffmpeg from gyan.dev if not found
   - Install PowerShell scripts
   - Register context menu entries for video files

## Usage

1. Right-click on any video file (MP4, AVI, MKV, etc.)
2. Select "Convert to MP3" or "Convert to WAV"
3. The converted file will be created in the same directory as the source file
4. A notification will appear when conversion is complete

## Uninstallation

1. Go to Settings > Apps > Apps & features (or Control Panel > Programs)
2. Find "Video to Audio Converter"
3. Click Uninstall
4. All components will be removed, including downloaded ffmpeg (if installed by this tool)

## Technical Details

- **Installation Type**: Per-user (no admin rights required)
- **ffmpeg Source**: https://www.gyan.dev/ffmpeg/builds/
- **Context Menu Registration**: Uses `SystemFileAssociations` registry keys (HKCU)
- **Conversion Settings**:
  - MP3: 256k bitrate
  - WAV: PCM 16-bit, 44.1kHz

## Troubleshooting

### ffmpeg download fails
- Check your internet connection
- The installer will prompt you to install ffmpeg manually
- Download from: https://www.gyan.dev/ffmpeg/builds/
- Extract `ffmpeg.exe` to a location in your PATH, or re-run the installer

### Context menu doesn't appear
- Restart Windows Explorer: Press Ctrl+Shift+Esc, find "Windows Explorer", right-click > Restart
- Or log out and back in
- Ensure the installer completed successfully

### Context menu items only appear in "Show more options" (Windows 11)
- **This is expected behavior** - Windows 11's new compact context menu is restrictive by design
- Microsoft intentionally limits third-party items to the legacy menu ("Show more options")
- The items will work perfectly from "Show more options"
- **To see all items in the main menu**: You can disable Windows 11's new context menu:
  1. Open Registry Editor (regedit)
  2. Navigate to: `HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1d0d-34ce-4e57-8b87-5b5b5b5b5b5b}`
  3. Create a new key: `{86ca1d0d-34ce-4e57-8b87-5b5b5b5b5b5b}`
  4. Inside it, create: `InprocServer32` (leave default value empty)
  5. Restart Windows Explorer or log out/in
  6. This will restore the full Windows 10-style context menu

### Conversion fails
- Ensure ffmpeg is accessible (check PATH or reinstall)
- Check that the video file is not corrupted
- Verify you have write permissions in the video file's directory


You can contact me on Twitter [@bryanthaboi](https://twitter.com/bryanthaboi), or open an issue for feature requests.