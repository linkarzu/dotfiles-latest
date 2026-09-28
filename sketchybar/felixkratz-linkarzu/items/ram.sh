#!/bin/bash

# Right click any RAM item for the stats and top apps popup.
RAM_CLICK_SCRIPT="ACTIVITY_MONITOR_CLICK_SCRIPT=\"$ACTIVITY_MONITOR_CLICK_SCRIPT\" $PLUGIN_DIR/usage_click.sh swap.used"

# Must match RAM_TOP_APPS in helper/ram.h.
RAM_POPUP_APPS=8

# Shift zero-width labels back over the graph, including its right padding.
ram_graph_padding_right=4
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
  click_script="$RAM_CLICK_SCRIPT"
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
  click_script="$RAM_CLICK_SCRIPT"
  update_freq=4
  mach_helper="$HELPER"
)

ram_used=(
  width=0
  padding_right=$ram_graph_padding_right
  graph.color=$ORANGE
  label.drawing=off
  icon.drawing=off
  click_script="$RAM_CLICK_SCRIPT"
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

swap_used=(
  padding_right=$ram_graph_padding_right
  graph.color=$GREEN
  label.drawing=off
  icon.drawing=off
  click_script="$RAM_CLICK_SCRIPT"
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

ram_popup_row=(
  icon.font="$FONT:Bold:12"
  icon.width=190
  icon.padding_left=10
  label.font="$FONT:Semibold:12"
  label.width=100
  label.align=right
  label.padding_right=10
  click_script="sketchybar --set swap.used popup.drawing=off; $ACTIVITY_MONITOR_CLICK_SCRIPT"
)

ram_popup_header=(
  "${ram_popup_row[@]}"
  icon.color=$GREY
  label.color=$GREY
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

# Popup rows are filled in by the helper on every update. App memory is the
# memory footprint, the same value as Activity Monitor's Memory column.
sketchybar --add item ram.popup.used popup.swap.used \
  --set ram.popup.used "${ram_popup_row[@]}" icon="Used" label="--" \
  \
  --add item ram.popup.wired popup.swap.used \
  --set ram.popup.wired "${ram_popup_row[@]}" icon="Wired" label="--" \
  \
  --add item ram.popup.compressed popup.swap.used \
  --set ram.popup.compressed "${ram_popup_row[@]}" icon="Compressed" label="--" \
  \
  --add item ram.popup.cached popup.swap.used \
  --set ram.popup.cached "${ram_popup_row[@]}" icon="Cached files" label="--" \
  \
  --add item ram.popup.swap popup.swap.used \
  --set ram.popup.swap "${ram_popup_row[@]}" icon="Swap used" label="--" \
  \
  --add item ram.popup.pressure popup.swap.used \
  --set ram.popup.pressure "${ram_popup_row[@]}" icon="Memory pressure" label="--" \
  \
  --add item ram.popup.header popup.swap.used \
  --set ram.popup.header "${ram_popup_header[@]}" icon="Top apps (all processes)" label="footprint"

for ((i = 1; i <= RAM_POPUP_APPS; i++)); do
  sketchybar --add item "ram.popup.app.$i" popup.swap.used \
    --set "ram.popup.app.$i" "${ram_popup_row[@]}" icon="Sampling..." label="" drawing=$([ "$i" = 1 ] && echo on || echo off)
done
