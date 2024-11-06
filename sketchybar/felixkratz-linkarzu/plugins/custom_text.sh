#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/custom_text.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/custom_text.sh

source "$CONFIG_DIR/colors.sh"

youtube_banner="$HOME/github/dotfiles-latest/youtube-banner.txt"

if [ -f "$youtube_banner" ]; then
  sketchybar -m --set custom_text label="Linkarzu" icon="" icon.color=$BLUE label.color=$BLUE icon.drawing=on
else
  sketchybar -m --set custom_text label="" icon.drawing=off
fi
