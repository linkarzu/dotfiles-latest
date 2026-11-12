#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/usage_click.sh

# Right click toggles the stats popup of the clicked CPU, RAM, GPU, keyboard or Claude
# widget and closes the others, left click opens Activity Monitor, except on the
# keyboard and Claude widgets, which don't set ACTIVITY_MONITOR_CLICK_SCRIPT.
# Usage: usage_click.sh <popup item>, one of cpu.graph, ram.graph, gpu.graph, keyboard.frame or claude_usage.frame.
POPUP_ITEMS=(cpu.graph ram.graph gpu.graph keyboard.frame claude_usage.frame)

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
