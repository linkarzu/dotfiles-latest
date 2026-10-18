#!/usr/bin/env bash

set -e

python3 \
  "$HOME/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager/scripts/macos/mac/yt-members-overlay/member_overlay.py" \
  "$@"

# The menu closes when this exits, so show the fresh screenshots.
open "$HOME/Downloads/overlay-premium.png" "$HOME/Downloads/overlay-members.png"
