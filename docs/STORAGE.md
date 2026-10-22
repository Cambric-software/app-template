# Storage

How Cambric applications store and manage data.

---

## Separation of concerns

| Type | Location | Cleared with cache? |
|---|---|---|
| User data | `Products/<id>/Data/` | Never |
| Cache | `Products/<id>/Cache/` | Yes |
| Backups | `Backups/` | Never |
| Downloads | `Downloads/` | No |
| Logs | `Logs/` | No |
| Registry | `Core/Registry/` | Never |

Never store user data in the cache directory. Never clear user data when clearing cache.

---

## LocalStorage

Key/value persistent storage. Each key is a separate JSON file.

```dart
final storage = LocalStorage.instance;

// Write
await storage.write('settings', {'theme': 'dark', 'language': 'en'});

// Read
final settings = await storage.read('settings');

// Check existence
final exists = await storage.contains('settings');

// Delete
await storage.delete('settings');

// List all keys
final keys = await storage.keys();
```

Keys are sanitized — only alphanumeric, `-`, `_`, `.` are kept.

---

## AtomicFileService

Use for any file that must not be corrupted by interruption.

```dart
final atomic = AtomicFileService();
await atomic.write(File('/path/to/file.json'), jsonContent);
```

Write flow: write to `.tmp` → flush → verify non-empty → rename over destination.

---

## CambricPaths

All paths are resolved via `getApplicationSupportDirectory()` — safe on all platforms.

```dart
final dataDir = await CambricPaths.productData('my-product');
final cacheDir = await CambricPaths.productCache('my-product');
final backupsDir = await CambricPaths.backups();
```

Never hardcode paths. Never use Windows-only separators in shared code.

---

## MigrationService

Run sequential versioned migrations on data maps.

```dart
class AddEmailFieldMigration extends Migration {
  AddEmailFieldMigration() : super(fromVersion: 1, toVersion: 2);

  @override
  Future<Map<String, dynamic>> migrate(Map<String, dynamic> data) async {
    return {...data, 'email': ''};
  }
}

final service = MigrationService(
  versionKey: 'schemaVersion',
  migrations: [AddEmailFieldMigration()],
);

final result = await service.run(data, targetVersion: 2);
```

Migrations never downgrade. Failed migrations surface an error in the result.

---

## Backups

There is no backup service in the template. `CambricPaths.backups()` returns a
`Backups/` directory, but nothing writes to it unless a product chooses to.

If your product needs backups, copy `Products/<id>/Data/` to a versioned folder
under `Backups/`, write a small manifest beside it (product id, version, time,
file list) and restore by copying back only after the app has closed the store.
Do not back up `Cache/`: it is disposable by definition.

Keep backups out of the update path. An update that overwrites user data without
a copy the user can find is a data-loss bug, not a feature.

