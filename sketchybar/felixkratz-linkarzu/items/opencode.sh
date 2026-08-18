#!/bin/bash

opencode_item=(
  updates=on
  update_freq=5
  icon="󰚩"
  icon.font="$FONT:Bold:15.0"
  icon.color=$GREY
  label="0"
  label.padding_left=2
  label.padding_right=7
  label.y_offset=-2
  popup.align=right
  script="$PLUGIN_DIR/opencode.sh"
)

opencode_template=(
  drawing=off
  icon.width=24
  icon.align=center
  label.max_chars=72
  label.padding_right=8
  background.corner_radius=7
  padding_left=4
  padding_right=4
)

sketchybar --add event opencode_update \
  --add item opencode right \
  --set opencode "${opencode_item[@]}" \
  --subscribe opencode opencode_update \
  system_woke \
  mouse.clicked \
  mouse.exited.global \
  \
  --add item opencode.template popup.opencode \
  --set opencode.template "${opencode_template[@]}"
