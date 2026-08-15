#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/github/dotfiles-private/scripts/macos/mac/obs/centre-to-screen/py/centre-to-screen.py"
label_count="${1:-4}"

for index in $(seq 1 "$label_count"); do
  python3 "$SCRIPT" "name-guest$index" "guest$index-text"
done
