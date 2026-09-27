# Releases

How to create and publish a Cambric application release.

---

## Version tags

Releases are triggered by pushing a Git tag:

```powershell
git tag v1.4.3
git push origin v1.4.3
```

The tag format must match `v*` (e.g. `v1.0.0`, `v1.4.3`).

---

## What the release workflow does

1. Builds Windows, Linux, and Android in parallel
2. Runs `flutter analyze` and `flutter test` on each platform
3. Packages artifacts:
   - `windows.zip` — Windows release bundle
   - `linux.tar.gz` — Linux release bundle
   - `android.apk` — Android APK
4. Generates SHA-256 checksums for each artifact
5. Creates a GitHub Release with all artifacts and checksums attached

---

## Artifact naming

Artifacts are published as:

```
windows.zip
windows.zip.sha256
linux.tar.gz
linux.tar.gz.sha256
android.apk
android.apk.sha256
```

The update system reads these names to select the correct platform asset.

---

## Release metadata

`ReleaseService` fetches from:

```
https://api.github.com/repos/<owner>/<repo>/releases/latest
```

Configure your repository in `cambric_config.json`:

```json
{
  "release": {
    "provider": "github",
    "repository": "owner/repo",
    "apiBase": "https://api.github.com"
  }
}
```

---

## Checklist before releasing

- [ ] Version updated in `cambric_config.json` and `pubspec.yaml`
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] `.\scripts-doctor.ps1` passes
- [ ] No secrets in source code
- [ ] Documentation updated
- [ ] Git tag created and pushed
