#!/bin/bash

cpu_top=(
  label.font="$FONT:Semibold:7"
  label=CPU
  label.width=$USAGE_GRAPH_WIDTH
  label.max_chars=$((CPU_TOPPROC_MAX_CHARS + 3))
  scroll_texts=off
  icon.drawing=off
  width=0
  # Align the process label's right edge with the CPU graph.
  padding_right=56
  y_offset=6
)

cpu_percent=(
  label.font="$FONT:Heavy:12"
  label=CPU
  y_offset=-4
  padding_right=15
  width=55
  icon.drawing=off
  update_freq=4
  mach_helper="$HELPER"
)

cpu_sys=(
  width=0
  graph.color=$RED
  graph.fill_color=$RED
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

cpu_user=(
  graph.color=$BLUE
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

# Change USAGE_GRAPH_WIDTH_PERCENT in sketchybarrc (100 = original 75-point width).
sketchybar --add item cpu.top right \
  --set cpu.top "${cpu_top[@]}" \
  \
  --add item cpu.percent right \
  --set cpu.percent "${cpu_percent[@]}" \
  \
  --add graph cpu.sys right "$USAGE_GRAPH_WIDTH" \
  --set cpu.sys "${cpu_sys[@]}" \
  \
  --add graph cpu.user right "$USAGE_GRAPH_WIDTH" \
  --set cpu.user "${cpu_user[@]}"
