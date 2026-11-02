#!/usr/bin/env bash
# iOS ve macOS platform klasorlerini uretir ve gerekli ayarlari yapar (macOS uzerinde calisir).
set -euo pipefail

flutter create --project-name iptv_pro --org com.iptvpro --platforms=ios,macos .
rm -rf test

PB=/usr/libexec/PlistBuddy
add_or_set() { # dosya anahtar tip deger
  "$PB" -c "Set :$2 $4" "$1" 2>/dev/null || "$PB" -c "Add :$2 $3 $4" "$1"
}

# --- iOS: http (sifrelenmemis) yayinlara izin, ad, yatay/dikey
IP=ios/Runner/Info.plist
"$PB" -c "Add :NSAppTransportSecurity dict" "$IP" 2>/dev/null || true
add_or_set "$IP" "NSAppTransportSecurity:NSAllowsArbitraryLoads" bool true
add_or_set "$IP" "CFBundleDisplayName" string "SF IPTV Player"

# --- macOS: ag erisimi (App Sandbox) ve http izni
for f in macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements; do
  add_or_set "$f" "com.apple.security.network.client" bool true
done
MP=macos/Runner/Info.plist
"$PB" -c "Add :NSAppTransportSecurity dict" "$MP" 2>/dev/null || true
add_or_set "$MP" "NSAppTransportSecurity:NSAllowsArbitraryLoads" bool true

# --- Asgari surumler (libmpv icin iOS 13 / macOS 10.15)
python3 - <<'PY'
import re, pathlib
def patch(path, subs):
    p = pathlib.Path(path)
    if not p.exists():
        return
    s = p.read_text(encoding="utf-8")
    for pat, rep in subs:
        s = re.sub(pat, rep, s)
    p.write_text(s, encoding="utf-8")

patch("ios/Podfile", [(r"^#?\s*platform :ios, '[0-9.]+'", "platform :ios, '13.0'")])
patch("ios/Runner.xcodeproj/project.pbxproj",
      [(r"IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;", "IPHONEOS_DEPLOYMENT_TARGET = 13.0;")])
patch("macos/Podfile", [(r"^#?\s*platform :osx, '[0-9.]+'", "platform :osx, '10.15'")])
patch("macos/Runner.xcodeproj/project.pbxproj",
      [(r"MACOSX_DEPLOYMENT_TARGET = [0-9.]+;", "MACOSX_DEPLOYMENT_TARGET = 10.15;")])
PY
flutter pub get && dart run flutter_launcher_icons -f tool/icons_apple.yaml || echo "Uygulama ikonu uretilemedi (varsayilan kalacak)"
echo "Apple platform ayarlari tamam."
