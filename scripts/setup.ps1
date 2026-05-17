# ============================================================
# Billar Pro — Capacitor setup script for Windows
# Run once after cloning the repo.
# ============================================================
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

Write-Host ""
Write-Host "=== Billar Pro — Capacitor Setup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Install dependencies
Write-Host "1/5  Installing npm dependencies..." -ForegroundColor Yellow
Set-Location $root
npm install
if ($LASTEXITCODE -ne 0) { throw "npm install failed" }
Write-Host "     ✓ Done" -ForegroundColor Green

# 2. Copy web assets
Write-Host "2/5  Copying web assets to www/..." -ForegroundColor Yellow
& "$PSScriptRoot\copy-web.ps1"

# 3. Add Android platform (safe to run if already added)
Write-Host "3/5  Adding Android platform..." -ForegroundColor Yellow
npx cap add android 2>&1 | ForEach-Object {
    if ($_ -match "already added") { Write-Host "     (already added, skipping)" -ForegroundColor DarkGray }
    else { Write-Host "     $_" }
}
Write-Host "     ✓ Done" -ForegroundColor Green

# 4. Add iOS platform (generates folder; final build needs macOS)
Write-Host "4/5  Adding iOS platform..." -ForegroundColor Yellow
npx cap add ios 2>&1 | ForEach-Object {
    if ($_ -match "already added") { Write-Host "     (already added, skipping)" -ForegroundColor DarkGray }
    else { Write-Host "     $_" }
}
Write-Host "     ✓ Done (iOS folder ready for macOS)" -ForegroundColor Green

# 5. Sync
Write-Host "5/5  Syncing Capacitor..." -ForegroundColor Yellow
npx cap sync
Write-Host "     ✓ Done" -ForegroundColor Green

Write-Host ""
Write-Host "=== Setup complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  Android:  npm run open:android   (opens Android Studio)" -ForegroundColor Gray
Write-Host "  Debug APK: npm run build:debug" -ForegroundColor Gray
Write-Host "  iOS:      Copy ios/ to macOS and open in Xcode" -ForegroundColor Gray
Write-Host ""
