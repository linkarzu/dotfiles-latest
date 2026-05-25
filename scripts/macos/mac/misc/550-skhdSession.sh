#!/usr/bin/env bash

# Switch to a kitty session by name or path

set -euo pipefail
session="$1"

sock="$($HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" action goto_session "$session"
