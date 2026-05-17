# Copies billar.html → www/index.html (Capacitor's webDir)
$src = Join-Path $PSScriptRoot "..\billar.html"
$dst = Join-Path $PSScriptRoot "..\www\index.html"
Copy-Item -Path $src -Destination $dst -Force
Write-Host "✓ Copied billar.html → www/index.html" -ForegroundColor Green
