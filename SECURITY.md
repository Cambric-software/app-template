# Security Policy

Security policy and practices for Cambric applications built on this template.

---

## Security model

Cambric applications are **local-first**. Security defaults are:

- No remote authentication required
- No telemetry or usage tracking by default
- No mandatory cloud backend
- User data stays on the device unless explicitly shared by the user

---

## Provided security infrastructure

### Input sanitization

`InputSanitizationService` — sanitize and validate all user input before storing, rendering, or sending:

- `trimWhitespace` — remove surrounding whitespace
- `toSafeIdentifier` — normalize to safe alphanumeric identifier
- `sanitizeFilename` — remove path traversal characters
- `escapeHtml` — escape HTML special characters
- `validateRequired`, `validateEmail`, `validateUrl`, `validateMinLength`
- `looksLikeSecret` — detect accidental secret values in input

### Atomic file writes

`AtomicFileService` — all persistent writes use atomic write-then-rename:

- Data is written to a temporary file first
- The file is renamed (committed) only after a successful write
- Prevents partial writes and file corruption on unexpected shutdown
- Used by storage, cache, and backup subsystems

### Secret redaction

`SecretRedactionService` — redact sensitive values before logging or exporting:

- Detects private keys, API keys, tokens, passwords, GitHub tokens, AWS keys
- `redact(string)` — redact a single string
- `redactMap(map)` — redact all sensitive keys in a map

### Hashing and integrity

`SecurityService`:

- `sha256String`, `sha256Bytes`, `sha256File` — SHA-256 hashing
- `constantTimeEquals` — timing-safe string comparison
- `generateIntegrityTag` / `verifyIntegrityTag` — HMAC-SHA256
- `verifyFileChecksum` — verify a file against an expected SHA-256 hash

### Access control

`AccessControlService` — software-level capability gating:

- `grant(subject, capability)` — grant a capability
- `revoke(subject, capability)` — revoke a capability
- `can(subject, capability)` — check permission

### Update verification

`UpdateVerificationService` — verifies downloaded packages before installation:

- File existence check
- Non-empty file check
- SHA-256 checksum comparison against the published release checksum

All release artifacts (Windows `.zip`, Linux `.tar.gz`, Android `.apk`) are published with a companion `.sha256` file. Verification is performed before any install step executes.

---

## Dependency auditing in CI

The `security.yml` GitHub Actions workflow runs on every push and pull request:

- `dart pub audit` — checks all transitive dependencies for known vulnerabilities
- Grep scan of `lib/` for hardcoded credential patterns (API keys, passwords, tokens)
- Check that no `.env` files have been committed to the repository

`dart pub audit` runs with `continue-on-error: true` because upstream packages may carry informational advisories that do not affect this application. Review audit output in CI and address genuine vulnerabilities.

---

## Secret scanning in developer tools

`scripts-doctor.ps1` scans Dart source files for common secret patterns:

- AWS access key IDs (`AKIA...`)
- GitHub personal access tokens (`ghp_...`)
- Private key headers
- Generic `api_key =`, `password =`, `token =` assignments

Run before committing:

```powershell
.\scripts-doctor.ps1
```

---

## What this template does NOT do

- It does NOT implement OS keychain or secure enclave storage (requires platform plugins)
- It does NOT implement OAuth or remote authentication flows
- It does NOT send diagnostic data to remote servers

---

## Reporting vulnerabilities

Do not report security vulnerabilities in public GitHub issues.

Contact: **security@cambric.dev**

Please include:

1. A description of the vulnerability and its potential impact
2. Steps to reproduce or a proof-of-concept
3. The affected version(s)

We will acknowledge receipt within 48 hours and aim to release a fix within 14 days for critical issues.
