#!/usr/bin/env bash

# ~/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh
# Trigger the work daily note creation inside the current Kitty instance

set -euo pipefail
recording_mode_marker="$HOME/.cache/obs-meeting-manager/recording-mode"

if [[ -e "$recording_mode_marker" ]]; then
  osascript -e 'display notification "Work daily note is disabled while recording" with title "Recording mode"'
  exit 1
fi

sock="$($HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" action launch env DAILY_NOTE_MODE=work "$HOME/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh"
