#!/bin/bash

# Lower this to reduce the gap between CPU and the widget on its right. Keep at
# least 35 so the 100% label and its 5-point graph inset fit.
cpu_percent_column_width=30

cpu_top=(
  label.font="$FONT:Semibold:7"
  label=CPU
  # Toggle SHOW_CPU_PROCESS in sketchybarrc to show or hide this label.
  label.drawing=$SHOW_CPU_PROCESS
  label.width=$USAGE_GRAPH_WIDTH
  label.max_chars=$((CPU_TOPPROC_MAX_CHARS + 3))
  scroll_texts=off
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  width=0
  # Align the process label's right edge with the CPU graph.
  padding_right=$((cpu_percent_column_width + PADDINGS))
  y_offset=6
)

cpu_label=(
  label.font="$FONT:Heavy:10"
  label=cpu
  label.width=$cpu_percent_column_width
  label.align=left
  label.padding_left=5
  label.padding_right=0
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  width=0
  padding_right=1
  y_offset=8
)

cpu_percent=(
  label.font="$FONT:Heavy:10"
  label=CPU
  # Match the RAM label inset from its graph.
  label.width=$cpu_percent_column_width
  label.align=left
  label.padding_left=5
  label.padding_right=0
  y_offset=-4
  padding_right=1
  width=$cpu_percent_column_width
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  update_freq=4
  mach_helper="$HELPER"
)

cpu_sys=(
  width=0
  graph.color=$RED
  graph.fill_color=$RED
  label.drawing=off
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

cpu_user=(
  graph.color=$BLUE
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
sketchybar --add item cpu.top right \
  --set cpu.top "${cpu_top[@]}" \
  \
  --add item cpu.label right \
  --set cpu.label "${cpu_label[@]}" \
  \
  --add item cpu.percent right \
  --set cpu.percent "${cpu_percent[@]}" \
  \
  --add graph cpu.sys right "$USAGE_GRAPH_WIDTH" \
  --set cpu.sys "${cpu_sys[@]}" \
  \
  --add graph cpu.user right "$USAGE_GRAPH_WIDTH" \
  --set cpu.user "${cpu_user[@]}"
