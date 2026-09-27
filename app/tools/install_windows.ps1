# Windows installation helper for Cambric app projects.
# Run after building the Windows application.

param(
    [string]$BuildPath = ".\app\build\windows\x64\runner\Release",
    [string]$InstallName = "CambricApp"
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $BuildPath)) {
    Write-Error "Windows build was not found at $BuildPath. Run: flutter build windows"
    exit 1
}

$InstallRoot = Join-Path $env:LOCALAPPDATA $InstallName
New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
Copy-Item "$BuildPath\*" $InstallRoot -Recurse -Force

$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $Desktop "$InstallName.lnk"
$Exe = Join-Path $InstallRoot "$InstallName.exe"

if (Test-Path $Exe) {
    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $Exe
    $Shortcut.WorkingDirectory = $InstallRoot
    $Shortcut.Save()
}

Write-Host "Installed to $InstallRoot"
Write-Host "Desktop shortcut: $ShortcutPath"
