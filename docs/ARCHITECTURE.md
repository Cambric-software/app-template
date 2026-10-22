# Architecture

## Purpose

This repository is the reusable Cambric Software application foundation.

The goal is to provide the infrastructure that every Cambric product needs —
storage, cache, release checks, security, diagnostics — so each new product
only has to implement its own domain logic.

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
│  core/platform  core/lifecycle  core/logging         │
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
- `MigrationService` — sequential schema migrations

Backups are a product decision, not a core service. The template creates the
`Backups/` directory but ships no backup or restore implementation; a product
that needs one adds it and documents what it copies.

### cache

- `CacheService` — disk cache with TTL, metadata, size limits
- `CacheEntryMetadata` — per-entry timestamps and size
- `CacheCleanupService` — evict expired, enforce limits, clear all

### network

- `NetworkService` — HTTP with retry and timeout
- `ConnectivityService` — online/offline/unknown (no plugin required)

### updates

- `ReleaseService` — GitHub release discovery with local cache fallback
- `UpdateService` — check → download → verify, with a typed state machine
- `UpdateVerificationService` — SHA-256 checksum verification
- `UpdateState` — the states the UI can render

Installing a downloaded build is deliberately not in core. A background
self-installer differs per platform and needs permissions the template should
not assume; the product implements it after verification and says so.

### platform

- `PlatformService` — Windows/Linux/Android detection

### security

- `SecurityService` — SHA-256, HMAC, file checksum
- `InputSanitizationService` — validation and sanitization
- `SecretRedactionService` — redact secrets from logs/exports

### lifecycle

- `AppLifecycleService` — Flutter lifecycle observer
- `VersionService` / `AppVersion` — authoritative version
- `FeatureFlagService` — runtime feature flags
- `Clock` / `SystemClock` / `FakeClock` — injectable time

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
2. Add services with clean interfaces and no global state.
3. Construct it in `AppServices` and pass it to the screen that needs it.
4. Add unit tests under `app/test/core/`.
5. Document it in `docs/`.
