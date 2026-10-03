#!/bin/bash

# Half as wide as the CPU, RAM and GPU graphs.
DISK_WIDTH=$((USAGE_GRAPH_WIDTH / 2))

# Shift zero-width labels back over the graph, including its right padding.
disk_graph_padding_right=4
disk_overlay_padding=$((-DISK_WIDTH - PADDINGS))

disk_top=(
  label.font="$USAGE_TOP_FONT"
  label="D"
  label.y_offset=7
  label.width=$DISK_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$disk_overlay_padding
  width=0
  icon.drawing=off
)

# Used percentage, without a % sign so it fits the half-width graph.
disk_percent=(
  label.font="$USAGE_PERCENT_FONT"
  label="--"
  label.y_offset=-5
  label.width=$DISK_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$disk_overlay_padding
  width=0
  icon.drawing=off
  script="$PLUGIN_DIR/disk.sh"
  updates=on
  update_freq=4
)

# Startup disk used.
disk_graph=(
  graph.color=$USAGE_GRAPH_COLOR
  padding_right=$disk_graph_padding_right
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  # Draw the 0-100% frame.
  background.border_width=1
  background.border_color=$USAGE_GRAPH_BORDER_COLOR
  background.corner_radius=0
  # sketchybar draws the graph 1pt right of its background, move the frame
  # along so the graph fills it edge to edge.
  background.x_offset=1
)

sketchybar --add graph disk.graph right "$DISK_WIDTH" \
  --set disk.graph "${disk_graph[@]}" \
  \
  --add item disk.top right \
  --set disk.top "${disk_top[@]}" \
  \
  --add item disk.percent right \
  --set disk.percent "${disk_percent[@]}" \
  --subscribe disk.percent system_woke
