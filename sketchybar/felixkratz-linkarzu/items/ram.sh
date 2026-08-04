#!/bin/bash

ram_top=(
  label.font="$FONT:Heavy:10"
  label="ram 0%"
  label.y_offset=5
  label.width=60
  label.align=left
  label.padding_left=5
  label.padding_right=0
  width=0
  icon.drawing=off
)

swap_percent=(
  label.font="$FONT:Heavy:10"
  label="swp 0G"
  label.y_offset=-5
  label.width=60
  label.align=left
  label.padding_left=5
  label.padding_right=0
  padding_right=1
  width=60
  icon.drawing=off
  update_freq=4
  mach_helper="$HELPER"
)

ram_used=(
  width=0
  graph.color=$ORANGE
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

swap_used=(
  graph.color=$GREEN
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

sketchybar --add item ram.top right \
  --set ram.top "${ram_top[@]}" \
  \
  --add item swap.percent right \
  --set swap.percent "${swap_percent[@]}" \
  \
  --add graph ram.used right 75 \
  --set ram.used "${ram_used[@]}" \
  \
  --add graph swap.used right 75 \
  --set swap.used "${swap_used[@]}"
