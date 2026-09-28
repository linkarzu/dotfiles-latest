#!/bin/bash

# Right click any CPU item for the stats and top apps popup.
CPU_CLICK_SCRIPT="ACTIVITY_MONITOR_CLICK_SCRIPT=\"$ACTIVITY_MONITOR_CLICK_SCRIPT\" $PLUGIN_DIR/usage_click.sh cpu.user"

# Must match CPU_TOP_APPS in helper/cpu.h.
CPU_POPUP_APPS=8

# Shift zero-width labels back over the graph, including its right padding.
cpu_graph_padding_right=6
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
  click_script="$CPU_CLICK_SCRIPT"
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
  click_script="$CPU_CLICK_SCRIPT"
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
  click_script="$CPU_CLICK_SCRIPT"
  update_freq=4
  mach_helper="$HELPER"
)

cpu_sys=(
  width=0
  graph.color=$RED
  graph.fill_color=$RED
  padding_right=$cpu_graph_padding_right
  label.drawing=off
  icon.drawing=off
  click_script="$CPU_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

cpu_user=(
  graph.color=$BLUE
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
  click_script="sketchybar --set cpu.user popup.drawing=off; $ACTIVITY_MONITOR_CLICK_SCRIPT"
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

# Popup rows are filled in by the helper on every update. App percentages are
# a share of the whole machine, so they add up to the CPU busy value.
sketchybar --add item cpu.popup.usage popup.cpu.user \
  --set cpu.popup.usage "${cpu_popup_row[@]}" icon="CPU busy" label="--" \
  \
  --add item cpu.popup.split popup.cpu.user \
  --set cpu.popup.split "${cpu_popup_row[@]}" icon="User / system" label="--" \
  \
  --add item cpu.popup.load popup.cpu.user \
  --set cpu.popup.load "${cpu_popup_row[@]}" icon="Load average" label="--" \
  \
  --add item cpu.popup.header popup.cpu.user \
  --set cpu.popup.header "${cpu_popup_header[@]}" icon="Top apps (all processes)" label="4s avg"

for ((i = 1; i <= CPU_POPUP_APPS; i++)); do
  sketchybar --add item "cpu.popup.app.$i" popup.cpu.user \
    --set "cpu.popup.app.$i" "${cpu_popup_row[@]}" icon="Sampling..." label="" drawing=$([ "$i" = 1 ] && echo on || echo off)
done

# Root processes like WindowServer, and processes that started and exited
# between two updates, can't be read per app.
sketchybar --add item cpu.popup.other popup.cpu.user \
  --set cpu.popup.other "${cpu_popup_header[@]}" icon="System / other" label="--"
