# Security

Security policy and practices for Cambric applications built on this template.

---

## Security model

Cambric applications are **local-first**. Security defaults are:

- No remote authentication required
- No telemetry
- No mandatory cloud backend
- User data stays on the device unless explicitly shared

---

## Provided security infrastructure

### Input sanitization

`InputSanitizationService` — sanitize and validate before storing, rendering, or sending:

- `trimWhitespace` — remove surrounding whitespace
- `toSafeIdentifier` — normalize to safe alphanumeric identifier
- `sanitizeFilename` — remove path traversal characters
- `escapeHtml` — escape HTML special characters
- `validateRequired`, `validateEmail`, `validateUrl`, `validateMinLength`
- `looksLikeSecret` — detect accidental secret values

### Secret redaction

`SecretRedactionService` — redact before logging or exporting:

- Detects private keys, API keys, tokens, passwords, GitHub tokens, AWS keys
- `redact(string)` — redact a string
- `redactMap(map)` — redact all sensitive keys in a map

### Hashing and integrity

`SecurityService`:

- `sha256String`, `sha256Bytes`, `sha256File` — SHA-256 hashing
- `constantTimeEquals` — timing-safe string comparison
- `generateIntegrityTag` / `verifyIntegrityTag` — HMAC-SHA256
- `verifyFileChecksum` — verify a file against an expected SHA-256

### Access control

`AccessControlService` — software-level capability gating:

- `grant(subject, capability)` — grant a capability
- `revoke(subject, capability)` — revoke a capability
- `can(subject, capability)` — check permission

### Update verification

`UpdateVerificationService` — verifies downloaded packages before installation:

- File existence check
- Non-empty check
- SHA-256 checksum comparison

---

## Secret scanning

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

- It does NOT implement OS keychain/secure enclave storage (requires platform plugins)
- It does NOT implement OAuth or remote authentication
- It does NOT send diagnostic data to remote servers

---

## Reporting vulnerabilities

Do not report security vulnerabilities in public GitHub issues.

Contact: security@cambric.software (or update this address for your product)
