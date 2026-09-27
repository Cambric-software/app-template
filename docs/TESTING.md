# Testing

How to test Cambric applications built on this template.

---

## Running tests

```powershell
cd app

# Run all tests
flutter test

# Run with verbose output
flutter test --reporter expanded

# Run a specific file
flutter test test/core/version_service_test.dart
```

Tests must pass before any release. The CI workflow runs `flutter test` in every build job.

---

## Test structure

```
app/test/
├── core/           — unit tests for core services
├── widgets/        — widget tests
├── screens/        — screen widget tests
├── services/       — product service tests
├── integration/    — integration tests
└── fixtures/       — shared test helpers and fakes
```

---

## Included tests

| Test | What it covers |
|---|---|
| `test/core/version_service_test.dart` | `AppVersion` parsing, comparison, display |
| `test/core/clock_test.dart` | `SystemClock`, `FakeClock` advance/set |
| `test/core/migration_service_test.dart` | Single and chained migrations, no-downgrade |
| `test/core/input_sanitization_test.dart` | Sanitization, validators, secret detection |
| `test/widgets/version_label_test.dart` | Version label rendering and semantics |
| `test/widget_test.dart` | App renders with config, setup button visible |

---

## FakeClock — testing time-dependent code

```dart
final clock = FakeClock(DateTime(2026, 1, 1));

// Move time forward without sleeping
clock.advance(Duration(hours: 24));

expect(clock.now(), DateTime(2026, 1, 2));
```

Inject `Clock` into services so tests can control time:

```dart
class MyService {
  final Clock clock;
  MyService(this.clock);

  bool isExpired(DateTime timestamp) =>
      clock.now().difference(timestamp) > Duration(hours: 1);
}

// In tests:
final clock = FakeClock(DateTime(2026, 1, 1, 10, 0));
final service = MyService(clock);
```

---

## Testing storage

Use `Directory.systemTemp` for test directories. Clean up in `tearDown`:

```dart
late Directory tempDir;

setUp(() async {
  tempDir = await Directory.systemTemp.createTemp('cambric_test_');
});

tearDown(() async {
  await tempDir.delete(recursive: true);
});
```

---

## Update tests must never touch real installations

Never call `InstallerService.install()` in tests with a real executable path. Use mocks or sandboxed temp directories.

---

## Writing new tests

- Test one concern per test function.
- Name tests clearly: `'returns null when key does not exist'`.
- Do not rely on real network in unit tests — inject fakes.
- Do not rely on real filesystem in unit tests — use temp directories.
- Always clean up temp files in `tearDown`.
