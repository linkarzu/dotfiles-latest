#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/mikrotik.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/mikrotik.sh

mikrotik=(
  updates=on
  update_freq=30
  label.drawing=on
  padding_right=0
  label.padding_right=2
  label.y_offset=0
  label.font="$FONT:Regular:12.0"
  script="$PLUGIN_DIR/mikrotik.sh"
)

mikrotik_download=(
  updates=off
  icon.drawing=off
  label.drawing=on
  label.font="$FONT:Regular:8.0"
  label.align=left
  label.y_offset=3
  label.padding_left=0
  # If wanna modify the overall right pad, change SPEED_COLUMN_PADDING_RIGHT in
  # ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mikrotik.sh
  label.padding_right=0
  padding_left=2
  padding_right=0
)

mikrotik_upload=(
  updates=off
  width=0
  icon.drawing=off
  label.drawing=on
  label.font="$FONT:Regular:8.0"
  label.align=left
  label.y_offset=-7
  label.padding_left=0
  label.padding_right=0
  padding_left=0
  padding_right=0
)

sketchybar --add item mikrotik left \
  --set mikrotik "${mikrotik[@]}" \
  \
  --add item mikrotik.download left \
  --set mikrotik.download "${mikrotik_download[@]}" \
  \
  --add item mikrotik.upload left \
  --set mikrotik.upload "${mikrotik_upload[@]}"
