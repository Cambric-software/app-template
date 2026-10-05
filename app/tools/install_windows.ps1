# Windows installation helper for Cambric app projects.
# Run from the repository root after building the Windows application.
#
# Usage:
#   .\app\tools\install_windows.ps1
#   .\app\tools\install_windows.ps1 -BuildPath ".\app\build\windows\x64\runner\Release" -InstallName "MyApp"

param(
    [string]$BuildPath  = ".\app\build\windows\x64\runner\Release",
    [string]$InstallName = "CambricApp",
    [switch]$NoShortcut
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $BuildPath)) {
    Write-Error "Windows build was not found at '$BuildPath'. Run: cd app && flutter build windows --release"
    exit 1
}

# Install to %LOCALAPPDATA%\<InstallName>
$InstallRoot = Join-Path $env:LOCALAPPDATA $InstallName
New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
Copy-Item "$BuildPath\*" $InstallRoot -Recurse -Force

Write-Host "Installed to: $InstallRoot"

# Create a desktop shortcut unless suppressed
if (-not $NoShortcut) {
    $Desktop = [Environment]::GetFolderPath("Desktop")
    $ShortcutPath = Join-Path $Desktop "$InstallName.lnk"

    # Look for any .exe in the install root
    $Exe = Get-ChildItem -Path $InstallRoot -Filter "*.exe" | Select-Object -First 1

    if ($Exe) {
        $Shell = New-Object -ComObject WScript.Shell
        $Shortcut = $Shell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $Exe.FullName
        $Shortcut.WorkingDirectory = $InstallRoot
        $Shortcut.Save()
        Write-Host "Desktop shortcut created: $ShortcutPath"
    } else {
        Write-Warning "No .exe found in $InstallRoot — desktop shortcut was not created."
    }
}
