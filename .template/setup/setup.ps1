#!/usr/bin/env pwsh
# Cambric App Template — Setup Wizard
# Run: .\.template\setup\setup.ps1
#
# Asks all the right questions for any type of application —
# utility, productivity, social, dashboard, e-commerce, tools, etc.
# Configures the template for your specific use case.

param(
    [string]$ProjectName,
    [string]$Description
)

$ErrorActionPreference = "Stop"

function Write-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Cambric App Template — Setup         ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Prompt-Value([string]$Question, [string]$Default = "") {
    $hint = if ($Default) { " [$Default]" } else { "" }
    $input = Read-Host "$Question$hint"
    if ([string]::IsNullOrWhiteSpace($input) -and $Default) { return $Default }
    return $input.Trim()
}

function Prompt-Choice([string]$Question, [string[]]$Options, [int]$DefaultIndex = 0) {
    Write-Host "$Question" -ForegroundColor Yellow
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($i -eq $DefaultIndex) { ">" } else { " " }
        Write-Host "  $marker $($i+1). $($Options[$i])"
    }
    $input = Read-Host "Choice [$($DefaultIndex+1)]"
    if ([string]::IsNullOrWhiteSpace($input)) { return $Options[$DefaultIndex] }
    $n = [int]::TryParse($input, [ref]$null) ? [int]$input : 0
    if ($n -ge 1 -and $n -le $Options.Count) { return $Options[$n-1] }
    return $Options[$DefaultIndex]
}

function Prompt-MultiChoice([string]$Question, [string[]]$Options, [int[]]$Defaults = @()) {
    Write-Host "$Question (comma-separated numbers, e.g. 1,2,3)" -ForegroundColor Yellow
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  $($i+1). $($Options[$i])"
    }
    $defaultStr = ($Defaults | ForEach-Object { $_ + 1 }) -join ","
    $input = Read-Host "Choices [$defaultStr]"
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Defaults | ForEach-Object { $Options[$_] }
    }
    $result = @()
    foreach ($part in $input.Split(",")) {
        $n = $part.Trim()
        if ($n -match '^\d+$') {
            $idx = [int]$n - 1
            if ($idx -ge 0 -and $idx -lt $Options.Count) { $result += $Options[$idx] }
        }
    }
    return if ($result.Count -gt 0) { $result } else { $Defaults | ForEach-Object { $Options[$_] } }
}

function Prompt-YesNo([string]$Question, [bool]$DefaultYes = $true) {
    $hint = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }
    $input = Read-Host "$Question $hint"
    if ([string]::IsNullOrWhiteSpace($input)) { return $DefaultYes }
    return $input.Trim().ToLower() -eq "y"
}

