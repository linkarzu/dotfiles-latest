#!/bin/bash

# Lower this to move the RAM widget closer to CPU; raise it to increase the gap.
ram_label_column_width=55

# Change this only to adjust the gap between the RAM graph and its labels.
ram_graph_label_padding=5

ram_top=(
  label.font="$FONT:Heavy:10"
  label="ram 0%"
  label.y_offset=5
  label.width=$ram_label_column_width
  label.align=left
  label.padding_left=$ram_graph_label_padding
  label.padding_right=0
  width=0
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
)

swap_percent=(
  label.font="$FONT:Heavy:10"
  label="swp 0G"
  label.y_offset=-5
  label.width=$ram_label_column_width
  label.align=left
  label.padding_left=$ram_graph_label_padding
  label.padding_right=0
  padding_right=1
  width=$ram_label_column_width
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
sketchybar --add item ram.top right \
  --set ram.top "${ram_top[@]}" \
  \
  --add item swap.percent right \
  --set swap.percent "${swap_percent[@]}" \
  \
  --add graph ram.used right "$USAGE_GRAPH_WIDTH" \
  --set ram.used "${ram_used[@]}" \
  \
  --add graph swap.used right "$USAGE_GRAPH_WIDTH" \
  --set swap.used "${swap_used[@]}"
