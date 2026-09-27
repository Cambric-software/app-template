param(
    [string]$ProjectName,
    [string]$Description,
    [string]$Publisher,
    [string]$Repository
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== CAMBRIC APP SETUP ===" -ForegroundColor Cyan
Write-Host ""

# ── Prompt for missing values ─────────────────────────────────────────────────

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Read-Host "Project name (e.g. My Cambric App)"
}
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    throw "Project name cannot be empty."
}

if ([string]::IsNullOrWhiteSpace($Description)) {
    $Description = Read-Host "Short description (optional, press Enter to skip)"
}

if ([string]::IsNullOrWhiteSpace($Publisher)) {
    $Publisher = Read-Host "Publisher / company (optional, press Enter to skip)"
}

if ([string]::IsNullOrWhiteSpace($Repository)) {
    $Repository = Read-Host "GitHub repository (owner/repo, optional, press Enter to skip)"
}

# ── Derive product ID ─────────────────────────────────────────────────────────

$productId = ($ProjectName.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')

Write-Host ""
Write-Host "Project name : $ProjectName"
Write-Host "Product ID   : $productId"
if ($Description) { Write-Host "Description  : $Description" }
if ($Publisher)   { Write-Host "Publisher    : $Publisher" }
if ($Repository)  { Write-Host "Repository   : $Repository" }
Write-Host ""

$confirm = Read-Host "Apply these settings? [Y/n]"
if ($confirm -match '^[Nn]') {
    Write-Host "Setup cancelled." -ForegroundColor Yellow
    exit 0
}

$root = Get-Location

# ── Update cambric.manifest.json ─────────────────────────────────────────────

$manifestPath = Join-Path $root "app\cambric.manifest.json"
if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $manifest.name = $ProjectName
    $manifest.productId = $productId
    $manifest | ConvertTo-Json -Depth 20 | Set-Content $manifestPath -Encoding UTF8
    Write-Host "  Updated: app\cambric.manifest.json" -ForegroundColor Green
} else {
    Write-Host "  WARN: cambric.manifest.json not found" -ForegroundColor Yellow
}

# ── Update cambric_config.json ────────────────────────────────────────────────

$configPath = Join-Path $root "app\lib\core\config\cambric_config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    $config.product.name = $ProjectName
    $config.product.id = $productId

    if ($Description)  { $config.product.description = $Description }
    if ($Publisher)    { $config.product.publisher = $Publisher }
    if ($Repository)   { $config.release.repository = $Repository }

    $config | ConvertTo-Json -Depth 20 | Set-Content $configPath -Encoding UTF8
    Write-Host "  Updated: app\lib\core\config\cambric_config.json" -ForegroundColor Green
} else {
    Write-Host "  WARN: cambric_config.json not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  1. cd app"
Write-Host "  2. flutter pub get"
Write-Host "  3. flutter run"
Write-Host ""
