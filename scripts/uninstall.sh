#!/bin/bash
# Remove only this plugin's PATH wrapper and generator link. Leaves intro
# clips, themes, and the stock Omarchy commands in place.
set -euo pipefail

PLUGIN_ID="io.github.fluxcapacitated.wallpaper-intros"
MARKER="# omarchy-plugin: ${PLUGIN_ID}"
HERE="$(cd "$(dirname "$0")" && pwd)"
WRAP_DEST="$HOME/.local/bin/omarchy-theme-bg-set"
GEN_DEST="$HOME/.local/bin/omarchy-intro-make"
GEN_SRC="$HERE/omarchy-intro-make"
status=0

if [[ ! -e $WRAP_DEST && ! -L $WRAP_DEST ]]; then
  echo "No wrapper at $WRAP_DEST; nothing to remove."
else
  if grep -qF "$MARKER" "$WRAP_DEST" 2>/dev/null; then
    rm -f "$WRAP_DEST"
    echo "Removed $WRAP_DEST"
    echo "Stock omarchy-theme-bg-set will be used again. Intro clips were not deleted."
  else
    echo "Refusing to remove $WRAP_DEST because it is not this plugin's wrapper." >&2
    status=1
  fi
fi

if [[ ! -e $GEN_DEST && ! -L $GEN_DEST ]]; then
  echo "No generator at $GEN_DEST; nothing to remove."
else
  if [[ -L $GEN_DEST && $(readlink -f "$GEN_DEST") == $(readlink -f "$GEN_SRC") ]]; then
    rm -f "$GEN_DEST"
    echo "Removed $GEN_DEST"
  elif grep -qF "$MARKER" "$GEN_DEST" 2>/dev/null; then
    rm -f "$GEN_DEST"
    echo "Removed $GEN_DEST"
  else
    echo "Refusing to remove $GEN_DEST because it is not this plugin's generator." >&2
    status=1
  fi
fi

exit $status
