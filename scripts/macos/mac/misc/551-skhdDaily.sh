#!/usr/bin/env bash

# ~/github/dotfiles-latest/scripts/macos/mac/misc/551-skhdDaily.sh
# Trigger the daily note creation inside the current Kitty instance

set -euo pipefail
sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" action launch env DAILY_NOTE_MODE=personal "$HOME/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh"
