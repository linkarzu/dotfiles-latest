#!/bin/bash

# Right click any CPU item for the stats and top apps popup.
CPU_CLICK_SCRIPT="ACTIVITY_MONITOR_CLICK_SCRIPT=\"$ACTIVITY_MONITOR_CLICK_SCRIPT\" $PLUGIN_DIR/usage_click.sh cpu.graph"

# Must match CPU_TOP_APPS in helper/cpu.h.
CPU_POPUP_APPS=8

# Shift zero-width labels back over the graph, including its right padding.
cpu_graph_padding_right=6
cpu_overlay_padding=$((-USAGE_GRAPH_WIDTH - PADDINGS))

# The top line shows the top CPU process instead of "cpu <temp>" when
# SHOW_CPU_PROCESS is on in sketchybarrc.
cpu_top_drawing=on
[[ "$SHOW_CPU_PROCESS" == "on" ]] && cpu_top_drawing=off

# CPU name and the average of the P-core and E-core temperature sensors.
cpu_top=(
  label.font="$USAGE_TOP_FONT"
  label="C --°"
  label.drawing=$cpu_top_drawing
  label.y_offset=7
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$cpu_overlay_padding
  width=0
  icon.drawing=off
  click_script="$CPU_CLICK_SCRIPT"
)

cpu_process=(
  label.font="$FONT:Semibold:7"
  label=CPU
  label.drawing=$SHOW_CPU_PROCESS
  label.y_offset=7
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  label.max_chars=$((CPU_TOPPROC_MAX_CHARS + 3))
  scroll_texts=off
  padding_right=$cpu_overlay_padding
  width=0
  icon.drawing=off
  click_script="$CPU_CLICK_SCRIPT"
)

cpu_percent=(
  label.font="$USAGE_PERCENT_FONT"
  label="0%"
  label.y_offset=-5
  label.width=$USAGE_GRAPH_WIDTH
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$cpu_overlay_padding
  width=0
  icon.drawing=off
  click_script="$CPU_CLICK_SCRIPT"
  update_freq=4
  mach_helper="$HELPER"
)

# CPU system time, drawn under the total.
cpu_sys=(
  width=0
  graph.color=$USAGE_GRAPH_SECONDARY_COLOR
  padding_right=$cpu_graph_padding_right
  label.drawing=off
  icon.drawing=off
  click_script="$CPU_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

# Total CPU busy, user plus system.
cpu_graph=(
  graph.color=$USAGE_GRAPH_COLOR
  padding_right=$cpu_graph_padding_right
  label.drawing=off
  icon.drawing=off
  click_script="$CPU_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  popup.align=center
  popup.height=20
  # Draw the shared 0-100% frame once, above both graph layers.
  background.border_width=1
  background.border_color=$GREY
  background.corner_radius=0
)

cpu_popup_row=(
  icon.font="$FONT:Bold:12"
  icon.width=190
  icon.padding_left=10
  label.font="$FONT:Semibold:12"
  label.width=100
  label.align=right
  label.padding_right=10
  click_script="sketchybar --set cpu.graph popup.drawing=off; $ACTIVITY_MONITOR_CLICK_SCRIPT"
)

cpu_popup_header=(
  "${cpu_popup_row[@]}"
  icon.color=$GREY
  label.color=$GREY
)

# Change USAGE_GRAPH_WIDTH_PERCENT in sketchybarrc (100 = original 75-point width).
sketchybar --add graph cpu.sys right "$USAGE_GRAPH_WIDTH" \
  --set cpu.sys "${cpu_sys[@]}" \
  \
  --add graph cpu.graph right "$USAGE_GRAPH_WIDTH" \
  --set cpu.graph "${cpu_graph[@]}" \
  \
  --add item cpu.top right \
  --set cpu.top "${cpu_top[@]}" \
  \
  --add item cpu.process right \
  --set cpu.process "${cpu_process[@]}" \
  \
  --add item cpu.percent right \
  --set cpu.percent "${cpu_percent[@]}"

# Popup rows are filled in by the helper on every update. App percentages are
# a share of the whole machine, so they add up to the CPU busy value.
sketchybar --add item cpu.popup.usage popup.cpu.graph \
  --set cpu.popup.usage "${cpu_popup_row[@]}" icon="CPU busy" label="--" \
  \
  --add item cpu.popup.split popup.cpu.graph \
  --set cpu.popup.split "${cpu_popup_row[@]}" icon="User / system" label="--" \
  \
  --add item cpu.popup.load popup.cpu.graph \
  --set cpu.popup.load "${cpu_popup_row[@]}" icon="Load average" label="--" \
  \
  --add item cpu.popup.temp popup.cpu.graph \
  --set cpu.popup.temp "${cpu_popup_row[@]}" icon="CPU temperature" label="--" \
  \
  --add item cpu.popup.header popup.cpu.graph \
  --set cpu.popup.header "${cpu_popup_header[@]}" icon="Top apps (all processes)" label="4s avg"

for ((i = 1; i <= CPU_POPUP_APPS; i++)); do
  sketchybar --add item "cpu.popup.app.$i" popup.cpu.graph \
    --set "cpu.popup.app.$i" "${cpu_popup_row[@]}" icon="Sampling..." label="" drawing=$([ "$i" = 1 ] && echo on || echo off)
done

# Root processes like WindowServer, and processes that started and exited
# between two updates, can't be read per app.
sketchybar --add item cpu.popup.other popup.cpu.graph \
  --set cpu.popup.other "${cpu_popup_header[@]}" icon="System / other" label="--"