function To-KebabCase([string]$s) {
    return ($s.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
}

# ── Safety check ──────────────────────────────────────────────────────────────

$root = Get-Location
$configPath = Join-Path $root "app\lib\core\config\cambric_config.json"

if (Test-Path $configPath) {
    $existingConfig = Get-Content $configPath -Raw | ConvertFrom-Json
    $existingName = $existingConfig.product.name
    if ($existingName -and $existingName -ne "Cambric App Product" -and $existingName -ne "") {
        Write-Host ""
        Write-Host "This project is already configured as `"$existingName`"." -ForegroundColor Yellow
        $overwrite = Prompt-YesNo "Overwrite existing configuration?" $false
        if (-not $overwrite) {
            Write-Host "Setup cancelled. Existing configuration preserved." -ForegroundColor Yellow
            exit 0
        }
    }
}

Write-Banner

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: App Identity
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host "═══ App Identity ═══════════════════════════════" -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Prompt-Value "App name" "My App"
}
$productId   = To-KebabCase $ProjectName
$productId   = Prompt-Value "App ID (lowercase-hyphen)" $productId
$packageId   = Prompt-Value "Package ID (e.g. com.company.appname)" "com.cambric.$($productId.Replace('-',''))"
$developer   = Prompt-Value "Developer / company" "Cambric"
$publisher   = Prompt-Value "Publisher" $developer
$version     = Prompt-Value "Initial version" "0.1.0"
$repository  = Prompt-Value "GitHub repository (owner/repo, optional)" ""

if ([string]::IsNullOrWhiteSpace($Description)) {
    $Description = Prompt-Value "Short description" "A Cambric application"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: App Type
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ App Type ═══════════════════════════════════" -ForegroundColor Cyan

$appType = Prompt-Choice "What kind of app are you building?" @(
    "Productivity (tasks, notes, documents)"
    "Utility (tools, converters, calculators)"
    "Dashboard (data, charts, monitoring)"
    "Social / Community"
    "E-commerce / Marketplace"
    "Media (photos, video, music)"
    "Health & Fitness"
    "Finance & Budget"
    "Education / Learning"
    "Developer Tool"
    "Custom / Other"
) 0

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: Target Platforms
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Target Platforms ═══════════════════════════" -ForegroundColor Cyan

$platforms = Prompt-MultiChoice "Target platforms" @(
    "Android"
    "Windows"
    "Linux"
) @(0,1,2)

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: Display & Orientation
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Display & Orientation ══════════════════════" -ForegroundColor Cyan

$orientation = Prompt-Choice "Screen orientation" @(
    "Portrait (mobile-first)"
    "Landscape (desktop/tablet)"
    "Adaptive (both)"
) 2

$themeDefault = Prompt-Choice "Default theme" @(
    "Light"
    "Dark"
    "Follow system"
) 2

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: Navigation
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Navigation ═════════════════════════════════" -ForegroundColor Cyan

$navigation = Prompt-Choice "Navigation pattern" @(
    "Bottom navigation bar (mobile)"
    "Side drawer"
    "Top tab bar"
    "Single screen (no navigation)"
    "Master-detail (tablet/desktop)"
) 0

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 6: Authentication
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Authentication ══════════════════════════════" -ForegroundColor Cyan

$authNeeded = Prompt-YesNo "Does the app require user authentication?" $false

$authType = "none"
if ($authNeeded) {
    $authType = Prompt-Choice "Authentication type" @(
        "Local PIN / passcode"
        "Biometric (fingerprint/face)"
        "Email + password (needs backend)"
        "OAuth / social login (needs backend)"
        "API key"
    ) 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 7: Language & Localization
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Language & Localization ════════════════════" -ForegroundColor Cyan

$languageChoice = Prompt-Choice "Supported languages" @(
    "English only"
    "Arabic only (RTL)"
    "English + Arabic (RTL)"
    "English + other (add later)"
) 0

$locales = switch ($languageChoice) {
    "Arabic only (RTL)"           { @("ar") }
    "English + Arabic (RTL)"      { @("en","ar") }
    "English + other (add later)" { @("en") }
    default                       { @("en") }
}
$defaultLanguage = $locales[0]

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 8: Features
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Features ═══════════════════════════════════" -ForegroundColor Cyan

$features = Prompt-MultiChoice "Include these infrastructure features" @(
    "Offline support (local-first)"
    "Cache system"
    "Update checker (GitHub Releases)"
    "Ecosystem integration (Cambric products)"
    "Diagnostics & logging"
    "Backup & restore"
) @(0,1,2)

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 9: Mode
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Development Mode ═══════════════════════════" -ForegroundColor Cyan

$envMode = Prompt-Choice "Environment mode" @(
    "development"
    "production"
) 0

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══ Summary ════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Name:         $ProjectName"
Write-Host "  ID:           $productId"
Write-Host "  Package:      $packageId"
Write-Host "  Developer:    $developer"
Write-Host "  Version:      $version"
Write-Host "  App type:     $appType"
Write-Host "  Platforms:    $($platforms -join ', ')"
Write-Host "  Orientation:  $orientation"
Write-Host "  Theme:        $themeDefault"
Write-Host "  Navigation:   $navigation"
Write-Host "  Auth:         $(if ($authNeeded) { $authType } else { 'none' })"
Write-Host "  Languages:    $($locales -join ', ')"
Write-Host "  Features:     $($features -join ', ')"
Write-Host "  Mode:         $envMode"
Write-Host ""

$confirm = Prompt-YesNo "Apply these settings?" $true
if (-not $confirm) {
    Write-Host "Setup cancelled." -ForegroundColor Yellow
    exit 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# APPLY
# ═══════════════════════════════════════════════════════════════════════════════

# ── cambric_config.json ───────────────────────────────────────────────────────

if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    $config.product.name        = $ProjectName
    $config.product.id          = $productId
    $config.product.description = $Description
    $config.product.publisher   = $publisher
    $config.product.version     = $version
    if ($repository) { $config.release.repository = $repository }

    $config.localization.defaultLanguage   = $defaultLanguage
    $config.localization.supportedLanguages = $locales
    $config.localization.rtlLanguages       = @($locales | Where-Object { $_ -eq "ar" })

    $config.environment = $envMode

    # Feature flags derived from selected features
    $flagOffline    = $features -contains "Offline support (local-first)"
    $flagCache      = $features -contains "Cache system"
    $flagUpdates    = $features -contains "Update checker (GitHub Releases)"
    $flagEcosystem  = $features -contains "Ecosystem integration (Cambric products)"
    $flagDiag       = $features -contains "Diagnostics & logging"
    $flagBackup     = $features -contains "Backup & restore"

    $config.featureFlags = [PSCustomObject]@{
        offlineSupport       = $flagOffline
        cacheEnabled         = $flagCache
        updatesEnabled       = $flagUpdates
        ecosystemEnabled     = $flagEcosystem
        diagnosticsEnabled   = $flagDiag
        backupEnabled        = $flagBackup
        showDeveloperTools   = ($envMode -eq "development")
    }

    $config.update.enabled = $flagUpdates
    $config.ecosystem.enabled = $flagEcosystem

    # Store wizard metadata in config (non-functional, for reference)
    $config | Add-Member -NotePropertyName "appMeta" -NotePropertyValue ([PSCustomObject]@{
        appType    = $appType
        platforms  = $platforms
        orientation = $orientation
        themeDefault = $themeDefault
        navigation = $navigation
        authType   = $authType
    }) -Force

    $config | ConvertTo-Json -Depth 20 | Set-Content $configPath -Encoding UTF8
    Write-Host "  ✓ cambric_config.json updated" -ForegroundColor Green
}

# ── cambric.manifest.json ─────────────────────────────────────────────────────

$manifestPath = Join-Path $root "app\cambric.manifest.json"
if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $manifest.name        = $ProjectName
    $manifest.productId   = $productId
    $manifest.version     = $version
    $manifest.description = $Description
    if (-not $manifest.PSObject.Properties["platforms"]) {
        $manifest | Add-Member -NotePropertyName "platforms" -NotePropertyValue @() -Force
    }
    $manifest.platforms = $platforms | ForEach-Object { $_.Split(" ")[0].ToLower() }
    $manifest | ConvertTo-Json -Depth 20 | Set-Content $manifestPath -Encoding UTF8
    Write-Host "  ✓ cambric.manifest.json updated" -ForegroundColor Green
}

# ── pubspec.yaml version ──────────────────────────────────────────────────────

$pubspecPath = Join-Path $root "app\pubspec.yaml"
if (Test-Path $pubspecPath) {
    $pubspec = Get-Content $pubspecPath -Raw
    $pubspec = $pubspec -replace '(?m)^version:.*$', "version: $version+1"
    $pubspec | Set-Content $pubspecPath -Encoding UTF8
    Write-Host "  ✓ pubspec.yaml version set to $version+1" -ForegroundColor Green
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd app && flutter pub get"
Write-Host "  2. flutter run"
Write-Host "  3. dart run scripts/cambric.dart doctor"
Write-Host ""
if ($authNeeded -and ($authType -like "*backend*" -or $authType -like "*OAuth*")) {
    Write-Host "Note: Authentication type '$authType' requires a backend service." -ForegroundColor Yellow
    Write-Host "      This template is local-first — add your auth layer in lib/services/." -ForegroundColor Yellow
    Write-Host ""
}
