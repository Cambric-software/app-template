#!/usr/bin/env pwsh
# Cambric App Template — Install Wizard
# Run after building: .\.template\setup\install_wizard.ps1
#
# Guides through platform-specific installation of a release build.

param([string]$Platform)

$ErrorActionPreference = "Stop"

function Write-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    Cambric App — Install Wizard          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Prompt-Choice([string]$Q, [string[]]$Opts, [int]$Def = 0) {
    Write-Host $Q -ForegroundColor Yellow
    for ($i = 0; $i -lt $Opts.Count; $i++) {
        $m = if ($i -eq $Def) { ">" } else { " " }
        Write-Host "  $m $($i+1). $($Opts[$i])"
    }
    $inp = Read-Host "Choice [$($Def+1)]"
    if ([string]::IsNullOrWhiteSpace($inp)) { return $Opts[$Def] }
    $n = 0
    if ([int]::TryParse($inp, [ref]$n) -and $n -ge 1 -and $n -le $Opts.Count) { return $Opts[$n-1] }
    return $Opts[$Def]
}

function Prompt-YesNo([string]$Q, [bool]$Def = $true) {
    $h = if ($Def) { "[Y/n]" } else { "[y/N]" }
    $i = Read-Host "$Q $h"
    if ([string]::IsNullOrWhiteSpace($i)) { return $Def }
    return $i.Trim().ToLower() -eq "y"
}

Write-Banner

$root = Get-Location
$configPath = Join-Path $root "app\lib\core\config\cambric_config.json"
$appName = "Cambric App"
if (Test-Path $configPath) {
    try {
        $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
        $appName = $cfg.product.name
    } catch {}
}

Write-Host "App: $appName" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrWhiteSpace($Platform)) {
    $Platform = Prompt-Choice "Which platform did you build for?" @(
        "Windows"
        "Android"
        "Linux (CI build)"
    ) 0
}

switch -Regex ($Platform.ToLower()) {

    "^win" {
        Write-Host ""
        Write-Host "═══ Windows Installation ═══════════════════" -ForegroundColor Cyan

        $buildPath = Join-Path $root "app\build\windows\x64\runner\Release"
        if (-not (Test-Path $buildPath)) {
            Write-Host "Release build not found at: $buildPath" -ForegroundColor Red
            Write-Host "Build first:  dart run scripts/cambric.dart build windows" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Build found: $buildPath" -ForegroundColor Green

        $method = Prompt-Choice "Installation method" @(
            "Copy to local programs folder + optional desktop shortcut"
            "Create distributable ZIP with SHA-256 checksum"
            "Run directly from build folder"
        ) 0

        switch ($method) {
            "Copy to local programs folder + optional desktop shortcut" {
                $dest = "$env:LOCALAPPDATA\$appName"
                if (Prompt-YesNo "Install to `"$dest`"?") {
                    New-Item -ItemType Directory -Force -Path $dest | Out-Null
                    Copy-Item -Recurse -Force "$buildPath\*" $dest
                    Write-Host "  ✓ Installed to $dest" -ForegroundColor Green
                    if (Prompt-YesNo "Create desktop shortcut?") {
                        $exe = Get-ChildItem $dest -Filter "*.exe" | Select-Object -First 1
                        if ($exe) {
                            $ws = New-Object -ComObject WScript.Shell
                            $sc = $ws.CreateShortcut("$env:USERPROFILE\Desktop\$appName.lnk")
                            $sc.TargetPath = $exe.FullName
                            $sc.WorkingDirectory = $dest
                            $sc.Save()
                            Write-Host "  ✓ Desktop shortcut created" -ForegroundColor Green
                        }
                    }
                }
            }
            "Create distributable ZIP with SHA-256 checksum" {
                $zip = Join-Path $root "$appName-windows.zip"
                Compress-Archive -Path "$buildPath\*" -DestinationPath $zip -Force
                $hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
                "$hash  $appName-windows.zip" | Out-File "$zip.sha256" -Encoding ASCII
                Write-Host "  ✓ ZIP: $zip" -ForegroundColor Green
                Write-Host "  ✓ Checksum: $zip.sha256" -ForegroundColor Green
            }
            default {
                $exe = Get-ChildItem $buildPath -Filter "*.exe" | Select-Object -First 1
                if ($exe) { Write-Host "  Run: $($exe.FullName)" -ForegroundColor Green }
            }
        }
    }

    "^and|^apk" {
        Write-Host ""
        Write-Host "═══ Android Installation ════════════════════" -ForegroundColor Cyan

        $apk = Join-Path $root "app\build\app\outputs\flutter-apk\app-release.apk"
        if (-not (Test-Path $apk)) {
            Write-Host "APK not found at: $apk" -ForegroundColor Red
            Write-Host "Build first:  dart run scripts/cambric.dart build android" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "APK found: $apk" -ForegroundColor Green

        $method = Prompt-Choice "Installation method" @(
            "Install on connected device via adb"
            "Copy APK to current folder with checksum"
            "Show path only"
        ) 0

        switch ($method) {
            "Install on connected device via adb" {
                $adbExe = "adb"
                if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
                    $adbExe = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
                }
                try {
                    & $adbExe install -r $apk
                    Write-Host "  ✓ Installed on connected device" -ForegroundColor Green
                } catch {
                    Write-Host "  adb not found or no device connected." -ForegroundColor Red
                    Write-Host "  Ensure USB debugging is enabled and adb is on your PATH." -ForegroundColor Yellow
                }
            }
            "Copy APK to current folder with checksum" {
                $dest = Join-Path $root "$appName-android.apk"
                Copy-Item $apk $dest
                $hash = (Get-FileHash $dest -Algorithm SHA256).Hash.ToLower()
                "$hash  $appName-android.apk" | Out-File "$dest.sha256" -Encoding ASCII
                Write-Host "  ✓ APK: $dest" -ForegroundColor Green
                Write-Host "  ✓ Checksum: $dest.sha256" -ForegroundColor Green
            }
            default { Write-Host "  APK: $apk" -ForegroundColor Green }
        }
    }

    "^lin" {
        Write-Host ""
        Write-Host "═══ Linux Distribution ══════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Linux builds run on GitHub Actions (ubuntu-latest)." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Steps to distribute a Linux build:" -ForegroundColor Cyan
        Write-Host "  1. Push to main or trigger a manual workflow run"
        Write-Host "  2. Download the 'linux-bundle' artifact from GitHub Actions"
        Write-Host "  3. Extract: tar -xzf linux.tar.gz -C ~/.local/share/$(($appName.ToLower() -replace ' ','-'))"
        Write-Host "  4. Run:     bash app/tools/install_linux.sh"
        Write-Host ""
        Write-Host "See docs/TROUBLESHOOTING.md for the full Linux distribution guide." -ForegroundColor Dim
    }

    default {
        Write-Host "Unknown platform: $Platform" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ""
