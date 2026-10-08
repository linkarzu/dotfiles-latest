#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/misc/562-skhdKittyClaude.sh
# ~/github/dotfiles-latest/scripts/macos/mac/misc/562-skhdKittyClaude.sh

# Open Claude Code in a new kitty tab in whatever kitty session is focused.
# Toucan hold-O sends cmd+ctrl+alt+shift+z, skhd calls this script.
# Focuses kitty only if it isn't already the focused app, so pressing it while
# in kitty never jumps to a different kitty OS window.

set -euo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
kitty_bin="${KITTY_BIN:-/Applications/kitty.app/Contents/MacOS/kitty}"

focused_app="$(yabai -m query --windows --window 2>/dev/null | jq -r '.app // empty' || true)"
if [[ "$focused_app" != "kitty" ]]; then
  "$DOTFILES_DIR/scripts/macos/mac/misc/500-switchApp.sh" kitty
fi

# If kitty was just launched, its socket takes a moment to show up
sock=""
for _ in {1..25}; do
  sock="$("$DOTFILES_DIR/scripts/macos/mac/misc/549-kittyMainSocket.sh" 2>/dev/null || true)"
  [[ -n "$sock" ]] && break
  sleep 0.2
done
[[ -n "$sock" ]] || exit 1

# Same as cmd+t (new_tab_with_cwd), so claude starts in the current directory.
# launch prints the new window id, send the keys to exactly that window.
win_id="$("$kitty_bin" @ --to "unix:${sock}" launch --type=tab --cwd=current)"
"$kitty_bin" @ --to "unix:${sock}" send-text --match "id:${win_id}" 'c\r'
