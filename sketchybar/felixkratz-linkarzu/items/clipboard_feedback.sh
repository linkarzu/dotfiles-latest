#!/bin/bash

clipboard_feedback=(
  drawing=off
  icon.drawing=off
  label="COPY"
  label.color="$GREEN"
  label.font="$FONT:Bold:10.0"
  label.padding_left=4
  label.padding_right=4
  background.drawing=on
  background.color="$BG1"
  background.border_color="$GREEN"
  background.border_width=1
  background.height=15
  background.corner_radius=4
)

sketchybar --add item clipboard.feedback right \
  --set clipboard.feedback "${clipboard_feedback[@]}"
