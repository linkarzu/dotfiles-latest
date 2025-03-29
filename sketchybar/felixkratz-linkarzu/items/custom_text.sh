#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/custom_text.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/custom_text.sh

custom_text=(
  updates=on
  update_freq=10
  label.drawing=on
  padding_right=3
  label.font="$FONT:Bold:14.0"
  # label.padding_left=3
  script="$PLUGIN_DIR/custom_text.sh"
)

sketchybar --add item custom_text right \
  --set custom_text "${custom_text[@]}"
