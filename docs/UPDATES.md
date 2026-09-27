# Updates

How the Cambric update system works.

---

## State machine

```
idle
  ↓ check()
checking
  ↓ release found
available
  ↓ download()
downloading
  ↓ complete
downloaded
  ↓ verify()
verifying
  ↓ passed
readyToInstall
  ↓ install (platform)
installing
  ↓ success
installed

Failure states:
  notAvailable   ← no release found
  checkFailed    ← network error during check
  downloadFailed ← download error
  verificationFailed ← checksum mismatch or empty file
  installFailed  ← installer returned error
  rollbackRequired ← install failed, rollback needed
  rolledBack     ← rollback completed
```

---

## Usage

```dart
final updates = UpdateService();

// 1. Check for updates
final release = await updates.check('owner/repo');
if (release == null) {
  print('State: ${updates.state}'); // notAvailable or checkFailed
  return;
}

// 2. Download
final file = await updates.download();
if (file == null) {
  print('Download failed: ${updates.error}');
  return;
}

// 3. Verify
final ok = await updates.verify(
  expectedChecksum: release.assetForCurrentPlatform()?.checksum,
);
if (!ok) {
  print('Verification failed: ${updates.error}');
  return;
}

// 4. Install (platform-specific)
final installer = InstallerService.forCurrentPlatform();
final result = await installer.install(file.path);
```

---

## Release discovery

`ReleaseService` fetches from GitHub:

```
https://api.github.com/repos/<owner>/<repo>/releases/latest
```

Caches the result locally. Falls back to cached data when GitHub is unavailable.

---

## Verification

Never install without verification. `UpdateVerificationService`:

```dart
final verifier = UpdateVerificationService();
final result = await verifier.verify(
  file,
  expectedSha256: '...',
);
if (!result.passed) {
  print(result.reason);
}
```

---

## Rollback

Before installing, save a rollback point:

```dart
final rollback = UpdateRollbackService();

await rollback.saveRollbackPoint(
  productId: 'my-product',
  currentVersion: '1.3.0',
);

// ... install new version ...

// If install fails:
await rollback.rollback('my-product');

// If install succeeds:
await rollback.clearRollbackPoint('my-product');
```

---

## Configuration

In `cambric_config.json`:

```json
{
  "release": {
    "provider": "github",
    "repository": "owner/repo"
  },
  "update": {
    "enabled": true,
    "automaticChecks": true,
    "allowPrerelease": false
  }
}
```
