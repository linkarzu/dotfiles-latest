#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/yabai/positions/yabai-custom-pad.sh
# ~/github/dotfiles-latest/yabai/positions/yabai-custom-pad.sh

padding="$1"
target_file="$HOME/github/dotfiles-latest/yabai/yabairc"

sed -E -i '' '/lineid_asus_monitor_bottom_pad/{n;s/([[:space:]]*yabai -m config bottom_padding )[0-9]+/\1'"$padding"'/;}' "$target_file"
