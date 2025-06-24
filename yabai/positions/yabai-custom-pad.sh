#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/yabai/positions/yabai-custom-pad.sh
# ~/github/dotfiles-latest/yabai/positions/yabai-custom-pad.sh

top="$1" bottom="$2" left="$3" right="$4"
target_file="$HOME/github/dotfiles-latest/yabai/yabairc"

sed -E -i '' "/lineid_asus_monitor_top_pad/{n;s/([[:space:]]*yabai -m config top_padding )[0-9]+/\1${top}/;};/lineid_asus_monitor_bottom_pad/{n;s/([[:space:]]*yabai -m config bottom_padding )[0-9]+/\1${bottom}/;};/lineid_asus_monitor_left_pad/{n;s/([[:space:]]*yabai -m config left_padding )[0-9]+/\1${left}/;};/lineid_asus_monitor_right_pad/{n;s/([[:space:]]*yabai -m config right_padding )[0-9]+/\1${right}/;}" "$target_file"
