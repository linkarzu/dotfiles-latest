#!/bin/bash

# Shift zero-width labels back over the graph, including its right padding.
ram_overlay_padding=$((-USAGE_GRAPH_WIDTH - PADDINGS))

ram_top=(
  label.font="$FONT:Heavy:8"
  label="ram 0%"
  label.y_offset=5
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$ram_overlay_padding
  width=0
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
)

swap_percent=(
  label.font="$FONT:Heavy:8"
  label="swp 0G"
  label.y_offset=-5
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$ram_overlay_padding
  width=0
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  update_freq=4
  mach_helper="$HELPER"
)

ram_used=(
  width=0
  graph.color=$ORANGE
  label.drawing=off
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

swap_used=(
  graph.color=$GREEN
  label.drawing=off
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  # Draw the shared 0-100% frame once, above both graph layers.
  background.border_width=1
  background.border_color=$GREY
  background.corner_radius=0
)

# Change USAGE_GRAPH_WIDTH_PERCENT in sketchybarrc (100 = original 75-point width).
sketchybar --add graph ram.used right "$USAGE_GRAPH_WIDTH" \
  --set ram.used "${ram_used[@]}" \
  \
  --add graph swap.used right "$USAGE_GRAPH_WIDTH" \
  --set swap.used "${swap_used[@]}" \
  \
  --add item ram.top right \
  --set ram.top "${ram_top[@]}" \
  \
  --add item swap.percent right \
  --set swap.percent "${swap_percent[@]}"
