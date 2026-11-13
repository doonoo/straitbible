#!/bin/sh
# Builds Strait Bible on macOS with Lazarus (lazbuild, Cocoa) and Free Pascal.
#
#   packaging/build-macos.sh [path-to-zeoslib]
#
# ZeosLib 7.2.x is needed, see build-linux.sh. Set LAZARUS_DIR when Lazarus is not in the default place.
# The result is ./straitbible_darwin; packaging/macos/make-app.sh makes the application from it.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ZEOS="${1:-$ROOT/components/zeosdb}"
PCP="${LAZARUS_PCP:-$ROOT/.lazarus-config}"
LAZ=""
if [ -n "$LAZARUS_DIR" ]; then LAZ="--lazarusdir=$LAZARUS_DIR"; fi

if [ ! -f "$ZEOS/packages/lazarus/zcomponent.lpk" ]; then
  echo "ZeosLib not found in $ZEOS" >&2
  exit 1
fi

cd "$ROOT"
mkdir -p "$PCP"

LAZDIR="${LAZARUS_DIR:-/Applications/Lazarus}"

# the Cocoa part of the LCL is not compiled in a fresh Lazarus: build it first
make -C "$LAZDIR/lcl" LCL_PLATFORM=cocoa PP=fpc > "$ROOT/lcl-make.log" 2>&1 || { tail -40 "$ROOT/lcl-make.log"; exit 1; }
tail -5 "$ROOT/lcl-make.log"
echo "--- interfaces folder:"
ls "$LAZDIR/lcl/interfaces" | head -40
make -C "$LAZDIR/lcl/interfaces" LCL_PLATFORM=cocoa PP=fpc > "$ROOT/lcl-if.log" 2>&1 || { tail -40 "$ROOT/lcl-if.log"; exit 1; }
tail -5 "$ROOT/lcl-if.log"
echo "--- where are the Cocoa units?"
find "$LAZDIR" -iname 'cocoawscommon*' | head
ls "$LAZDIR/lcl/units/aarch64-darwin/cocoa" | head -20

for lpk in \
    "$ZEOS/packages/lazarus/zcomponent.lpk" \
    components/richmemo/richmemopackage.lpk \
    components/unboundmemo/unboundmemopackage.lpk; do
  lazbuild $LAZ --pcp="$PCP" --ws=cocoa --add-package-link "$lpk"
  lazbuild $LAZ --pcp="$PCP" --ws=cocoa "$lpk"
done

lazbuild $LAZ --pcp="$PCP" --ws=cocoa straitbible.lpi
ls -la "$ROOT"/straitbible_darwin
