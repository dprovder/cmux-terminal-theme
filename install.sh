#!/usr/bin/env bash
# Install the cmux terminal theme into ~/.config.
# Backs up anything it would overwrite to <file>.bak-<timestamp>, then copies.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

install_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    cp "$dest" "$dest.bak-$STAMP"
    echo "  backed up  $dest -> $dest.bak-$STAMP"
  fi
  cp "$src" "$dest"
  echo "  installed  $dest"
}

echo "Installing cmux terminal theme..."
install_file "$SRC/cmux/cmux.json"                "$HOME/.config/cmux/cmux.json"
install_file "$SRC/cmux/sidebars/terminal.swift"  "$HOME/.config/cmux/sidebars/terminal.swift"
install_file "$SRC/ghostty/config"                "$HOME/.config/ghostty/config"

echo
echo "Done. Next:"
echo "  cmux reload-config"
echo "  cmux themes set --light \"TokyoNight Day\" --dark TokyoNight"
echo "  cmux sidebar select terminal   # activate the custom sidebar"
