# GitHub Actions Workflows

This repository includes automated build and release workflows.

## Workflows

### 1. `build-on-commit.yml`
- **Triggers**: On every push to main/master/develop branches and pull requests
- **Purpose**: Builds the installer and uploads it as an artifact
- **Artifacts**: Available for 7 days in the Actions tab
- **Use case**: Testing builds, CI validation

### 2. `release-on-tag.yml`
- **Triggers**: When you push a tag matching `v*.*.*` (e.g., `v1.0.0`, `v2.1.3`)
- **Purpose**: Creates a GitHub Release with the built installer
- **Releases**: Published to the Releases page
- **Use case**: Official releases

### 3. `build-and-release.yml` (Alternative)
- **Triggers**: On push to main/master, tags, or manual dispatch
- **Purpose**: Combined workflow that builds and optionally creates releases
- **Use case**: Single workflow for all scenarios

## How to Create a Release

### Method 1: Using Git Tags (Recommended)

1. Make sure your code is committed and pushed
2. Create and push a version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The workflow will automatically:
   - Build the installer
   - Create a GitHub Release
   - Attach the installer .exe to the release

### Method 2: Manual Release via GitHub UI

1. Go to the **Releases** page on GitHub
2. Click **Draft a new release**
3. Choose a tag or create a new one
4. Upload the built installer manually

## Workflow Details

### NSIS Installation
- The workflows automatically download and install NSIS 3.09
- NSIS is installed to `C:\nsis` on the Windows runner
- No manual setup required

### Build Process
1. Checkout code
2. Install NSIS
3. Run `makensis.exe convert-audio.nsi`
4. Verify the installer was created
5. Upload artifact or create release

### Artifacts
- Build artifacts are stored for 7-30 days (depending on workflow)
- Access them from the **Actions** tab → Select a workflow run → **Artifacts** section

## Troubleshooting

### Build fails
- Check the Actions log for error messages
- Ensure all required files are in the repository
- Verify NSIS script syntax is correct

### Release not created
- Ensure you pushed a tag matching the pattern `v*.*.*`
- Check that the workflow has permission to create releases
- Verify `GITHUB_TOKEN` is available (it's automatic in public repos)

### Installer not in release
- Check the build step succeeded
- Verify the file path is correct: `installer/VideoToAudioConverter-Installer.exe`
- Check the workflow logs for file upload errors
