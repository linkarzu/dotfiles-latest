#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/claude_usage.sh
# Claude plan usage in a frame like the keyboard one: the 5 hour session on the
# top row, the week on the bottom one, each with the used percentage and the
# hours:minutes left until it resets. Left click fetches it again.

claude_usage_frame_padding_right=4
claude_usage_width=62
claude_usage_overlay_padding=$((-claude_usage_width + claude_usage_frame_padding_right))
claude_usage_font="$FONT:Bold:8"

claude_usage_frame=(
  width=$claude_usage_width
  padding_right=$claude_usage_frame_padding_right
  updates=on
  update_freq=60
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  background.border_width=1
  background.border_color=$USAGE_GRAPH_BORDER_COLOR
  background.corner_radius=0
  script="$PLUGIN_DIR/claude_usage.sh"
)

claude_usage_row=(
  label.font="$claude_usage_font"
  label="--"
  label.width=$claude_usage_width
  label.align=center
  label.padding_left=0
  label.padding_right=0
  padding_right=$claude_usage_overlay_padding
  width=0
  icon.drawing=off
  click_script="SENDER=mouse.clicked NAME=claude_usage.frame $PLUGIN_DIR/claude_usage.sh"
)

sketchybar --add item claude_usage.frame right \
  --set claude_usage.frame "${claude_usage_frame[@]}" \
  --subscribe claude_usage.frame system_woke mouse.clicked \
  \
  --add item claude_usage.session right \
  --set claude_usage.session "${claude_usage_row[@]}" label.y_offset=5 \
  \
  --add item claude_usage.week right \
  --set claude_usage.week "${claude_usage_row[@]}" label.y_offset=-6
