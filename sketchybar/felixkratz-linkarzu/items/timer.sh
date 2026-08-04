#!/usr/bin/env bash

sketchybar --add event reset_timer

timer=(
  script="${PLUGIN_DIR}/reset_timer.sh"
  icon=""
  popup.height=28
  click_script="sketchybar --set timer popup.drawing=toggle"
)

stopwatch=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py stopwatch"
  label="SW Mode"
)

stop=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py stop"
  label="Stop"
)

custom=(
  click_script="sketchybar --set timer popup.drawing=toggle ; ${PLUGIN_DIR}/custom_timer.sh"
  label="Custom"
)

sit_30_10=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py sequence Sit:1800,Stand:600"
  label="Sit-30-10"
)

stand_10_30=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py sequence Stand:600,Sit:1800"
  label="Stand-10-30"
)

preset0=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 60"
  label="1 min"
)

preset1=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 120"
  label="2 min"
)

preset2=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 180"
  label="3 min"
)

preset3=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 240"
  label="4 min"
)

preset4=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 300"
  label="5 min"
)

preset5=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 600"
  label="10 min"
)

preset6=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 1200"
  label="20 min"
)

preset7=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 1800"
  label="30 min"
)

preset8=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 3600"
  label="60 min"
)

preset9=(
  click_script="sketchybar --set timer popup.drawing=toggle ; python3 ${PLUGIN_DIR}/timer.py timer 7200"
  label="120 min"
)

sketchybar --add item timer left \
  --set timer "${timer[@]}" \
  --subscribe timer reset_timer \
  --add item timer.stopwatch popup.timer \
  --set timer.stopwatch "${stopwatch[@]}" \
  --add item timer.stop popup.timer \
  --set timer.stop "${stop[@]}" \
  --add item timer.custom popup.timer \
  --set timer.custom "${custom[@]}" \
  --add item timer.sit_30_10 popup.timer \
  --set timer.sit_30_10 "${sit_30_10[@]}" \
  --add item timer.stand_10_30 popup.timer \
  --set timer.stand_10_30 "${stand_10_30[@]}" \
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
  --set timer.preset6 "${preset6[@]}" \
  --add item timer.preset7 popup.timer \
  --set timer.preset7 "${preset7[@]}" \
  --add item timer.preset8 popup.timer \
  --set timer.preset8 "${preset8[@]}" \
  --add item timer.preset9 popup.timer \
  --set timer.preset9 "${preset9[@]}"
