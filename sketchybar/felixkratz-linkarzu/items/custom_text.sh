#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/custom_text.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/custom_text.sh

custom_text=(
  updates=on
  update_freq=300
  icon.drawing=on
  icon.font="$FONT:Regular:8.0"
  icon.y_offset=5
  icon.padding_left=0
  icon.padding_right=0
  label.drawing=on
  padding_right=3
  label.font="$FONT:Bold:12.0"
  label.y_offset=-6
  label.padding_left=0
  label.padding_right=0
  script="$PLUGIN_DIR/custom_text.sh"
)

sketchybar --add event custom_text_update \
  --add item custom_text right \
  --set custom_text "${custom_text[@]}" \
  --subscribe custom_text custom_text_update
