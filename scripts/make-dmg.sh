#!/bin/bash
# Builds a Release copy of RoundedCorners and packs it into a DMG in build/.
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="RoundedCorners"
BUILD_DIR="build"
APP="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"
STAGING="$BUILD_DIR/dmg-staging"

for tool in xcodegen xcodebuild; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Error: $tool tidak ditemukan." >&2
        case "$tool" in
            xcodegen) echo "Pasang dulu dengan: brew install xcodegen" >&2 ;;
            xcodebuild) echo "Pasang Xcode dari App Store, lalu jalankan: sudo xcode-select -s /Applications/Xcode.app" >&2 ;;
        esac
        exit 1
    fi
done

xcodegen generate
xcodebuild -quiet -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" \
    -configuration Release -destination 'generic/platform=macOS' \
    -derivedDataPath "$BUILD_DIR" clean build

codesign --verify --strict "$APP"

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Contents/Info.plist")
DMG="$BUILD_DIR/$APP_NAME-$VERSION.dmg"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
ditto "$APP" "$STAGING/$APP_NAME.app"
ln -s /Applications "$STAGING/Applications"

hdiutil create -quiet -volname "$APP_NAME" -srcfolder "$STAGING" -format ULMO "$DMG"
rm -rf "$STAGING"
hdiutil verify -quiet "$DMG"

# Run from build/ so the .sha256 file names the DMG without a folder,
# then `shasum -c` works next to the downloaded file.
(cd "$BUILD_DIR" && shasum -a 256 "$(basename "$DMG")" > "$(basename "$DMG").sha256")

echo "Created $DMG ($(du -h "$DMG" | cut -f1))"
echo "SHA-256: $(cut -d' ' -f1 "$DMG.sha256")"
