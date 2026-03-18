#!/bin/bash
set -e

# ─── Configurazione ────────────────────────────────────────────────
APP_NAME="StemSeparator"
DISPLAY_NAME="Stems Shortcut"
VERSION="1.0"
TEAM_ID="7HB6926XLK"
BUNDLE_ID="com.matteozampieri.stemseparator"

# Credenziali Apple per notarizzazione
# Genera una App-Specific Password su https://appleid.apple.com → Sicurezza
APPLE_ID="matteozampierimaz@gmail.com"
APP_PASSWORD="dwud-fitr-qwlx-dbci"
# ───────────────────────────────────────────────────────────────────

DMG_NAME="${DISPLAY_NAME// /_}_${VERSION}.dmg"
BUILD_DIR="$(pwd)/build"
APP_PATH="$BUILD_DIR/Release/$APP_NAME.app"
DMG_PATH="$(pwd)/dist/$DMG_NAME"

mkdir -p "$(pwd)/dist"

echo "▶︎ Generating Xcode project..."
xcodegen generate --quiet

echo "▶︎ Building Release (Developer ID)..."
xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  CONFIGURATION_BUILD_DIR="$BUILD_DIR/Release" \
  build

echo "▶︎ Verifying signature..."
codesign --verify --deep --strict "$APP_PATH"
codesign -dv --verbose=4 "$APP_PATH" 2>&1 | grep "Authority\|TeamIdentifier"

echo "▶︎ Creating DMG..."
STAGE="$BUILD_DIR/dmg_stage"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -R "$APP_PATH" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

TMP_DMG="$BUILD_DIR/tmp.dmg"
hdiutil create \
  -volname "$DISPLAY_NAME" \
  -srcfolder "$STAGE" \
  -ov -format UDRW \
  -fs HFS+ \
  "$TMP_DMG"

MOUNT_DIR=$(hdiutil attach "$TMP_DMG" -readwrite -noverify -noautoopen | grep "/Volumes/" | awk '{print $NF}')
sleep 1

osascript << EOF
tell application "Finder"
  tell disk "$DISPLAY_NAME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {200, 200, 680, 440}
    set icon size of icon view options of container window to 100
    set arrangement of icon view options of container window to not arranged
    set position of item "$APP_NAME.app" of container window to {140, 120}
    set position of item "Applications" of container window to {340, 120}
    close
    open
    update without registering applications
    delay 2
    close
  end tell
end tell
EOF

hdiutil detach "$MOUNT_DIR"

rm -f "$DMG_PATH"
hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH"
rm -f "$TMP_DMG"
rm -rf "$STAGE"

echo "▶︎ Signing DMG..."
codesign --sign "Developer ID Application" --timestamp "$DMG_PATH"

echo "▶︎ Submitting for notarization (può richiedere qualche minuto)..."
xcrun notarytool submit "$DMG_PATH" \
  --apple-id "$APPLE_ID" \
  --password "$APP_PASSWORD" \
  --team-id "$TEAM_ID" \
  --wait

echo "▶︎ Stapling notarization ticket..."
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

echo ""
echo "✅ Tutto fatto: dist/$DMG_NAME"
echo "   $(du -sh "$DMG_PATH" | cut -f1) — firmato, notarizzato e pronto per Gumroad"
