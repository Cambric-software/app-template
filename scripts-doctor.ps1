$ErrorActionPreference = "Stop"

$root = Get-Location
$failed = 0
$warnings = 0

function Pass($msg) { Write-Host "  OK  $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host " FAIL $msg" -ForegroundColor Red; $script:failed++ }
function Warn($msg) { Write-Host " WARN $msg" -ForegroundColor Yellow; $script:warnings++ }
function Section($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

# ──────────────────────────────────────────────────────────────────────────────
Section "REQUIRED FILES"
# ──────────────────────────────────────────────────────────────────────────────

$required = @(
    "app\pubspec.yaml",
    "app\lib\main.dart",
    "app\lib\cambric_app_shell.dart",
    "app\lib\core\config\cambric_config.dart",
    "app\lib\core\config\cambric_config.json",
    "app\lib\core\storage\cambric_paths.dart",
    "app\lib\core\storage\atomic_file_service.dart",
    "app\lib\core\storage\local_storage.dart",
    "app\lib\core\cache\cache_service.dart",
    "app\lib\core\cache\cache_cleanup_service.dart",
    "app\lib\core\network\network_service.dart",
    "app\lib\core\network\connectivity_service.dart",
    "app\lib\core\updates\release_service.dart",
    "app\lib\core\updates\update_service.dart",
    "app\lib\core\updates\update_state.dart",
    "app\lib\core\updates\update_verification_service.dart",
    "app\lib\core\updates\update_rollback_service.dart",
    "app\lib\core\platform\platform_service.dart",
    "app\lib\core\platform\installer_service.dart",
    "app\lib\core\platform\desktop_integration_service.dart",
    "app\lib\core\security\security_service.dart",
    "app\lib\core\security\input_sanitization_service.dart",
    "app\lib\core\security\secret_redaction_service.dart",
    "app\lib\core\security\access_control_service.dart",
    "app\lib\core\ecosystem\cambric_ecosystem_service.dart",
    "app\lib\core\ecosystem\product_registry_service.dart",
    "app\lib\core\lifecycle\app_lifecycle_service.dart",
    "app\lib\core\lifecycle\version_service.dart",
    "app\lib\core\lifecycle\environment_service.dart",
    "app\lib\core\lifecycle\feature_flag_service.dart",
    "app\lib\core\lifecycle\clock.dart",
    "app\lib\core\storage\backup_service.dart",
    "app\lib\core\storage\migration_service.dart",
    "app\lib\core\storage\restore_service.dart",
    "app\lib\widgets\cambric_first_run_wizard.dart",
    "app\lib\widgets\cambric_version_label.dart",
    "app\lib\widgets\state_widgets.dart",
    "app\lib\theme\app_theme.dart",
    "app\lib\screens\onboarding\onboarding_screen.dart",
    "app\cambric.manifest.json",
    ".template\setup\setup.ps1"
)

foreach ($file in $required) {
    $fullPath = Join-Path $root $file
    if (Test-Path $fullPath) {
        Pass $file
    } else {
        Fail "MISSING: $file"
    }
}

# ──────────────────────────────────────────────────────────────────────────────
Section "MANIFEST VALIDATION"
# ──────────────────────────────────────────────────────────────────────────────

$manifestPath = Join-Path $root "app\cambric.manifest.json"
if (Test-Path $manifestPath) {
    try {
        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
        if ($manifest.productId) { Pass "manifest.productId: $($manifest.productId)" }
        else { Fail "manifest.productId is missing" }
        if ($manifest.version) { Pass "manifest.version: $($manifest.version)" }
        else { Fail "manifest.version is missing" }
        if ($manifest.platforms.Count -gt 0) { Pass "manifest.platforms: $($manifest.platforms -join ', ')" }
        else { Warn "manifest.platforms is empty" }
    } catch {
        Fail "manifest JSON is invalid: $_"
    }
} else {
    Fail "cambric.manifest.json not found"
}

# ──────────────────────────────────────────────────────────────────────────────
Section "CONFIG VALIDATION"
# ──────────────────────────────────────────────────────────────────────────────

$configPath = Join-Path $root "app\lib\core\config\cambric_config.json"
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        if ($config.product.id) { Pass "config.product.id: $($config.product.id)" }
        else { Warn "config.product.id is empty" }
        if ($config.product.version) { Pass "config.product.version: $($config.product.version)" }
        else { Warn "config.product.version is empty" }
    } catch {
        Fail "cambric_config.json is invalid JSON: $_"
    }
} else {
    Fail "cambric_config.json not found"
}


