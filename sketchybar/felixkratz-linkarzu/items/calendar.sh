#!/bin/bash

# Keep the date and time in a shared column so the time stays centered below it.
calendar_date=(
  label.font="$FONT:Black:11.0"
  label="Mon 000000"
  label.width=75
  label.align=center
  label.y_offset=5
  label.padding_left=0
  label.padding_right=0
  width=0
  icon.drawing=off
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

calendar_time=(
  label.font="$FONT:Black:11.0"
  label="00:00"
  label.width=75
  label.align=center
  label.y_offset=-5
  label.padding_left=0
  label.padding_right=0
  padding_left=10
  width=75
  icon.drawing=off
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar.date right \
  --set calendar.date "${calendar_date[@]}" \
  --subscribe calendar.date system_woke \
  \
  --add item calendar.time right \
  --set calendar.time "${calendar_time[@]}"
