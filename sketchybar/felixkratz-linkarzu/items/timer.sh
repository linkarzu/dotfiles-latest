#!/usr/bin/env bash

sketchybar --add event reset_timer

timer=(
  script="${PLUGIN_DIR}/reset_timer.sh"
  icon=""
  click_script="sketchybar --set timer popup.drawing=toggle ; sketchybar --trigger reset_timer"
)

stopwatch=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py"
  label="SW Mode"
)

preset0=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py 60"
  label="1 min"
)

preset1=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py 180"
  label="3 min"
)

preset2=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py 300"
  label="5 min"
)

preset3=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py 1800"
  label="30 min"
)

preset4=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py 2400"
  label="40 min"
)

preset5=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py 3600"
  label="60 min"
)

preset6=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py 4800"
  label="80 min"
)

sketchybar --add item timer left \
  --set timer "${timer[@]}" \
  --subscribe timer reset_timer \
  --add item timer.stopwatch popup.timer \
  --set timer.stopwatch "${stopwatch[@]}" \
  --add item timer.preset0 popup.timer \
  --set timer.preset0 "${preset0[@]}" \
  --add item timer.preset1 popup.timer \
  --set timer.preset1 "${preset1[@]}" \
  --add item timer.preset2 popup.timer \
  --set timer.preset2 "${preset2[@]}" \
  --add item timer.preset3 popup.timer \
  --set timer.preset3 "${preset3[@]}" \
  --add item timer.preset4 popup.timer \
  --set timer.preset4 "${preset4[@]}" \
  --add item timer.preset5 popup.timer \
  --set timer.preset5 "${preset5[@]}" \
  --add item timer.preset6 popup.timer \
  --set timer.preset6 "${preset6[@]}"
