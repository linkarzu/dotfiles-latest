#!/usr/bin/env bash

set -euo pipefail

sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" \
  action launch --type=background kitten quick-access-terminal \
  --config "$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf" \
  --instance-group system-task /bin/bash -c "$HOME/github/dotfiles-latest/scripts/macos/mac/misc/240-systemTask.sh"
