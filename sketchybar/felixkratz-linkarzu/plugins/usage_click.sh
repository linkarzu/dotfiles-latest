#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/usage_click.sh

# Right click toggles the stats popup of the clicked CPU, RAM or GPU widget and
# closes the other two, left click opens Activity Monitor.
# Usage: usage_click.sh <popup item>, one of cpu.graph, ram.graph or gpu.graph.
POPUP_ITEMS=(cpu.graph ram.graph gpu.graph)

args=()
for item in "${POPUP_ITEMS[@]}"; do
  if [ "$BUTTON" = "right" ] && [ "$item" = "$1" ]; then
    args+=(--set "$item" popup.drawing=toggle)
  else
    args+=(--set "$item" popup.drawing=off)
  fi
done
sketchybar "${args[@]}"

if [ "$BUTTON" != "right" ]; then
  eval "$ACTIVITY_MONITOR_CLICK_SCRIPT"
fi
