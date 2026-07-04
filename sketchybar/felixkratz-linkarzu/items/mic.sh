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
  label.y_offset=4
  icon.y_offset=0
  script="$PLUGIN_DIR/mic.sh"
  click_script="$PLUGIN_DIR/mic_click.sh"
)

mic_output=(
  updates=off
  width=0
  icon.drawing=off
  label.drawing=on
  label.font="$FONT:Regular:8.0"
  label.align=left
  label.y_offset=-8
  # If you wanna modify the left and right padding of the output device, modify
  # OUTPUT_PADDING_LEFT in ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
  label.padding_left=0
  label.padding_right=0
  padding_left=-40
  padding_right=0
  click_script="$PLUGIN_DIR/mic_click.sh"
)

sketchybar --add item mic left \
  --set mic "${mic[@]}" \
  \
  --add item mic.output left \
  --set mic.output "${mic_output[@]}" \
  --subscribe mic volume_change
