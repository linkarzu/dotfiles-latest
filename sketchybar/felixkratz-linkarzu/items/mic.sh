#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/mic.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/mic.sh

mic=(
  updates=on
  update_freq=10
  label.drawing=on
  padding_right=4
  label.padding_right=2
  label.font="$FONT:Regular:12.0"
  script="$PLUGIN_DIR/mic.sh"
  click_script="$PLUGIN_DIR/mic_click.sh"
)

sketchybar --add item mic left \
  --set mic "${mic[@]}" \
  --subscribe mic volume_change
