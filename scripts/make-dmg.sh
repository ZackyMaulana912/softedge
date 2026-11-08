#!/bin/bash
# Builds a Release copy of RoundedCorners and packs it into a DMG in build/.
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="RoundedCorners"
BUILD_DIR="build"
APP="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"
STAGING="$BUILD_DIR/dmg-staging"

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

echo "Created $DMG ($(du -h "$DMG" | cut -f1))"
