#!/bin/bash

# Right click any GPU item for the stats and top GPU processes popup.
GPU_CLICK_SCRIPT="ACTIVITY_MONITOR_CLICK_SCRIPT=\"$ACTIVITY_MONITOR_CLICK_SCRIPT\" $PLUGIN_DIR/gpu_click.sh"

# Must match GPU_TOP_PROCS in helper/gpu.h.
GPU_POPUP_PROCS=8

# Shift zero-width labels back over the graph, including its right padding.
gpu_graph_padding_right=4
gpu_overlay_padding=$((-USAGE_GRAPH_WIDTH - PADDINGS))

gpu_top=(
  label.font="$FONT:Heavy:8"
  label="gpu 0%"
  label.y_offset=5
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$gpu_overlay_padding
  width=0
  icon.drawing=off
  click_script="$GPU_CLICK_SCRIPT"
)

# Hottest SoC die sensor, the GPU shares the die with the CPU.
gpu_temp=(
  label.font="$FONT:Heavy:8"
  label="--°"
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

gpu_util=(
  padding_right=$gpu_graph_padding_right
  graph.color=$MAGENTA
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
  click_script="sketchybar --set gpu.util popup.drawing=off; $ACTIVITY_MONITOR_CLICK_SCRIPT"
)

gpu_popup_header=(
  "${gpu_popup_row[@]}"
  icon.color=$GREY
  label.color=$GREY
)

# Change USAGE_GRAPH_WIDTH_PERCENT in sketchybarrc (100 = original 75-point width).
sketchybar --add graph gpu.util right "$USAGE_GRAPH_WIDTH" \
  --set gpu.util "${gpu_util[@]}" \
  \
  --add item gpu.top right \
  --set gpu.top "${gpu_top[@]}" \
  \
  --add item gpu.temp right \
  --set gpu.temp "${gpu_temp[@]}"

# Popup rows are filled in by the helper on every update.
sketchybar --add item gpu.popup.util popup.gpu.util \
  --set gpu.popup.util "${gpu_popup_row[@]}" icon="GPU busy" label="--" \
  \
  --add item gpu.popup.stages popup.gpu.util \
  --set gpu.popup.stages "${gpu_popup_row[@]}" icon="Renderer / tiler" label="--" \
  \
  --add item gpu.popup.memory popup.gpu.util \
  --set gpu.popup.memory "${gpu_popup_row[@]}" icon="GPU memory (shared)" label="--" \
  \
  --add item gpu.popup.temp popup.gpu.util \
  --set gpu.popup.temp "${gpu_popup_row[@]}" icon="Hottest die sensor" label="--" \
  \
  --add item gpu.popup.header popup.gpu.util \
  --set gpu.popup.header "${gpu_popup_header[@]}" icon="Top GPU processes" label="4s avg"

for ((i = 1; i <= GPU_POPUP_PROCS; i++)); do
  sketchybar --add item "gpu.popup.proc.$i" popup.gpu.util \
    --set "gpu.popup.proc.$i" "${gpu_popup_row[@]}" icon="Sampling..." label="" drawing=$([ "$i" = 1 ] && echo on || echo off)
done
