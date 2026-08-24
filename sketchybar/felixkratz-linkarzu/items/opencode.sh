#!/bin/bash

opencode_item=(
  updates=on
  update_freq=0
  icon="󰚩"
  icon.font="$FONT:Bold:15.0"
  icon.color=$GREY
  label="0"
  label.padding_left=2
  label.padding_right=7
  label.y_offset=-2
  popup.align=right
  popup.height=24
  script="$PLUGIN_DIR/opencode.sh"
)

opencode_template=(
  drawing=off
  width=248
  icon.width=24
  icon.align=center
  label.max_chars=43
  label.padding_right=8
  scroll_texts=off
  background.drawing=off
  background.height=24
  background.border_width=0
  background.corner_radius=0
  background.padding_left=0
  background.padding_right=0
  padding_left=0
  padding_right=0
)

sketchybar --add event opencode_update \
  --add item opencode right \
  --set opencode "${opencode_item[@]}" \
  --subscribe opencode opencode_update \
  system_woke \
  mouse.clicked \
  \
  --add item opencode.template left \
  --set opencode.template "${opencode_template[@]}"
