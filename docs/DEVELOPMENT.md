# Development

How to develop, test, and build applications using this template.

---

## Setup

See [SETUP.md](../SETUP.md) for initial project setup.

---

## Daily workflow

```powershell
cd app

# Run in development
flutter run -d windows

# Analyze
flutter analyze

# Test
flutter test

# Test with coverage
flutter test --coverage
```

---

## Project conventions

### Filenames

Use `snake_case.dart` for all Dart files. Example: `cache_service.dart`.

### Classes

Use `PascalCase`. Example: `CacheService`.

### Imports

Use relative imports within the same package. Prefer `import '../storage/local_storage.dart';` over
`import 'package:cambric_app/core/storage/local_storage.dart';`.
---

## Where things belong

| What | Where |
|---|---|
| Reusable infrastructure | `app/lib/core/` |
| Product screens | `app/lib/screens/` |
| Product services | `app/lib/services/` |
| Product models | `app/lib/models/` |
| Shared widgets | `app/lib/widgets/` |
| Theme | `app/lib/theme/` |
| Unit tests | `app/test/core/` |
| Widget tests | `app/test/widgets/` |
| Screen tests | `app/test/screens/` |
| Test fixtures | `app/test/fixtures/` |

---

## Adding a new screen

1. Create `app/lib/screens/<name>/<name>_screen.dart`.
2. Wrap the body in `DsPage(title: ..., child: ...)` so padding, max width and
   the scroll behaviour match every other screen.
3. Compose `DsSection`, `DsCard`, `DsMetricTile`, `DsStatusPill` and
   `DsEmptyState` rather than hand-building a card or an empty view.
4. Add it to the shell in `app/lib/app/app_shell.dart` if it is a destination,
   or push it with `MaterialPageRoute` from the place that owns it.
5. Add a widget test under `app/test/screens/`.

---

## Adding a new core service

1. Create `app/lib/core/<subsystem>/<service_name>_service.dart`.
2. Use constructor injection for dependencies (not singletons where avoidable).
3. Handle errors explicitly — do not swallow exceptions silently.
4. Add unit tests under `app/test/core/`.
5. Document in the appropriate `docs/` file.

---

## Environment configuration

`environment` in `cambric_config.json` is the single source of truth:

```json
{ "environment": "production" }
```

The template does not read a `--dart-define` for this. If a product needs
build-time separation, add it deliberately and document it; do not add a second
environment source that can disagree with the config file.

---

## Feature flags

In `cambric_config.json`:

```json
{
  "featureFlags": {
    "showDeveloperTools": true
  }
}
```

In Dart:

```dart
if (config.featureFlags.isEnabled('showDeveloperTools')) {
  // show developer overlay
}
```

---

## Building for release

```powershell
cd app

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# Android
flutter build apk --release
```

### Local install helpers

After a release build, `app/tools/` can install the bundle locally without
building an installer:

```powershell
.\app\tools\install_windows.ps1 -InstallName "MyApp"
```

```bash
INSTALL_NAME=my-app MAIN_BINARY_NAME=cambric_app ./app/tools/install_linux.sh
```

The Windows helper accepts `-BuildPath`, `-InstallName` and `-NoShortcut`. The
Linux helper reads `INSTALL_NAME`, `DISPLAY_NAME`, `MAIN_BINARY_NAME` and
`BUILD_PATH` from the environment, defaulting to the template's names. These
helpers are for local testing, not for shipping; the release workflow publishes
the archives.

---

## Running the doctor

```powershell
.\scripts-doctor.ps1
```

Returns exit code 0 on success, 1 on failure. Safe to use in CI.
