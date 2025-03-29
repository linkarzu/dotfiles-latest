#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/custom_text.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/custom_text.sh

source "$CONFIG_DIR/colors.sh"

# File created by ~/github/scripts-public/macos/mac/305-bannerOn.sh
youtube_banner="$HOME/github/dotfiles-latest/youtube-banner.txt"

if [ -f "$youtube_banner" ]; then
  banner_text=$(<"$youtube_banner")

  # Choose color based on label value
  if [[ "$banner_text" == "main-screen" ]]; then
    color=$BLUE
  else
    color=$RED
  fi

  sketchybar -m --set custom_text label="$banner_text" icon="" icon.color=$color label.color=$color icon.drawing=on
else
  sketchybar -m --set custom_text label="" icon.drawing=off
fi
