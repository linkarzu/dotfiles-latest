#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/host_hand.sh
# Raise or lower my hand in a show with guests (guest show or Open Terminal), left of opencode.
# Hidden unless such a show is prepared or live; click toggles, like Enter-O-H. Right click opens
# a menu that mutes or unmutes every guest through vdo.ninja.

host_hand=(
  updates=on
  update_freq=2
  drawing=off
  icon=""
  icon.font="$FONT:Bold:15.0"
  icon.color=$GREY
  label.drawing=off
  icon.padding_right=6
  popup.height=28
  popup.align=right
  script="$PLUGIN_DIR/host_hand.sh"
)

host_hand_mute=(
  label="Mute all guests"
  icon="󰍭"
  click_script="$PLUGIN_DIR/host_hand_mute.sh on"
)

host_hand_unmute=(
  label="Unmute all guests"
  icon="󰍬"
  click_script="$PLUGIN_DIR/host_hand_mute.sh off"
)

sketchybar --add event host_hand_update \
  --add item host_hand right \
  --set host_hand "${host_hand[@]}" \
  --subscribe host_hand host_hand_update system_woke mouse.clicked mouse.exited.global \
  \
  --add item host_hand.mute popup.host_hand \
  --set host_hand.mute "${host_hand_mute[@]}" \
  \
  --add item host_hand.unmute popup.host_hand \
  --set host_hand.unmute "${host_hand_unmute[@]}"
