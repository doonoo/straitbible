#!/bin/sh
# Installs a built Strait Bible (see build-linux.sh) into a directory tree.
#
#   packaging/install-linux.sh [DESTDIR] [PREFIX]
#
# DESTDIR is for packages (for example $pkgdir), PREFIX defaults to /usr.
# The program looks for its modules and translations in /usr/share/straitbible when it runs from /usr.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DESTDIR="${1:-}"
PREFIX="${2:-/usr}"
SHARE="$DESTDIR$PREFIX/share"

install -Dm755 "$ROOT/straitbible_linux" "$DESTDIR$PREFIX/bin/straitbible"

mkdir -p "$SHARE/straitbible/modules" "$SHARE/straitbible/localization" "$SHARE/straitbible/titles"
cp -r "$ROOT"/modules/*.zip "$SHARE/straitbible/modules/"
cp -r "$ROOT"/localization/*.lng "$SHARE/straitbible/localization/"
cp -r "$ROOT"/titles/. "$SHARE/straitbible/titles/"

install -Dm644 "$ROOT/packaging/straitbible.desktop" "$SHARE/applications/straitbible.desktop"
install -Dm644 "$ROOT/packaging/io.github.doonoo.StraitBible.metainfo.xml" \
  "$SHARE/metainfo/io.github.doonoo.StraitBible.metainfo.xml"
install -Dm644 "$ROOT/straitbible.svg" "$SHARE/icons/hicolor/scalable/apps/straitbible.svg"
install -Dm644 "$ROOT/straitbible.png" "$SHARE/icons/hicolor/256x256/apps/straitbible.png"
install -Dm644 "$ROOT/LICENSE" "$SHARE/licenses/straitbible/LICENSE"

echo "installed into $DESTDIR$PREFIX"
