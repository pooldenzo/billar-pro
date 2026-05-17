# Billar Pro — Mobile Setup (Windows)

## Prerequisites

Install these before anything else:

| Tool | Download |
|------|----------|
| Node.js 20+ | https://nodejs.org |
| Android Studio | https://developer.android.com/studio |
| JDK 17 | bundled with Android Studio |
| Git | https://git-scm.com |

After Android Studio installs, open **SDK Manager** and install:
- Android SDK Platform 34
- Android SDK Build-Tools 34
- Android Emulator

Set environment variables (add to your PowerShell profile or System env):
```powershell
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools"
```

---

## First-time Setup

Open PowerShell in the project root and run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```

This will:
1. Install npm packages
2. Copy `billar.html` → `www/index.html`
3. Add Android platform (`android/` folder)
4. Add iOS platform (`ios/` folder — structure only, no macOS needed)
5. Run `cap sync`

---

## Every Time You Edit billar.html

```powershell
# Copy changes and sync to native projects
powershell -ExecutionPolicy Bypass -File scripts/copy-web.ps1
npx cap sync
```

Or just:
```powershell
npm run sync
```

---

## Android — Build & Run

### Open in Android Studio
```powershell
npm run open:android
```
Then press ▶ Run in Android Studio to install on emulator or device.

### Build Debug APK (command line)
```powershell
npm run build:debug
# Output: billar-pro-debug.apk (project root)
```

### Install on connected device via ADB
```powershell
adb devices                           # confirm device is listed
adb install billar-pro-debug.apk
```

### Build Release AAB (for Play Store)

**Step 1 — Create keystore (once only):**
```powershell
keytool -genkey -v `
  -keystore keystore.jks `
  -alias billar-pro `
  -keyalg RSA -keysize 2048 `
  -validity 10000
```
Keep `keystore.jks` safe — you cannot update the app without it.

**Step 2 — Set env vars and build:**
```powershell
$env:KEYSTORE_PATH     = "$PWD\keystore.jks"
$env:KEYSTORE_PASSWORD = "your_store_password"
$env:KEY_ALIAS         = "billar-pro"
$env:KEY_PASSWORD      = "your_key_password"

npm run build:release
# Output: billar-pro-release.aab (project root)
```

**Step 3 — Upload** `billar-pro-release.aab` to Google Play Console.

---

## Android — Gradle signing config (optional hardcoded)

Edit `android/app/build.gradle` and add inside `android { ... }`:

```gradle
signingConfigs {
    release {
        storeFile     file(System.getenv("KEYSTORE_PATH") ?: "keystore.jks")
        storePassword System.getenv("KEYSTORE_PASSWORD") ?: ""
        keyAlias      System.getenv("KEY_ALIAS")         ?: "billar-pro"
        keyPassword   System.getenv("KEY_PASSWORD")      ?: ""
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled false
    }
}
```

---

## iOS — From Windows

Capacitor generates the `ios/` folder on Windows but final compilation
**requires a Mac with Xcode**.

### What you do on Windows:
```powershell
npx cap add ios      # generates ios/ folder
npx cap sync ios     # copies web assets into it
```

### What to do on macOS:

1. Copy the entire project to macOS (or push to Git and clone).
2. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```
3. Install iOS dependencies:
   ```bash
   cd ios/App
   pod install
   ```
4. Open in Xcode:
   ```bash
   npx cap open ios
   # or: open ios/App/App.xcworkspace
   ```
5. In Xcode:
   - Set your **Team** (Apple Developer account)
   - Set **Bundle Identifier**: `com.billarpro.app`
   - Select target device or simulator → ▶ Run

### App Store Archive:
1. Xcode → Product → Archive
2. Xcode Organizer → Distribute App → App Store Connect
3. Upload, then submit in App Store Connect

---

## Project Structure

```
billar-pro/
├── www/                    ← Capacitor webDir (mobile-optimized HTML)
│   ├── index.html          ← billar.html + mobile meta/CSS/JS
│   ├── manifest.json       ← PWA manifest
│   └── icons/              ← app icons (add icon-192.png, icon-512.png)
├── android/                ← Android Studio project (generated)
├── ios/                    ← Xcode project (generated)
├── scripts/
│   ├── setup.ps1           ← first-time setup
│   ├── copy-web.ps1        ← copy billar.html → www/index.html
│   ├── build-debug.ps1     ← build debug APK
│   └── build-release.ps1   ← build signed AAB
├── billar.html             ← source of truth (edit this)
├── capacitor.config.json
├── package.json
└── MOBILE_SETUP.md
```

---

## App Icons

Place these files in `www/icons/`:
- `icon-192.png` — 192×192 px
- `icon-512.png` — 512×512 px

For Android adaptive icons, Capacitor copies them automatically from
`resources/` if you use `@capacitor/assets`:

```powershell
npm install -D @capacitor/assets
# Place a 1024x1024 icon.png in resources/
npx capacitor-assets generate
```

---

## Quick Reference

```powershell
# Edit billar.html, then:
npm run sync                  # copy + sync to Android/iOS

# Run on Android
npm run open:android          # Android Studio
npm run build:debug           # CLI APK

# Run on iOS (macOS only)
npm run open:ios              # Xcode

# Full first-time setup
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```
