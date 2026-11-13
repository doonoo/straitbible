#!/bin/sh
# Makes "Strait Bible.app" and a .dmg from the program built by packaging/build-macos.sh.
#
# The application is only signed ad hoc (no Apple developer account), so macOS asks for a confirmation the first
# time: right-click the app -> Open, or run   xattr -cr "/Applications/Strait Bible.app"
set -e

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION=$(sed -n "s/.*ApplicationVersion = '\(.*\)';/\1/p" "$ROOT/unitutils.pas")
ARCH=$(uname -m)
APP="$ROOT/dist/Strait Bible.app"

rm -rf "$ROOT/dist"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$ROOT/straitbible_darwin" "$APP/Contents/MacOS/straitbible"
chmod +x "$APP/Contents/MacOS/straitbible"
sed "s/@VERSION@/$VERSION/g" "$ROOT/packaging/macos/Info.plist" > "$APP/Contents/Info.plist"
cp "$ROOT/straitbible.icns" "$APP/Contents/Resources/straitbible.icns"

# what the program reads from next to itself (see SharePath in unitlib.pas)
mkdir -p "$APP/Contents/Resources/modules" "$APP/Contents/Resources/localization"
cp "$ROOT"/modules/*.zip "$APP/Contents/Resources/modules/"
cp "$ROOT"/localization/*.lng "$APP/Contents/Resources/localization/"

codesign --force --deep --sign - "$APP"

STAGE="$ROOT/dist/dmg"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Strait Bible $VERSION" -srcfolder "$STAGE" -ov -format UDZO \
  "$ROOT/dist/straitbible-$VERSION-macos-$ARCH.dmg"
rm -rf "$STAGE"
ls -la "$ROOT/dist"
