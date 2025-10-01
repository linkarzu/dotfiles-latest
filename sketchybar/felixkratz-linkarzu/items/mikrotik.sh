#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/mikrotik.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/mikrotik.sh

mikrotik=(
  updates=on
  update_freq=30
  label.drawing=on
  padding_right=4
  label.padding_right=2
  label.font="$FONT:Regular:12.0"
  script="$PLUGIN_DIR/mikrotik.sh"
)

sketchybar --add item mikrotik left \
  --set mikrotik "${mikrotik[@]}"
