#!/usr/bin/env pwsh
# Cambric App Template — Changelog Generator
# Run: .\scripts\cambric-changelog.ps1
#
# Reads git log since last tag, writes CHANGELOG.md entry.
# Records run in .cambric/state.json

$ErrorActionPreference = "Stop"
$root = Get-Location

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Cambric — Changelog Generator          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Read version from config
$version = "0.1.0"
$configPath = Join-Path $root "app\lib\core\config\cambric_config.json"
if (Test-Path $configPath) {
    try {
        $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
        $version = $cfg.product.version
    } catch {}
}

# Find last tag
$lastTag = ""
try { $lastTag = git describe --tags --abbrev=0 2>$null } catch {}
if ($lastTag) { Write-Host "Last tag: $lastTag" } else { Write-Host "No previous tag found." }
Write-Host "Current version: $version"
Write-Host ""

# Get commits since last tag
$range = if ($lastTag) { "$lastTag..HEAD" } else { "HEAD" }
$commits = @(git log $range --oneline --no-merges 2>$null)
if ($commits.Count -eq 0) {
    Write-Host "No new commits since $lastTag. Nothing to changelog."
    exit 0
}

Write-Host "$($commits.Count) commit(s) to include:"
$commits | Select-Object -First 5 | ForEach-Object { Write-Host "  • $_" }
if ($commits.Count -gt 5) { Write-Host "  ... and $($commits.Count - 5) more" }
Write-Host ""

# Strip hashes, get messages
$messages = $commits | ForEach-Object { ($_ -replace '^\S+\s+', '').Trim() }

# Categorize
$features = @($messages | Where-Object { $_ -match '^feat' })
$fixes    = @($messages | Where-Object { $_ -match '^fix' })
$others   = @($messages | Where-Object { $_ -notmatch '^feat' -and $_ -notmatch '^fix' })

function Clean-Message($msg) {
    return $msg -replace '^(feat|fix|chore|docs|refactor|test|style)(\([^)]+\))?:\s*', ''
}

# Build entry
$date = (Get-Date).ToString("yyyy-MM-dd")
$entry = "## [$version] — $date`n`n"
if ($features.Count -gt 0) {
    $entry += "### Added`n"
    $features | ForEach-Object { $entry += "- $(Clean-Message $_)`n" }
    $entry += "`n"
}
if ($fixes.Count -gt 0) {
    $entry += "### Fixed`n"
    $fixes | ForEach-Object { $entry += "- $(Clean-Message $_)`n" }
    $entry += "`n"
}
if ($others.Count -gt 0) {
    $entry += "### Changed`n"
    $others | ForEach-Object { $entry += "- $(Clean-Message $_)`n" }
    $entry += "`n"
}

# Prepend to CHANGELOG.md
$changelogPath = Join-Path $root "CHANGELOG.md"
$header = "# Changelog`n`nAll notable changes to this project are documented here.`n`n"
if (Test-Path $changelogPath) {
    $existing = Get-Content $changelogPath -Raw
    $rest = if ($existing -match '(?s)# Changelog\n\n[^\n]*\n\n(.*)') { $Matches[1] } else { $existing }
    $output = $header + $entry + $rest
} else {
    $output = $header + $entry
}
$output | Set-Content $changelogPath -Encoding UTF8
Write-Host "  ✓ CHANGELOG.md updated" -ForegroundColor Green

# Record in .cambric/state.json
$stateDir = Join-Path $root ".cambric"
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
$stateFile = Join-Path $stateDir "state.json"
$state = if (Test-Path $stateFile) { Get-Content $stateFile -Raw | ConvertFrom-Json } else { [PSCustomObject]@{} }
$state | Add-Member -NotePropertyName "lastChangelog" -NotePropertyValue ([PSCustomObject]@{
    version = $version; date = $date; commitsIncluded = $commits.Count
    timestamp = (Get-Date).ToString("o")
}) -Force
$state | ConvertTo-Json -Depth 5 | Set-Content $stateFile -Encoding UTF8

Write-Host ""
Write-Host "Done. Review CHANGELOG.md before committing." -ForegroundColor Green
Write-Host ""
