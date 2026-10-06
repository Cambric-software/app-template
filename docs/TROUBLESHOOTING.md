# Troubleshooting

## `flutter pub get` fails with dependency conflict

Run `flutter pub outdated` to see what is conflicting. The template pins dependencies to known-working versions. If you need a newer version of a specific package, update `pubspec.yaml` and re-run `flutter pub get`.

---

## `flutter analyze` reports issues after pulling updates

Run a clean analysis:
```bash
flutter clean
flutter pub get
flutter analyze
```

---

## Linux build fails on Windows host

Linux builds require a Linux toolchain (GCC, CMake, GTK headers). On Windows, use GitHub Actions (`ubuntu-latest`) — the `ci.yml` and `release.yml` workflows build Linux automatically.

---

## Android build fails: licenses not accepted

```bash
flutter doctor --android-licenses
```

Accept all licenses, then retry the build.

---

## Version drift detected by doctor

**Symptom:** `scripts-doctor.ps1` reports `VERSION DRIFT: pubspec=x.y.z config=a.b.c`

**Cause:** `pubspec.yaml` and `cambric_config.json` have different versions.

**Fix:** Keep them in sync by always bumping both together:
1. Update `version:` in `app/pubspec.yaml`
2. Update `product.version` in `app/lib/core/config/cambric_config.json`

Or add a release script to your CLI that updates both atomically.

---

## `CambricConfig.load` returns default values unexpectedly

**Cause:** The config file path is wrong. `CambricConfig.load` silently returns defaults when the file is missing (by design — the app must always start).

**Fix:** Verify the path matches where the JSON lives. The default path used in `main.dart` is `'lib/core/config/cambric_config.json'`.

---

## AtomicFileService leaves `.tmp` files behind

This only happens when the process is killed during a write. The `.tmp` files are safe to delete manually — they are intermediate write buffers, not the real data.

---

## Update check returns stale data

The `ReleaseService` caches release metadata locally. To force a fresh check, clear the cache:
```dart
await CacheCleanupService().clearAll();
```

---

## Ecosystem discovery returns empty list

`CambricEcosystemService.discover()` scans the local registry. If no other Cambric products are installed on the same device, the list will be empty — this is correct behaviour, not a bug.

---

## Tests time out on Windows

Widget tests that load Google Fonts or complex themes can hang on Windows due to font resolution. Keep widget tests simple (avoid `ThemeData` with external fonts in tests). Pure Dart tests run reliably with `flutter test`.
