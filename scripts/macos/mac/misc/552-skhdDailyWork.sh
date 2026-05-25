#!/usr/bin/env bash

# ~/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh
# Trigger the work daily note creation inside the current Kitty instance

set -euo pipefail
sock="$($HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" action launch env DAILY_NOTE_MODE=work "$HOME/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh"
