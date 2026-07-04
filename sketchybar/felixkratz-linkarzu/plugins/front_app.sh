#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/front_app.sh

if [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "front_app_windows_changed" ]; then
  # if [ "$INFO" = "kitty" ]; then
  #   ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/kitty_name.sh
  #   exit 0
  # fi

  APP="${INFO:-$(yabai -m query --windows --window 2>/dev/null | jq -r '.app // empty')}"

  if [ -z "$APP" ]; then
    exit 0
  fi

  COUNT=$(yabai -m query --windows 2>/dev/null | jq --arg app "$APP" '[.[] | select(.app == $app)] | length')

  if [ "$COUNT" -gt 1 ]; then
    sketchybar --set "$NAME" label="$COUNT" label.drawing=on icon.background.image="app.$APP"
  else
    sketchybar --set "$NAME" label="" label.drawing=off icon.background.image="app.$APP"
  fi
fi
