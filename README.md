# Cambric App Template

[![CI](https://github.com/Cambric-software/app-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Cambric-software/app-template/actions/workflows/ci.yml)

A reusable, production-oriented Flutter application foundation for Cambric Software products.

Supports **Android**, **Windows**, and **Linux**.

---

## What this is

A starting point for building Cambric applications. It provides the infrastructure every Cambric product needs so you can focus on your product-specific code.

It is **not** a Firebase template, a cloud platform, or an AI framework. It is a local-first, offline-capable Flutter foundation.

---

## Quick start

```powershell
# 1. Clone
git clone https://github.com/Cambric-software/app-template.git my-app
cd my-app

# 2. Run the setup wizard
.\.template\setup\setup.ps1

# 3. Install Flutter dependencies
cd app
flutter pub get

# 4. Run
flutter run
```

---

## What's included

| Area | What's provided |
|---|---|
| Configuration | `CambricConfig` — central product identity, feature flags, localization, branding |
| Storage | `LocalStorage`, `AtomicFileService`, `BackupService`, `MigrationService`, `RestoreService` |
| Cache | `CacheService` (TTL, size limits, metadata), `CacheCleanupService` |
| Network | `NetworkService` (retry/timeout), `ConnectivityService` (online/offline/unknown) |
| Updates | Full state machine: check → download → verify → install, with rollback |
| Releases | `ReleaseService` — GitHub release discovery with local metadata cache |
| Installation | `InstallerService` — platform-specific (Windows/Linux/Android) |
| Desktop | `DesktopIntegrationService` — shortcuts, metadata |
| Security | `SecurityService`, `InputSanitizationService`, `SecretRedactionService`, `AccessControlService` |
| Ecosystem | `CambricEcosystemService`, `ProductRegistryService` — multi-product local discovery |
| Lifecycle | `AppLifecycleService`, `VersionService`, `EnvironmentService`, `FeatureFlagService`, `Clock` |
| Logging | `CambricLogger` — structured logging with rolling in-memory records |
| Diagnostics | `DiagnosticsService` — local diagnostic report generator |
| Localization | English + Arabic (RTL) configured in `cambric_config.json` |
| UX | `OnboardingScreen`, `CambricFirstRunWizard`, `AppTheme`, `EmptyStateWidget`, `LoadingWidget`, `ErrorWidget` |
| Developer tools | `scripts-doctor.ps1` (with version drift check), `.template/setup/setup.ps1` |
| CI/CD | GitHub Actions: analyze, test, build Windows/Linux/Android, security scan, publish release with SHA-256 checksums |

---

## Project structure

```
app-template/
├── app/                    Flutter application
│   ├── lib/
│   │   ├── core/           Reusable infrastructure (never product-specific)
│   │   ├── screens/        Product screens (replace with your own)
│   │   ├── widgets/        Shared widgets
│   │   ├── models/         Shared models
│   │   ├── services/       Product services (replace with your own)
│   │   └── theme/          AppTheme
│   └── test/               Unit, widget, and integration tests
├── .template/setup/        Developer setup wizard
├── docs/                   Documentation
├── .github/workflows/      CI/CD
└── scripts-doctor.ps1      Repository health check
```

---

## Developer commands

```powershell
# Health check
.\scripts-doctor.ps1

# Setup a new project from this template
.\.template\setup\setup.ps1

# Run tests
cd app && flutter test

# Analyze
cd app && flutter analyze

# Build
cd app && flutter build windows --release
cd app && flutter build linux --release
cd app && flutter build apk --release
```

---

## See also

- [ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [DEVELOPMENT.md](docs/DEVELOPMENT.md)
- [STORAGE.md](docs/STORAGE.md)
- [CACHE.md](docs/CACHE.md)
- [UPDATES.md](docs/UPDATES.md)
- [SECURITY.md](SECURITY.md)
- [SETUP.md](SETUP.md)
