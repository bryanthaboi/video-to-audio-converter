# Icon Assets

Place your custom icon files in this directory:

## Required Icons

1. **installer.ico** - Icon for the installer executable (recommended: 256x256 or 128x128)
2. **uninstaller.ico** - Icon for the uninstaller (can be same as installer)
3. **mp3-icon.ico** - Icon for "Convert to MP3" context menu item (16x16 or 32x32 recommended)
4. **wav-icon.ico** - Icon for "Convert to WAV" context menu item (16x16 or 32x32 recommended)

## Icon Specifications

- **Format**: ICO (Windows Icon format)
- **Sizes**: 
  - Installer/Uninstaller: 256x256, 128x128, 64x64, 48x48, 32x32, 16x16 (multi-resolution ICO)
  - Context menu: 16x16 or 32x32 (small icons work best)
- **Tools**: Use tools like:
  - [IcoFX](https://icofx.ro/) (free)
  - [GIMP](https://www.gimp.org/) with ICO plugin
  - Online converters like [ConvertICO](https://convertio.co/png-ico/)

## Default Behavior

If icons are not found, the installer will use default NSIS icons and no icons for context menu items.

## Quick Setup

1. Create or download your icon files
2. Name them exactly as listed above
3. Place them in this `assets/` directory
4. Rebuild the installer
