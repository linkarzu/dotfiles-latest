#!/bin/bash

# Right click any GPU item for the stats and top GPU processes popup.
GPU_CLICK_SCRIPT="ACTIVITY_MONITOR_CLICK_SCRIPT=\"$ACTIVITY_MONITOR_CLICK_SCRIPT\" $PLUGIN_DIR/usage_click.sh gpu.graph"

# Must match GPU_TOP_PROCS in helper/gpu.h.
GPU_POPUP_PROCS=8

# Shift zero-width labels back over the graph, including its right padding.
gpu_graph_padding_right=4
gpu_overlay_padding=$((-USAGE_GRAPH_WIDTH - PADDINGS))

# GPU name and the average of the GPU temperature sensors.
gpu_top=(
  label.font="$USAGE_TOP_FONT"
  label="G --°"
  label.y_offset=7
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$gpu_overlay_padding
  width=0
  icon.drawing=off
  click_script="$GPU_CLICK_SCRIPT"
)

gpu_percent=(
  label.font="$USAGE_PERCENT_FONT"
  label="0%"
  label.y_offset=-5
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$gpu_overlay_padding
  width=0
  icon.drawing=off
  click_script="$GPU_CLICK_SCRIPT"
  update_freq=4
  mach_helper="$HELPER"
)

# GPU busy.
gpu_graph=(
  graph.color=$USAGE_GRAPH_COLOR
  padding_right=$gpu_graph_padding_right
  label.drawing=off
  icon.drawing=off
  click_script="$GPU_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  popup.align=center
  popup.height=20
  # Draw the 0-100% frame.
  background.border_width=1
  background.border_color=$GREY
  background.corner_radius=0
)

gpu_popup_row=(
  icon.font="$FONT:Bold:12"
  icon.width=190
  icon.padding_left=10
  label.font="$FONT:Semibold:12"
  label.width=100
  label.align=right
  label.padding_right=10
  click_script="sketchybar --set gpu.graph popup.drawing=off; $ACTIVITY_MONITOR_CLICK_SCRIPT"
)

gpu_popup_header=(
  "${gpu_popup_row[@]}"
  icon.color=$GREY
  label.color=$GREY
)

# Change USAGE_GRAPH_WIDTH_PERCENT in sketchybarrc (100 = original 75-point width).
sketchybar --add graph gpu.graph right "$USAGE_GRAPH_WIDTH" \
  --set gpu.graph "${gpu_graph[@]}" \
  \
  --add item gpu.top right \
  --set gpu.top "${gpu_top[@]}" \
  \
  --add item gpu.percent right \
  --set gpu.percent "${gpu_percent[@]}"

# Popup rows are filled in by the helper on every update.
sketchybar --add item gpu.popup.util popup.gpu.graph \
  --set gpu.popup.util "${gpu_popup_row[@]}" icon="GPU busy" label="--" \
  \
  --add item gpu.popup.stages popup.gpu.graph \
  --set gpu.popup.stages "${gpu_popup_row[@]}" icon="Renderer / tiler" label="--" \
  \
  --add item gpu.popup.memory popup.gpu.graph \
  --set gpu.popup.memory "${gpu_popup_row[@]}" icon="GPU memory (shared)" label="--" \
  \
  --add item gpu.popup.temp popup.gpu.graph \
  --set gpu.popup.temp "${gpu_popup_row[@]}" icon="GPU temperature" label="--" \
  \
  --add item gpu.popup.header popup.gpu.graph \
  --set gpu.popup.header "${gpu_popup_header[@]}" icon="Top GPU processes" label="4s avg"

for ((i = 1; i <= GPU_POPUP_PROCS; i++)); do
  sketchybar --add item "gpu.popup.proc.$i" popup.gpu.graph \
    --set "gpu.popup.proc.$i" "${gpu_popup_row[@]}" icon="Sampling..." label="" drawing=$([ "$i" = 1 ] && echo on || echo off)
done
