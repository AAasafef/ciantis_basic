$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

Write-Host "CIANTIS Calendar - Chrome" -ForegroundColor Cyan
Write-Host "Project: $PSScriptRoot"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter was not found in PATH." -ForegroundColor Red
    Write-Host "Open the PowerShell window where your Flutter command normally works, then run this script again."
    exit 1
}

flutter config --enable-web
flutter pub get

Write-Host ""
Write-Host "Launching CIANTIS Calendar in Chrome..." -ForegroundColor Green
flutter run -d chrome
