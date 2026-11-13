#!/bin/sh
# Builds Strait Bible on Linux with Lazarus (lazbuild) and Free Pascal.
#
#   packaging/build-linux.sh [path-to-zeoslib]
#
# ZeosLib 7.2.x is needed (the 8.0 branch needs a newer compiler than Free Pascal 3.2.2), for example
#   git clone --depth 1 --branch 7.2.14-stable https://github.com/marsupilami79/zeoslib.git
#
# This script has not been run on Linux by the author yet: if something does not work, please open an issue.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ZEOS="${1:-$ROOT/components/zeosdb}"
WS="${LCL_WIDGETSET:-gtk2}"
PCP="${LAZARUS_PCP:-$ROOT/.lazarus-config}"   # a private Lazarus configuration, so the build touches nothing in $HOME

if [ ! -f "$ZEOS/packages/lazarus/zcomponent.lpk" ]; then
  echo "ZeosLib not found in $ZEOS (see the comment at the top of this script)" >&2
  exit 1
fi

# the folder of Lazarus (where "lcl" is): LAZARUS_DIR, or the usual places
LAZ=""
if [ -n "$LAZARUS_DIR" ]; then
  LAZ="--lazarusdir=$LAZARUS_DIR"
else
  for d in /usr/lib/lazarus /usr/lib/lazarus/* /usr/share/lazarus /usr/share/lazarus/*; do
    if [ -d "$d/lcl" ]; then LAZ="--lazarusdir=$d"; break; fi
  done
fi

cd "$ROOT"
mkdir -p "$PCP"

for lpk in \
    "$ZEOS/packages/lazarus/zcomponent.lpk" \
    components/richmemo/richmemopackage.lpk \
    components/unboundmemo/unboundmemopackage.lpk; do
  lazbuild $LAZ --pcp="$PCP" --ws="$WS" --add-package-link "$lpk"
  lazbuild $LAZ --pcp="$PCP" --ws="$WS" "$lpk"
done

lazbuild $LAZ --pcp="$PCP" --ws="$WS" straitbible.lpi
echo "built: $ROOT/straitbible_linux"
