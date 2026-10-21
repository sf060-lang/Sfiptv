#!/usr/bin/env bash
# Android ve Windows platform klasorlerini uretir ve gerekli ayarlari yapar.
# Kullanim (proje klasorunde):  bash tool/setup_platforms.sh
set -euo pipefail

flutter create --project-name iptv_pro --org com.iptvpro --platforms=android,windows .
rm -rf test   # sablon test dosyasi bu uygulamaya uymuyor

M=android/app/src/main/AndroidManifest.xml

# Internet izni + http (sifrelenmemis) yayinlara izin + uygulama adi
if ! grep -q 'android.permission.INTERNET' "$M"; then
  sed -i 's|<application|<uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.WAKE_LOCK"/>\n    <application android:usesCleartextTraffic="true"|' "$M"
fi
sed -i 's|android:label="[^"]*"|android:label="SF İPTV Player"|' "$M"

# ---- Google TV / Android TV / Android box destegi ----
# 1) TV ana ekraninda gorunsun (LEANBACK_LAUNCHER)
if ! grep -q 'LEANBACK_LAUNCHER' "$M"; then
  sed -i 's|\(<category android:name="android.intent.category.LAUNCHER"/>\)|\1\n                <category android:name="android.intent.category.LEANBACK_LAUNCHER"/>|' "$M"
fi
# 2) Dokunmatik ekran sart degil (TV kutularinda yok)
if ! grep -q 'android.software.leanback' "$M"; then
  sed -i 's|<application|<uses-feature android:name="android.software.leanback" android:required="false"/>\n    <uses-feature android:name="android.hardware.touchscreen" android:required="false"/>\n    <uses-feature android:name="android.hardware.faketouch" android:required="false"/>\n    <application|' "$M"
fi
# 2b) Impeller'i kapat (bazi TV ekran kartlarinda beyaz ekran yapiyor), eski Skia kullan
if ! grep -q 'EnableImpeller' "$M"; then
  sed -i 's|</application>|    <meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false"/>\n    </application>|' "$M"
fi
# 3) TV ana ekrani afisi (banner)
mkdir -p android/app/src/main/res/drawable-xhdpi
cp tool/tv_banner.png android/app/src/main/res/drawable-xhdpi/tv_banner.png
if ! grep -q 'android:banner' "$M"; then
  sed -i 's|<application|<application android:banner="@drawable/tv_banner"|' "$M"
fi
echo "---- AndroidManifest.xml ----"
cat "$M"
echo "-----------------------------"

# Windows pencere basligi
sed -i 's/L"iptv_pro"/L"SF IPTV Player"/' windows/runner/main.cpp

echo "Platform ayarlari tamam."
