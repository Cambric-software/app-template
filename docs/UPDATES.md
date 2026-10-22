# Release checks

What the template does: checks a GitHub repository for its latest release,
downloads the asset that matches the current platform, verifies the file, and
stops. Installing the verified file is the product's job.

It does **not** install, replace its own binary or roll back. A self-installer
needs platform permissions the template should not assume, so the last step is
left to you and the UI must say that an update is downloaded, not installed.

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

Failure states:
  notAvailable       ← no release published
  checkFailed        ← network or parse error while checking
  downloadFailed     ← no asset for this platform, or download error
  verificationFailed ← empty file or checksum mismatch
```

`readyToInstall` is the end of the line. The enum also carries install states
for products that implement the final step; the template never enters them.

---

## Usage

```dart
final updates = UpdateService();

// 1. Check. The repository comes from release.repository in the config.
final release = await updates.check('owner/repo');
if (release == null) {
  // updates.error explains whether nothing was published or the check failed.
  return;
}

// 2. Download the asset that matches this platform.
final file = await updates.download();
if (file == null) {
  return;
}

// 3. Verify. Pass the SHA-256 you published with the release, if you have one.
final ok = await updates.verify(expectedChecksum: publishedSha256);
if (!ok) {
  return;
}

// 4. Hand the verified file to your installer, or show its folder and stop.
```

If you have no hash to pass, `verify()` still rejects a missing or empty file,
but it cannot prove the download is authentic. Do not describe that result as
verified. Publish a checksum with every release and pass it.

---

## Release discovery

`ReleaseService` fetches:

```
https://api.github.com/repos/<owner>/<repo>/releases/latest
```

The metadata is cached for one hour. When GitHub is unreachable and a cached
response exists, the cached release is returned rather than an error; the
`checkedAt` field says when it was fetched. When nothing is cached, the check
fails and reports `checkFailed`.

`assetForCurrentPlatform()` picks the first asset whose filename contains
`windows`/`win`, `linux`, or `android`/`.apk`. Name release assets so that
exactly one asset matches the platform, and include the architecture in the
name (`MyApp-1.2.3-windows-x64-setup.exe`).

---

## Verification

```dart
final verifier = UpdateVerificationService();
final result = await verifier.verify(file, expectedSha256: '...');

if (!result.passed) {
  print(result.reason);
}
```

`result.actualChecksum` is available even on mismatch, so the UI can show both
hashes instead of only saying "failed". The comparison is constant-time.

GitHub's release API does not return hashes. Publish the SHA-256 in the release
notes or as a `SHA256SUMS` asset and read it from there; never compute the hash
from the same downloaded file and treat that as authenticity.

---

## Configuration

In `app/lib/core/config/cambric_config.json`:

```json
{
  "release": {
    "provider": "github",
    "repository": "owner/repo",
    "apiBase": "https://api.github.com"
  },
  "update": {
    "enabled": true,
    "automaticChecks": true,
    "allowPrerelease": false
  }
}
```

With an empty `repository`, the app has no release source and should not offer
an update check at all. Do not show a disabled "Check for updates" button
without explaining why it is disabled.

---

## Tests

Both the network and the filesystem are injected. Use `NetworkService` with a
fake client and a temporary directory; never let an update test reach GitHub or
write into a real installation. See `docs/TESTING.md`.
