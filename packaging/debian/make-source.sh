#!/bin/sh
# Builds the source package for a Launchpad PPA (unsigned), for the series given as argument.
#
#   packaging/debian/make-source.sh jammy [directory-for-the-result]
#
# Needs devscripts/dpkg-dev and git. ZeosLib is not in Ubuntu, so it is put into the source package.
set -e

SERIES="${1:?series, for example jammy or noble}"
OUT="${2:-$PWD/ppa-out}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION=$(sed -n "s/.*ApplicationVersion = '\(.*\)';/\1/p" "$ROOT/unitutils.pas")
PKGVER="${VERSION}ppa1~${SERIES}1"

WORK="$(mktemp -d)"
mkdir -p "$OUT"
cp -a "$ROOT" "$WORK/straitbible-$VERSION"
cd "$WORK/straitbible-$VERSION"
rm -rf .git .github ppa-out

# ZeosLib 7.2 (Free Pascal 3.2 can not use the 8.0 branch)
git clone -q --depth 1 --branch 7.2.14-stable https://github.com/marsupilami79/zeoslib.git components/zeosdb
rm -rf components/zeosdb/.git

# changelog for this series
cat > debian/changelog <<EOF
straitbible ($PKGVER) $SERIES; urgency=medium

  * Package for the Strait Bible PPA (see CHANGELOG.md for the changes).

 -- Strait Bible contributors <noreply@users.noreply.github.com>  $(date -R)
EOF

dpkg-buildpackage -S -sa -d -us -uc
cp -v "$WORK"/straitbible_"$PKGVER"* "$OUT"/
