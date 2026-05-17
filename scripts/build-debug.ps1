# ============================================================
# Build DEBUG APK from Windows
# Output: android/app/build/outputs/apk/debug/app-debug.apk
# ============================================================
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

Write-Host "=== Building Debug APK ===" -ForegroundColor Cyan

# Sync web assets first
Write-Host "Syncing web assets..." -ForegroundColor Yellow
& "$PSScriptRoot\copy-web.ps1"
Set-Location $root
npx cap sync android
if ($LASTEXITCODE -ne 0) { throw "cap sync failed" }

# Build APK
Write-Host "Running Gradle assembleDebug..." -ForegroundColor Yellow
Set-Location "$root\android"
.\gradlew.bat assembleDebug --no-daemon
if ($LASTEXITCODE -ne 0) { throw "Gradle build failed" }

$apk = "$root\android\app\build\outputs\apk\debug\app-debug.apk"
Write-Host ""
Write-Host "✓ Debug APK built successfully!" -ForegroundColor Green
Write-Host "  Path: $apk" -ForegroundColor White

# Optional: copy to project root for easy access
Copy-Item $apk "$root\billar-pro-debug.apk" -Force
Write-Host "  Copied to: $root\billar-pro-debug.apk" -ForegroundColor White
Write-Host ""
Write-Host "Install on connected device:" -ForegroundColor Yellow
Write-Host "  adb install billar-pro-debug.apk" -ForegroundColor Gray
