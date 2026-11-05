#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/forager_battery.sh
# Battery level of the left and right Forager halves, left of the disk graph.
# ZMK updates the levels slowly and reading them is cheap for the keyboard.

# Shift zero-width labels back over the frame. Less than the graphs' overlay: a
# plain item's right padding already counts, a graph's doesn't.
forager_frame_padding_right=4
# Wider than the graphs so the "forager" title fits.
forager_width=34
forager_overlay_padding=$((-forager_width + forager_frame_padding_right))
forager_title_font="$FONT:Heavy:7"
forager_level_font="$FONT:Heavy:8"

forager_frame=(
  width=$forager_width
  padding_right=$forager_frame_padding_right
  drawing=off
  updates=on
  update_freq=300
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  background.border_width=1
  background.border_color=$USAGE_GRAPH_BORDER_COLOR
  background.corner_radius=0
  script="$PLUGIN_DIR/forager_battery.sh"
)

forager_title=(
  drawing=off
  label.font="$forager_title_font"
  label="forager"
  label.y_offset=9
  label.width=$forager_width
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$forager_overlay_padding
  width=0
  icon.drawing=off
)

forager_left=(
  drawing=off
  label.font="$forager_level_font"
  label="L --"
  label.y_offset=0
  label.width=$forager_width
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$forager_overlay_padding
  width=0
  icon.drawing=off
)

forager_right=(
  drawing=off
  label.font="$forager_level_font"
  label="R --"
  label.y_offset=-9
  label.width=$forager_width
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$forager_overlay_padding
  width=0
  icon.drawing=off
)

sketchybar --add item forager.frame right \
  --set forager.frame "${forager_frame[@]}" \
  --subscribe forager.frame system_woke \
  \
  --add item forager.title right \
  --set forager.title "${forager_title[@]}" \
  \
  --add item forager.left right \
  --set forager.left "${forager_left[@]}" \
  \
  --add item forager.right right \
  --set forager.right "${forager_right[@]}"
