#!/usr/bin/env bash

set -euo pipefail

sock="$($HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" \
  action launch --type=background kitten quick-access-terminal --config "$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf" --instance-group colorscheme-selector /bin/bash -c "$HOME/github/dotfiles-latest/colorscheme/colorscheme-selector.sh"
