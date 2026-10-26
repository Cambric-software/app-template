# Developer Scripts

Developer commands and tools for the Cambric app-template.

---

## Setup wizard

```powershell
.\.template\setup\setup.ps1
```

Walks you through configuring the app for a new product:
- Sets the product name, package ID, and version
- Configures target platforms
- Updates `CambricConfig` and `pubspec.yaml`

Run this once after cloning the template before making product-specific changes.

---

## Environment health check

```powershell
.\scripts-doctor.ps1
```

Checks your development environment for common issues:
- Flutter SDK version and channel
- Dart version
- Required platform tools (Android SDK, Visual Studio, etc.)
- Scans Dart source for hardcoded secret patterns
- Validates `cambric.manifest.json` if present

Run this whenever you set up a new machine or troubleshoot build problems.

---

## Tests

```powershell
cd app
flutter test
```

Runs the full unit and widget test suite. All 34+ tests must pass before committing.

For verbose output:

```powershell
cd app
flutter test --reporter expanded
```

---

## Static analysis

```powershell
cd app
flutter analyze
```

Runs Dart static analysis with the project's `analysis_options.yaml`. Must report "No issues found" before committing.

---

## Building

### Windows

```powershell
cd app
flutter build windows --release
```

Output: `app\build\windows\x64\runner\Release\`

### Linux

```bash
cd app
flutter build linux --release
```

Output: `app/build/linux/x64/release/bundle/`

### Android

```bash
cd app
flutter build apk --release
```

Output: `app/build/app/outputs/flutter-apk/app-release.apk`

---

## Install helpers

After building, use the install helpers in `app/tools/`:

- `app\tools\install_windows.ps1` — copies the Windows build to `%LOCALAPPDATA%\CambricApp` and creates a desktop shortcut
- `app/tools/install_linux.sh` — copies the Linux bundle to `~/.local/share/cambric-app` and creates a `.desktop` launcher
