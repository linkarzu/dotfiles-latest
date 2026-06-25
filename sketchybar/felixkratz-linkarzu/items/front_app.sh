#!/bin/bash

#Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/items/front_app.sh

front_app=(
  icon.padding_left=15
  icon.padding_right=0
  label.padding_left=0
  label.padding_right=10
  label.y_offset=-7
  # Using "JetBrainsMono Nerd Font"
  label.font="$FONT:Bold:14.0"
  # Using default "SF Pro"
  # label.font="$FONT:Black:13.0"
  icon.background.drawing=on
  display=active
  script="$PLUGIN_DIR/front_app.sh"
  click_script="open -a 'Mission Control'"
)

sketchybar --add event front_app_windows_changed \
  --add item front_app left \
  --set front_app "${front_app[@]}" \
  --subscribe front_app front_app_switched front_app_windows_changed
