#!/bin/bash
# Install the Wallpaper Intros PATH wrapper and link the intro generator.
# Never overwrites a different user script, and never touches theme files,
# clips, or shell.json.
set -euo pipefail

PLUGIN_ID="io.github.fluxcapacitated.wallpaper-intros"
MARKER="# omarchy-plugin: ${PLUGIN_ID}"
HERE="$(cd "$(dirname "$0")" && pwd)"
WRAP_SRC="$HERE/omarchy-theme-bg-set"
WRAP_DEST="$HOME/.local/bin/omarchy-theme-bg-set"
GEN_SRC="$HERE/omarchy-intro-make"
GEN_DEST="$HOME/.local/bin/omarchy-intro-make"

if [[ ! -f $WRAP_SRC ]]; then
  echo "Missing wrapper source: $WRAP_SRC" >&2
  exit 1
fi
if [[ ! -f $GEN_SRC ]]; then
  echo "Missing generator source: $GEN_SRC" >&2
  exit 1
fi

mkdir -p "$HOME/.local/bin"
status=0

if [[ -e $WRAP_DEST || -L $WRAP_DEST ]]; then
  if grep -qF "$MARKER" "$WRAP_DEST" 2>/dev/null; then
    cp -f "$WRAP_SRC" "$WRAP_DEST"
    chmod +x "$WRAP_DEST"
    echo "Updated the Wallpaper Intros wrapper at $WRAP_DEST"
  else
    echo "Refusing to overwrite $WRAP_DEST because it is not this plugin's wrapper."
    echo "Compare it with $WRAP_SRC, back it up if you want to keep it, then replace it and rerun this installer."
    echo "The intro generator can still be installed independently."
    status=1
  fi
else
  cp "$WRAP_SRC" "$WRAP_DEST"
  chmod +x "$WRAP_DEST"
  echo "Installed the Wallpaper Intros wrapper at $WRAP_DEST"
fi

if [[ -e $GEN_DEST || -L $GEN_DEST ]]; then
  if [[ -L $GEN_DEST && $(readlink -f "$GEN_DEST") == $(readlink -f "$GEN_SRC") ]]; then
    echo "Generator already linked at $GEN_DEST"
  elif grep -qF "$MARKER" "$GEN_DEST" 2>/dev/null; then
    cp -f "$GEN_SRC" "$GEN_DEST"
    chmod +x "$GEN_DEST"
    echo "Updated the intro generator at $GEN_DEST"
  else
    echo "Refusing to overwrite $GEN_DEST because that path is already taken."
    echo "The plugin generator remains at $GEN_SRC"
    status=1
  fi
else
  ln -s "$GEN_SRC" "$GEN_DEST"
  echo "Linked the intro generator to $GEN_DEST"
fi

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *)
    echo "Note: $HOME/.local/bin is not on PATH in this shell."
    echo "Omarchy sessions normally include it. If wallpaper intros do not play, add that directory to PATH and log in again."
    ;;
esac

echo "Clips, themes, and other config were left unchanged."
echo "Enable or disable intros anytime with: omarchy theme bg intro toggle"
echo "Build a clip with: omarchy-intro-make /path/to/wallpaper.webp --style fade"
exit $status
