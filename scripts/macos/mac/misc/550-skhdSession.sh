#!/usr/bin/env bash

# Switch to a kitty session by name or path

set -euo pipefail
session="$1"

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
sock="$("$DOTFILES_DIR/scripts/macos/mac/misc/549-kittyMainSocket.sh")"
"${KITTY_BIN:-/Applications/kitty.app/Contents/MacOS/kitty}" @ --to "unix:${sock}" action goto_session "$session"
