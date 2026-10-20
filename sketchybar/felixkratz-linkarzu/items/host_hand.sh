#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/host_hand.sh
# Raise or lower my hand in a show with guests (guest show or Open Terminal), left of opencode.
# Hidden unless such a show is prepared or live; click toggles, like Enter-O-H.

host_hand=(
  updates=on
  update_freq=2
  drawing=off
  icon=$''
  icon.font="$FONT:Bold:15.0"
  icon.color=$GREY
  label.drawing=off
  icon.padding_right=6
  script="$PLUGIN_DIR/host_hand.sh"
)

sketchybar --add event host_hand_update \
  --add item host_hand right \
  --set host_hand "${host_hand[@]}" \
  --subscribe host_hand host_hand_update system_woke mouse.clicked
