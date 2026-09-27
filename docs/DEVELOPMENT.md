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

Use relative imports within the same package. Prefer:

```dart
import '../storage/local_storage.dart';
```

Not:

```dart
import 'package:cambric_app/core/storage/local_storage.dart';
```

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
2. Use `Scaffold` + `AppBar` consistently.
3. Use `LoadingWidget`, `EmptyStateWidget`, `ErrorWidget` for states.
4. Add a route in your navigation setup if applicable.
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

Set the environment via the `CAMBRIC_ENV` compile-time constant:

```powershell
flutter run --dart-define=CAMBRIC_ENV=development
flutter build windows --release --dart-define=CAMBRIC_ENV=production
```

Or set it in `cambric_config.json`:

```json
{ "environment": "production" }
```

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

---

## Running the doctor

```powershell
.\scripts-doctor.ps1
```

Returns exit code 0 on success, 1 on failure. Safe to use in CI.
