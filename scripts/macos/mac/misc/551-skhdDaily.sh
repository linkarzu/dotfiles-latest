#!/usr/bin/env bash

# Trigger the daily note creation inside the current Kitty instance

set -euo pipefail
sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" action launch /bin/zsh -c "$HOME/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh"
