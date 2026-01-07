# How to Add Custom Icons

## Quick Steps

1. **Create or obtain icon files** in ICO format
2. **Place them in the `assets/` folder** with these exact names:
   - `installer.ico` - For the installer executable
   - `uninstaller.ico` - For the uninstaller (optional, can use same as installer)
   - `mp3-icon.ico` - For "Convert to MP3" context menu item
   - `wav-icon.ico` - For "Convert to WAV" context menu item

3. **Rebuild the installer** - The script will automatically detect and use your icons

## Icon Requirements

### Installer/Uninstaller Icons
- **Format**: ICO (Windows Icon)
- **Recommended sizes**: Multi-resolution ICO containing:
  - 256x256 (for high-DPI displays)
  - 128x128
  - 64x64
  - 48x48
  - 32x32
  - 16x16

### Context Menu Icons
- **Format**: ICO
- **Recommended sizes**: 16x16 or 32x32 (small icons work best in context menus)
- **Style**: Simple, recognizable icons (music note, waveform, etc.)

## Creating Icons

### Option 1: Online Converters
1. Create your icon as PNG (256x256 or 128x128)
2. Use online converter: https://convertio.co/png-ico/ or https://www.icoconverter.com/
3. Download the ICO file

### Option 2: IcoFX (Free Windows Tool)
1. Download from: https://icofx.ro/
2. Create new icon project
3. Import your image or design from scratch
4. Export as ICO with multiple sizes

### Option 3: GIMP (Free, Cross-platform)
1. Install GIMP: https://www.gimp.org/
2. Install ICO plugin or export as PNG and convert online
3. Create your design and export

## File Structure

After adding icons, your `installer/` folder should look like:

```
installer/
├── assets/
│   ├── installer.ico      (optional)
│   ├── uninstaller.ico    (optional)
│   ├── mp3-icon.ico       (optional)
│   ├── wav-icon.ico        (optional)
│   └── README.md
├── scripts/
│   └── ...
├── convert-audio.nsi
└── build.ps1
```

## Behavior

- **If icons exist**: They will be used automatically
- **If icons don't exist**: Default NSIS icons will be used (installer/uninstaller), and no icons for context menu items
- **No errors**: The installer will work fine without custom icons

## Testing

After rebuilding:
1. Check the installer `.exe` file - it should show your custom icon
2. Install the application
3. Right-click a video file - context menu items should show your icons (if provided)

## Tips

- Keep icon designs simple and recognizable
- Use contrasting colors for small context menu icons
- Test icons at different sizes to ensure they look good
- For context menu icons, consider using standard symbols (musical note for MP3, waveform for WAV)
