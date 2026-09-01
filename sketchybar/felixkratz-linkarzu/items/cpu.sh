#!/bin/bash

# Shift zero-width labels back over the graph, including its right padding.
cpu_overlay_padding=$((-USAGE_GRAPH_WIDTH - PADDINGS))

cpu_label_drawing=on
[[ "$SHOW_CPU_PROCESS" == "on" ]] && cpu_label_drawing=off

cpu_top=(
  label.font="$FONT:Semibold:7"
  label=CPU
  # Toggle SHOW_CPU_PROCESS in sketchybarrc to show or hide this label.
  label.drawing=$SHOW_CPU_PROCESS
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  label.max_chars=$((CPU_TOPPROC_MAX_CHARS + 3))
  scroll_texts=off
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  width=0
  padding_right=$cpu_overlay_padding
  y_offset=6
)

cpu_label=(
  label.font="$FONT:Heavy:8"
  label=cpu
  label.drawing=$cpu_label_drawing
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  icon.drawing=off
  click_script="$ACTIVITY_MONITOR_CLICK_SCRIPT"
  width=0
  padding_right=$cpu_overlay_padding
  y_offset=5
)

cpu_percent=(
  label.font="$FONT:Heavy:8"
  label=CPU
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  y_offset=-5
  padding_right=$cpu_overlay_padding
  width=0
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
sketchybar --add graph cpu.sys right "$USAGE_GRAPH_WIDTH" \
  --set cpu.sys "${cpu_sys[@]}" \
  \
  --add graph cpu.user right "$USAGE_GRAPH_WIDTH" \
  --set cpu.user "${cpu_user[@]}" \
  \
  --add item cpu.top right \
  --set cpu.top "${cpu_top[@]}" \
  \
  --add item cpu.label right \
  --set cpu.label "${cpu_label[@]}" \
  \
  --add item cpu.percent right \
  --set cpu.percent "${cpu_percent[@]}"
