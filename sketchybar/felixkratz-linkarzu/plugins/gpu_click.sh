#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/gpu_click.sh

# Right click toggles the GPU stats popup, left click opens Activity Monitor.
if [ "$BUTTON" = "right" ]; then
  sketchybar --set gpu.util popup.drawing=toggle
else
  sketchybar --set gpu.util popup.drawing=off
  eval "$ACTIVITY_MONITOR_CLICK_SCRIPT"
fi
