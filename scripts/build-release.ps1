# ============================================================
# Build SIGNED RELEASE APK/AAB from Windows
# Prerequisites:
#   - keystore.jks in project root (see instructions below)
#   - Environment variables set (see below)
# ============================================================
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

# ── Signing config ──────────────────────────────────────────
# Set these before running, or add to your environment:
#   $env:KEYSTORE_PATH     = "C:\path\to\keystore.jks"
#   $env:KEYSTORE_PASSWORD = "your_store_password"
#   $env:KEY_ALIAS         = "billar-pro"
#   $env:KEY_PASSWORD      = "your_key_password"

$keystorePath = $env:KEYSTORE_PATH
$keystorePass = $env:KEYSTORE_PASSWORD
$keyAlias     = $env:KEY_ALIAS
$keyPass      = $env:KEY_PASSWORD

if (-not $keystorePath) {
    Write-Host ""
    Write-Host "ERROR: Signing env vars not set." -ForegroundColor Red
    Write-Host ""
    Write-Host "To create a keystore (run once):" -ForegroundColor Yellow
    Write-Host '  keytool -genkey -v -keystore keystore.jks -alias billar-pro -keyalg RSA -keysize 2048 -validity 10000' -ForegroundColor Gray
    Write-Host ""
    Write-Host "Then set environment variables:" -ForegroundColor Yellow
    Write-Host '  $env:KEYSTORE_PATH     = "$PWD\keystore.jks"' -ForegroundColor Gray
    Write-Host '  $env:KEYSTORE_PASSWORD = "yourpassword"' -ForegroundColor Gray
    Write-Host '  $env:KEY_ALIAS         = "billar-pro"' -ForegroundColor Gray
    Write-Host '  $env:KEY_PASSWORD      = "yourpassword"' -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "=== Building Signed Release AAB ===" -ForegroundColor Cyan

# Sync
& "$PSScriptRoot\copy-web.ps1"
Set-Location $root
npx cap sync android

# Write signing config to local.properties (gitignored)
$localProps = @"
sdk.dir=$env:ANDROID_HOME
MYAPP_RELEASE_STORE_FILE=$keystorePath
MYAPP_RELEASE_STORE_PASSWORD=$keystorePass
MYAPP_RELEASE_KEY_ALIAS=$keyAlias
MYAPP_RELEASE_KEY_PASSWORD=$keyPass
"@
$localProps | Out-File "$root\android\local.properties" -Encoding utf8

# Build release AAB (for Play Store)
Set-Location "$root\android"
.\gradlew.bat bundleRelease --no-daemon
if ($LASTEXITCODE -ne 0) { throw "Gradle bundleRelease failed" }

$aab = "$root\android\app\build\outputs\bundle\release\app-release.aab"
Copy-Item $aab "$root\billar-pro-release.aab" -Force

Write-Host ""
Write-Host "✓ Signed Release AAB built!" -ForegroundColor Green
Write-Host "  $root\billar-pro-release.aab" -ForegroundColor White
Write-Host ""
Write-Host "Upload billar-pro-release.aab to Google Play Console." -ForegroundColor Yellow
