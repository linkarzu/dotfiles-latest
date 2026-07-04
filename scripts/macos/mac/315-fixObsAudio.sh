#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/github/dotfiles-private/scripts/macos/mac/obs/set-audio-application/py/set-audio-application.py"
SCENE="youtube-chat"
SOURCE="3-brave-audio"

python3 "$SCRIPT" "$SCENE" "$SOURCE" "OBS Studio"

sleep 1

python3 "$SCRIPT" "$SCENE" "$SOURCE" "Brave Browser" --restart-capture
