#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/claude_usage.sh
# Claude plan usage in a frame like the keyboard one: "claude" on top, then the
# 5 hour session and the week below it, each with the used percentage on the
# left and the time left until it resets on the right, like 2h58m or 1d17h.

# Right click for the popup with every limit and when it resets. Any click fetches
# the usage again.
CLAUDE_USAGE_CLICK_SCRIPT="$PLUGIN_DIR/usage_click.sh claude_usage.frame; sketchybar --trigger claude_usage_update"

# Wider than the keyboard frame's padding: that one sits next to a graph, whose
# right padding doesn't count, this one next to the keyboard's overlays, so it
# takes the same 5pt gap between the frames.
claude_usage_frame_padding_right=9
claude_usage_width=51
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
  popup.align=center
  popup.height=20
  click_script="$CLAUDE_USAGE_CLICK_SCRIPT"
  script="$PLUGIN_DIR/claude_usage.sh"
)

claude_usage_overlay=(
  label.font="$claude_usage_font"
  label="--"
  label.width=$claude_usage_width
  label.padding_left=0
  label.padding_right=0
  padding_right=$claude_usage_overlay_padding
  width=0
  icon.drawing=off
  click_script="$CLAUDE_USAGE_CLICK_SCRIPT"
)

claude_usage_title=(
  "${claude_usage_overlay[@]}"
  label="claude"
  label.y_offset=9
  label.align=center
)

# Percentages on the left.
claude_usage_used=(
  "${claude_usage_overlay[@]}"
  label.align=left
  label.padding_left=3
)

# Time left on the right.
claude_usage_left=(
  "${claude_usage_overlay[@]}"
  label.align=right
  label.padding_right=3
)

sketchybar --add event claude_usage_update \
  --add item claude_usage.frame right \
  --set claude_usage.frame "${claude_usage_frame[@]}" \
  --subscribe claude_usage.frame system_woke claude_usage_update \
  \
  --add item claude_usage.title right \
  --set claude_usage.title "${claude_usage_title[@]}" \
  \
  --add item claude_usage.session right \
  --set claude_usage.session "${claude_usage_used[@]}" label.y_offset=0 \
  \
  --add item claude_usage.session_left right \
  --set claude_usage.session_left "${claude_usage_left[@]}" label.y_offset=0 \
  \
  --add item claude_usage.week right \
  --set claude_usage.week "${claude_usage_used[@]}" label.y_offset=-9 \
  \
  --add item claude_usage.week_left right \
  --set claude_usage.week_left "${claude_usage_left[@]}" label.y_offset=-9 \
  padding_left=1

# The plugin fills the popup from this template, a row per limit, then Updated
# and Refresh. It builds every row again when a limit shows up or goes away,
# because sketchybar can't move a new row above existing ones in a popup.
claude_usage_popup_template=(
  drawing=off
  icon.font="$FONT:Bold:12"
  icon.width=140
  icon.padding_left=10
  icon.color=$WHITE
  label.font="$FONT:Semibold:12"
  label.width=200
  label.align=right
  label.padding_right=10
  label.color=$WHITE
  click_script="sketchybar --set claude_usage.frame popup.drawing=off"
)

sketchybar --add item claude_usage.popup.template left \
  --set claude_usage.popup.template "${claude_usage_popup_template[@]}"
