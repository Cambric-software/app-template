# Cambric App Template

[![CI](https://github.com/Cambric-software/app-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Cambric-software/app-template/actions/workflows/ci.yml)

A Flutter foundation for Cambric applications on **Android, Windows and Linux**.
Local-first, no account and no telemetry: the template ships the parts every
Cambric app needs, in the same visual language as the web and game templates.

## What is included

- **A working shell**, not a blank screen: bottom navigation on phones, a
  navigation rail on desktop, with Home, Components and Settings.
- **The Cambric design system**: complete light and dark themes, semantic
  colours, spacing, radii, type scale, and a widget library (`DsPage`,
  `DsSection`, `DsCard`, `DsMetricTile`, `DsStatusPill`, `DsEmptyState`,
  `DsSegmented`, `DsGrid`).
- **First-run onboarding** with three real pages, persisted completion, and a
  Replay action in Settings.
- **Bundled configuration** (`lib/core/config/cambric_config.json`): product
  name, id, version, repository and capabilities. The app reads it at startup.
- **Local infrastructure**: product-scoped storage paths, atomic file writes,
  a cache with cleanup, a diagnostics report, migration helpers, security
  helpers (input sanitisation, secret redaction) and a release check that stays
  disabled until a repository is configured.
- **A download page** in `app/landing/`, using the same palette and card shapes
  as the Max Tools page.
- **68 tests**, and `flutter analyze` reports no issues.

## Quick start

```powershell
git clone https://github.com/Cambric-software/app-template.git my-app
cd my-app
.\.template\setup\setup.ps1      # name, platforms, ids, locale
cd app
flutter pub get
flutter run -d windows           # or: flutter run
flutter test
```

The setup wizard is a PowerShell script. On Linux or macOS, edit
`app/lib/core/config/cambric_config.json` and `app/cambric.manifest.json`
directly; nothing else in the template is Windows-only.

## What it is not

- **No backend, no account system, no analytics.** The template never sends
  anything anywhere. A product that needs a server adds one deliberately.
- **No auto-update.** The release service can check a GitHub repository and
  report a newer version; it does not download or install anything. Set
  `release.repository` in the config to enable the check, or leave it empty and
  the check is disabled rather than faked.
- **No fake data.** Where a new product has to supply something (release asset
  names, product screens), the template labels it as a placeholder.

## Structure

```text
app/
  lib/
    app/          app root, service wiring, responsive shell
    core/         config, storage, cache, diagnostics, updates, security
    screens/      Home, Components, Settings, Cache, Diagnostics, onboarding
    services/     product-level services (preferences lives here)
    theme/        colours, design tokens, ThemeData
    widgets/      the Cambric widget library
  landing/        static download page (HTML/CSS/JS, no build step)
  test/           widget and unit tests
docs/             architecture, cache, storage, updates, releases, design
.template/        setup wizard and scaffolding
```

Every Dart file under `lib/` is reachable from `main.dart` or from a test; there
is no unused service tree.

## Design

The palette, radii, type scale and component rules are in
[docs/DESIGN.md](docs/DESIGN.md). The code is authoritative:
`app/lib/theme/app_colors.dart`, `design_tokens.dart`, `app_theme.dart` and
`app/lib/widgets/ds_widgets.dart`.

The same values are used by `web-template` (CSS) and `game-template` (game UI),
so a customer moving between Cambric products sees one family. If a token
changes, change it in all three in the same pass.

## Download page

`app/landing/` is a plain HTML page with no dependencies. Before publishing,
replace the `__APP_NAME__`, `__REPO__` and asset placeholders listed in
`app/landing/README.md`. Links use the version-independent
`releases/latest/download/` alias, so a release does not require a page rebuild.
The page shows a version only when one is supplied; it never invents one.

## Renaming for a new product

1. Run `.template\setup\setup.ps1`, or edit `cambric_config.json` and
   `cambric.manifest.json`.
2. Change the Android application id and the Windows runner metadata if the
   wizard did not.
3. Replace the three demo screens with your product screens, keeping the
   `Ds*` components.
4. Fill in `app/landing/` and publish it beside your releases.
5. Keep the security and privacy statements in `SECURITY.md` true for your
   product; do not copy claims the product does not meet.

## Documentation

| Document | Read it when |
|---|---|
| [SETUP.md](SETUP.md) | You are creating a product from the template. |
| [docs/DESIGN.md](docs/DESIGN.md) | You are styling a screen or adding a component. |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | You need to know how the layers fit. |
| [docs/STORAGE.md](docs/STORAGE.md) | You are writing user data. |
| [docs/CACHE.md](docs/CACHE.md) | You are adding disposable files. |
| [docs/UPDATES.md](docs/UPDATES.md) | You are wiring release checks. |
| [docs/TESTING.md](docs/TESTING.md) | You are adding tests. |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | A build or run fails. |

## Licence

Proprietary. See [LICENSE](LICENSE). Security reporting is described in
[SECURITY.md](SECURITY.md).
