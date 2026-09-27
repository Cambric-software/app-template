# Setup

How to create a new Cambric application from this template.

---

## Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (included with Flutter)
- Git
- PowerShell 5+ (Windows) or PowerShell Core (Linux/macOS)
- For Android builds: Android SDK, Java 17+
- For Windows builds: Visual Studio with C++ workload
- For Linux builds: `clang cmake ninja-build libgtk-3-dev`

---

## Step 1 — Clone

```powershell
git clone https://github.com/Cambric-software/app-template.git my-app
cd my-app
```

---

## Step 2 — Run the setup wizard

```powershell
.\.template\setup\setup.ps1
```

The wizard asks for:

- **Project name** — human-readable (e.g. `My Cambric App`)
- **Description** — short description (optional)
- **Publisher** — company or author name (optional)
- **Repository** — GitHub repository for release discovery, e.g. `owner/repo` (optional)

It then updates:
- `app/cambric.manifest.json`
- `app/lib/core/config/cambric_config.json`

---

## Step 3 — Install dependencies

```powershell
cd app
flutter pub get
```

---

## Step 4 — Run

```powershell
flutter run
```

Or specify a target:

```powershell
flutter run -d windows
flutter run -d linux
flutter run -d android
```

---

## Step 5 — Verify

```powershell
cd ..
.\scripts-doctor.ps1
```

This checks for all required files, validates manifests, checks for corrupted filenames, scans for secrets, and verifies pubspec structure.

---

## Customizing branding

After setup, update these files for your product:

| What | Where |
|---|---|
| App name, ID, version | `app/lib/core/config/cambric_config.json` |
| Platform manifest | `app/cambric.manifest.json` |
| Theme seed color | `app/lib/theme/app_theme.dart` |
| App icon | `app/android/app/src/main/res/mipmap-*/` (Android), `app/windows/runner/resources/` (Windows) |
| Onboarding pages | `app/lib/screens/onboarding/onboarding_screen.dart` |

---

## What to replace

| Directory | What to do |
|---|---|
| `app/lib/screens/` | Replace placeholder screens with your product screens |
| `app/lib/services/` | Add your product-specific services |
| `app/lib/models/` | Add your product-specific models |
| `app/lib/core/` | Do NOT replace — this is shared infrastructure |
