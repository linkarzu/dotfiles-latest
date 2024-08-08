#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/custom_text.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/custom_text.sh

custom_text=(
  updates=on
  update_freq=3
  label.drawing=on
  padding_right=15
  label.font="$FONT:Bold:17.0"
  # label.padding_left=3
  script="$PLUGIN_DIR/custom_text.sh"
)

sketchybar --add item custom_text right \
  --set custom_text "${custom_text[@]}"
