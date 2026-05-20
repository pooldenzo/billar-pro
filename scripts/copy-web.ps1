# Sync billar.html into www/ (Capacitor) and docs/ (GitHub Pages mirror).
#
# billar.html is the source of truth. It references assets via ./docs/...
# because the per-ball SVGs and mode icons live in the /docs folder.
# Neither www/ nor docs/index.html serves from a /docs root, so we rewrite
# paths to a flat layout and copy assets into the bundle.
#
# Outputs:
#   www/index.html            - Capacitor webDir entry point
#   www/balls/ball-N.svg      - per-ball art
#   www/1.svg, www/5.svg      - mode-card icons
#   www/icons/                - PWA icons (used if served via browser)
#   www/manifest.json         - PWA manifest
#   docs/index.html           - GitHub Pages mirror (Pages-source = main/docs)
#
# Run from anywhere - paths are resolved relative to the repo root.

$ErrorActionPreference = 'Stop'

$root    = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$src     = Join-Path $root 'billar.html'
$wwwDir  = Join-Path $root 'www'
$docsDir = Join-Path $root 'docs'

if (-not (Test-Path $src))     { throw "Source not found: $src" }
if (-not (Test-Path $docsDir)) { throw "Asset source not found: $docsDir" }

# 1. Read source and transform.
$html = Get-Content -Raw -Encoding UTF8 $src

$pwaTags = "`n  <link rel=`"manifest`" href=`"./manifest.json`">" +
           "`n  <link rel=`"apple-touch-icon`" href=`"./icons/icon-192.svg`">" +
           "`n  <meta name=`"theme-color`" content=`"#09100c`">"

$titleTag = '<title>Billar Pro</title>'
if (-not $html.Contains($titleTag)) {
    throw "Could not find <title>Billar Pro</title> anchor in billar.html. PWA tag injection aborted."
}
$html = $html.Replace($titleTag, $titleTag + $pwaTags)

# Flatten asset paths: billar.html uses ./docs/... but bundles don't have a docs/ prefix.
$html = $html.Replace('./docs/balls/ball-', './balls/ball-').
              Replace('./docs/1.svg',  './1.svg').
              Replace('./docs/5.svg',  './5.svg')

# Sanity check - bail if any unexpected ./docs/ refs slipped through.
$leftover = [regex]::Matches($html, '\./docs/[^'')"\s]+').Count
if ($leftover -gt 0) {
    throw "Found $leftover unexpected ./docs/ asset references after rewrite. Update the script."
}

$utf8 = New-Object System.Text.UTF8Encoding $false

# 2. Write docs/index.html (GitHub Pages mirror). Assets already live under docs/.
$docsIndex = Join-Path $docsDir 'index.html'
[System.IO.File]::WriteAllText($docsIndex, $html, $utf8)
Write-Host "[ok] docs/index.html ($($html.Length) bytes)" -ForegroundColor Green

# 3. Build www/ bundle: index.html + asset folders copied from docs/.
if (-not (Test-Path $wwwDir)) { New-Item -ItemType Directory -Path $wwwDir | Out-Null }

$wwwIndex = Join-Path $wwwDir 'index.html'
[System.IO.File]::WriteAllText($wwwIndex, $html, $utf8)
Write-Host "[ok] www/index.html ($($html.Length) bytes)" -ForegroundColor Green

# Copy referenced assets from docs/ into www/.
$assets = @(
    @{ src = 'balls';         type = 'dir'  },
    @{ src = 'icons';         type = 'dir'  },
    @{ src = '1.svg';         type = 'file' },
    @{ src = '5.svg';         type = 'file' },
    @{ src = 'manifest.json'; type = 'file' }
)

foreach ($a in $assets) {
    $from = Join-Path $docsDir $a.src
    $to   = Join-Path $wwwDir  $a.src

    if (-not (Test-Path $from)) {
        Write-Warning "Missing asset: $from - skipped."
        continue
    }

    if ($a.type -eq 'dir') {
        if (Test-Path $to) { Remove-Item -Recurse -Force $to }
        Copy-Item -Recurse -Force $from $to
        $count = (Get-ChildItem -Recurse -File $to).Count
        Write-Host "[ok] www/$($a.src)/ ($count files)" -ForegroundColor Green
    } else {
        Copy-Item -Force $from $to
        Write-Host "[ok] www/$($a.src)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Sync complete. Next: run 'npx cap sync' to push www/ into the Android assets folder." -ForegroundColor Cyan
