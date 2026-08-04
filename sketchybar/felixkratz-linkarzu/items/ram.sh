#!/bin/bash

ram_percent=(
  icon="ram 0%"
  icon.font="$FONT:Heavy:10"
  icon.width=0
  icon.y_offset=5
  icon.padding_left=0
  icon.padding_right=0
  label.font="$FONT:Heavy:10"
  label="swp 0G"
  label.y_offset=-5
  label.padding_left=0
  label.padding_right=10
  padding_right=27
  width=75
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

sketchybar --add item ram.percent right \
  --set ram.percent "${ram_percent[@]}" \
  \
  --add graph ram.used right 75 \
  --set ram.used "${ram_used[@]}" \
  \
  --add graph swap.used right 75 \
  --set swap.used "${swap_used[@]}"