# ──────────────────────────────────────────────────────────────────────────────
Section "TEMPLATE VERSION CHECK"
# ──────────────────────────────────────────────────────────────────────────────

$stateDir  = Join-Path $root ".cambric"
$stateFile = Join-Path $stateDir "state.json"
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null

$currentTplVer = "0.1.0"
if (Test-Path $configPath) {
    try {
        $cfgT = Get-Content $configPath -Raw | ConvertFrom-Json
        if ($cfgT.product.templateVersion) { $currentTplVer = $cfgT.product.templateVersion }
    } catch {}
}

$useCached = $false
if (Test-Path $stateFile) {
    try {
        $st = Get-Content $stateFile -Raw | ConvertFrom-Json
        if ($st.templateVersionCheck) {
            $ts = [datetime]::Parse($st.templateVersionCheck.timestamp)
            if (([datetime]::Now - $ts).TotalHours -lt 24) { $useCached = $true }
        }
    } catch {}
}

if ($useCached) {
    $cached = $st.templateVersionCheck
    if ($cached.latestVersion -and $cached.latestVersion -ne $currentTplVer) {
        Warn "Template update available: $($cached.latestVersion) (you have $currentTplVer) — github.com/Cambric-software/app-template"
    } else { Pass "Template version: up to date ($currentTplVer)" }
} else {
    try {
        $resp = Invoke-WebRequest `
            -Uri "https://api.github.com/repos/Cambric-software/app-template/releases/latest" `
            -Headers @{Accept="application/vnd.github+json"} `
            -UseBasicParsing -TimeoutSec 6 2>$null
        $latest = ($resp.Content | ConvertFrom-Json).tag_name -replace '^v',''
        $stObj = if (Test-Path $stateFile) { Get-Content $stateFile -Raw | ConvertFrom-Json } else { [PSCustomObject]@{} }
        $stObj | Add-Member -NotePropertyName "templateVersionCheck" -NotePropertyValue ([PSCustomObject]@{
            latestVersion=$latest; currentVersion=$currentTplVer; timestamp=(Get-Date).ToString("o")
        }) -Force
        $stObj | ConvertTo-Json -Depth 5 | Set-Content $stateFile -Encoding UTF8
        if ($latest -and $latest -ne $currentTplVer) {
            Warn "Template update: $latest available (you have $currentTplVer)"
        } else { Pass "Template version: up to date ($currentTplVer)" }
    } catch { Pass "Template version: check skipped (offline or rate-limited)" }
}

# Record this doctor run in .cambric/state.json
$drObj = if (Test-Path $stateFile) { Get-Content $stateFile -Raw | ConvertFrom-Json } else { [PSCustomObject]@{} }
$drObj | Add-Member -NotePropertyName "lastDoctor" -NotePropertyValue ([PSCustomObject]@{
    timestamp=(Get-Date).ToString("o"); passed=($failed -eq 0)
}) -Force
$drObj | ConvertTo-Json -Depth 5 | Set-Content $stateFile -Encoding UTF8


# ──────────────────────────────────────────────────────────────────────────────
Section "VERSION DRIFT CHECK"
# ──────────────────────────────────────────────────────────────────────────────
# Verifies that cambric_config.json version matches pubspec.yaml version.
# These must stay in sync — divergence causes diagnostic confusion.

$pubspecPath2 = Join-Path $root "app\pubspec.yaml"
$configPath2  = Join-Path $root "app\lib\core\config\cambric_config.json"

if ((Test-Path $pubspecPath2) -and (Test-Path $configPath2)) {
    try {
        $pubspecRaw = Get-Content $pubspecPath2 -Raw
        $pubspecVersion = [regex]::Match($pubspecRaw, '^version:\s*(\S+)', 'Multiline').Groups[1].Value
        # Strip build suffix (+N)
        $pubspecSemver = $pubspecVersion -replace '\+.*$', ''

        $cfg = Get-Content $configPath2 -Raw | ConvertFrom-Json
        $configVersion = $cfg.product.version

        if ($pubspecSemver -and $configVersion) {
            if ($pubspecSemver -eq $configVersion) {
                Pass "Version in sync: pubspec=$pubspecSemver, config=$configVersion"
            } else {
                Fail "VERSION DRIFT: pubspec.yaml version=$pubspecSemver but cambric_config.json version=$configVersion — run: dart run scripts/cambric.dart release <version>"
            }
        } else {
            Warn "Could not read version from pubspec or config"
        }
    } catch {
        Warn "Version drift check failed: $_"
    }
} else {
    Warn "Skipping version drift check — files missing"
}

# ──────────────────────────────────────────────────────────────────────────────
Section "VERSION DRIFT CHECK"
# ──────────────────────────────────────────────────────────────────────────────

$pubspecPath2 = Join-Path $root "app\pubspec.yaml"
$configPath2  = Join-Path $root "app\lib\core\config\cambric_config.json"

if ((Test-Path $pubspecPath2) -and (Test-Path $configPath2)) {
    try {
        $pubspecRaw    = Get-Content $pubspecPath2 -Raw
        $pubspecVer    = [regex]::Match($pubspecRaw, '^version:\s*(\S+)', 'Multiline').Groups[1].Value -replace '\+.*$', ''
        $cfg           = Get-Content $configPath2 -Raw | ConvertFrom-Json
        $configVer     = $cfg.product.version
        if ($pubspecVer -and $configVer) {
            if ($pubspecVer -eq $configVer) { Pass "Versions in sync: $pubspecVer" }
            else { Fail "VERSION DRIFT: pubspec=$pubspecVer config=$configVer — run: dart run scripts/cambric.dart release <version>" }
        } else { Warn "Could not read version from pubspec or config" }
    } catch { Warn "Version drift check failed: $_" }
} else { Warn "Skipping version drift check — files missing" }

# ──────────────────────────────────────────────────────────────────────────────
Section "CORRUPTED FILENAMES"
# ──────────────────────────────────────────────────────────────────────────────

$libPath = Join-Path $root "app\lib"
$corruptedPattern = [regex]'(_[a-z]{2}){3,}'
$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"
$corrupted = $dartFiles | Where-Object { $corruptedPattern.IsMatch($_.BaseName) }
if ($corrupted.Count -gt 0) {
    Warn "$($corrupted.Count) file(s) with potentially corrupted names found"
    $corrupted | Select-Object -First 5 | ForEach-Object { Warn "  $($_.FullName)" }
} else {
    Pass "No corrupted filenames detected"
}

# ──────────────────────────────────────────────────────────────────────────────
Section "SECRET SCAN"
# ──────────────────────────────────────────────────────────────────────────────

$secretPatterns = @(
    'AKIA[A-Z0-9]{16}',
    'ghp_[A-Za-z0-9]{36}',
    '-----BEGIN (RSA |EC )?PRIVATE KEY-----',
    'password\s*=\s*["\x27]\S+["\x27]',
    'api_key\s*=\s*["\x27]\S+["\x27]'
)

$secretFound = $false
$dartFiles | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    foreach ($pattern in $secretPatterns) {
        if ($content -match $pattern) {
            Warn "Possible secret in: $($_.FullName)"
            $secretFound = $true
        }
    }
}
if (-not $secretFound) { Pass "No obvious secrets detected in Dart files" }

# ──────────────────────────────────────────────────────────────────────────────
Section "PUBSPEC"
# ──────────────────────────────────────────────────────────────────────────────

$pubspecPath = Join-Path $root "app\pubspec.yaml"
if (Test-Path $pubspecPath) {
    $pubspecContent = Get-Content $pubspecPath -Raw
    $depCount = ([regex]::Matches($pubspecContent, '^dependencies:', 'Multiline')).Count
    if ($depCount -gt 1) {
        Fail "pubspec.yaml has $depCount 'dependencies:' blocks (must be exactly 1)"
    } else {
        Pass "pubspec.yaml has exactly 1 dependencies block"
    }
} else {
    Fail "pubspec.yaml not found"
}

# ──────────────────────────────────────────────────────────────────────────────
Section "SUMMARY"
# ──────────────────────────────────────────────────────────────────────────────

Write-Host ""
if ($failed -gt 0) {
    Write-Host "DOCTOR FAILED: $failed error(s), $warnings warning(s)" -ForegroundColor Red
    exit 1
} elseif ($warnings -gt 0) {
    Write-Host "DOCTOR PASSED with $warnings warning(s)" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "DOCTOR PASSED - no issues found" -ForegroundColor Green
    exit 0
}
