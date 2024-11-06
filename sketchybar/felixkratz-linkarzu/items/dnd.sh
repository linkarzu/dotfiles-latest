#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/dnd.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/dnd.sh

dnd=(
  updates=on
  label.font="$FONT:Regular:8.0"
  update_freq=10
  padding_right=2
  padding_left=4
  label.padding_left=0
  label.drawing=on
  script="$PLUGIN_DIR/dnd.sh"
)

# Add the DND item to the right side of the bar and set its properties
sketchybar --add item dnd right \
  --set dnd "${dnd[@]}"
