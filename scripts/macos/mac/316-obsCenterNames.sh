#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/github/dotfiles-private/scripts/macos/mac/obs/centre-to-screen/py/centre-to-screen.py"

python3 "$SCRIPT" name-guest1 guest1-text
python3 "$SCRIPT" name-guest2 guest2-text
python3 "$SCRIPT" name-guest3 guest3-text
python3 "$SCRIPT" name-guest4 guest4-text
