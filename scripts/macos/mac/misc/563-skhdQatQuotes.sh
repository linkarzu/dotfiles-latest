#!/usr/bin/env bash

set -euo pipefail

# QAT -> Quotes directly: pick a live quote and it plays over the live scene in
# OBS. Toucan W+B sends shift+alt+cmd+F19 (skhdrc). The window closes once the
# quote is on screen; after an error it waits for enter so the message stays.

script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/563-skhdQatQuotes.sh"

if [[ "${1:-}" == "--pick" ]]; then
  "$HOME/github/dotfiles-latest/scripts/macos/mac/070-obsMeetingManager.sh" --quotes ||
    read -r -p "Press enter to close. "
  exit 0
fi

sock="$($HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" \
  action launch --type=background kitten quick-access-terminal --config "$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf" --instance-group live-quotes /bin/bash "$script" --pick
