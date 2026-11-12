#!/bin/bash

# Logo above the count in one column. The logo has no width of its own, so the item is only as wide
# as the column, and it's left aligned because centering a zero width icon clips it.
opencode_width=18
opencode_logo_indent=1

opencode_item=(
  updates=on
  update_freq=0
  padding_right=9
  icon="󰚩"
  icon.font="$FONT:Bold:15.0"
  icon.color=$GREY
  icon.width=0
  icon.align=left
  icon.padding_left=$opencode_logo_indent
  icon.padding_right=0
  icon.y_offset=6
  label="0"
  label.font="$FONT:Black:9.0"
  label.width=$opencode_width
  label.align=center
  label.padding_left=-$opencode_logo_indent
  label.padding_right=0
  label.y_offset=-8
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
