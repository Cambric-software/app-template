# Architecture

## Purpose

This repository is the reusable Cambric Software application foundation.

The goal is to provide the infrastructure that every Cambric product needs —
storage, cache, updates, security, ecosystem communication — so each new
product only has to implement its own domain logic.

---

## Core principles

- **Local-first** — works without any remote server
- **Offline-capable** — graceful degradation when network is unavailable
- **Cross-platform** — Android, Linux, Windows
- **No mandatory cloud** — cloud services are optional future additions
- **No telemetry** — diagnostics remain on-device by default
- **User data safety** — cache and user data are strictly separated

---

## Layer model

```
┌─────────────────────────────────────────────────────┐
│                  Product Layer                       │
│  screens/  services/  models/                        │
├─────────────────────────────────────────────────────┤
│                  Widget Layer                        │
│  widgets/  theme/                                    │
├─────────────────────────────────────────────────────┤
│                  Core Layer                          │
│  core/config  core/storage  core/cache               │
│  core/network  core/updates  core/security           │
│  core/platform  core/lifecycle  core/ecosystem       │
└─────────────────────────────────────────────────────┘
```

Product code depends on core. Core never depends on product code.

---

## Core subsystems

### config

`CambricConfig` — loads `cambric_config.json` at startup. Central identity:
product ID, name, version, repository, feature flags, localization, environment.

### storage

- `CambricPaths` — all filesystem paths, platform-safe
- `AtomicFileService` — safe write → verify → rename
- `LocalStorage` — key/value JSON persistence (user data)
- `BackupService` — versioned local backups
- `MigrationService` — sequential schema migrations
- `RestoreService` — restore from backup

### cache

- `CacheService` — disk cache with TTL, metadata, size limits
- `CacheEntryMetadata` — per-entry timestamps and size
- `CacheCleanupService` — evict expired, enforce limits, clear all

### network

- `NetworkService` — HTTP with retry and timeout
- `ConnectivityService` — online/offline/unknown (no plugin required)

### updates

- `ReleaseService` — GitHub release discovery with local cache fallback
- `UpdateService` — full state machine (idle → checking → available → downloading → verifying → readyToInstall → installing → installed)
- `UpdateVerificationService` — SHA-256 checksum verification
- `UpdateRollbackService` — pre-install rollback point

### platform

- `PlatformService` — Windows/Linux/Android detection
- `InstallerService` — abstract + platform implementations
- `DesktopIntegrationService` — shortcuts, metadata

### security

- `SecurityService` — SHA-256, HMAC, file checksum
- `InputSanitizationService` — validation and sanitization
- `SecretRedactionService` — redact secrets from logs/exports
- `AccessControlService` — capability-based access control

### lifecycle

- `AppLifecycleService` — Flutter lifecycle observer
- `VersionService` / `AppVersion` — authoritative version
- `EnvironmentService` — development/test/production
- `FeatureFlagService` — runtime feature flags
- `Clock` / `SystemClock` / `FakeClock` — injectable time

### ecosystem

- `CambricEcosystemService` — stable local installation identity
- `ProductRegistryService` — shared multi-product registry

---

## Data directory layout

```
Cambric/
├── Core/
│   ├── Registry/       — one JSON file per registered product
│   ├── Connections/    — approved inter-product connections
│   └── Ecosystem/      — local installation identity
├── Products/
│   └── <productId>/
│       ├── Data/       — persistent user data
│       └── Cache/      — disposable cache
├── Shared/Data/        — shared approved data
├── Downloads/          — staged release downloads
├── Updates/            — staged updates + rollback info
├── Backups/            — versioned application backups
└── Logs/               — application logs
```

---

## Important boundary

- Cache is DISPOSABLE. Clearing cache never removes user data.
- User data lives in `Products/<id>/Data/`.
- Backups are NOT cache. They are not cleared with cache cleanup.
- Secrets are never placed in source code or config files.

---

## Adding a new subsystem

1. Create a directory under `app/lib/core/<subsystem>/`.
2. Add services with clean interfaces.
3. Register via `ServiceRegistry` if needed.
4. Add unit tests under `app/test/core/`.
5. Document in `docs/`.
