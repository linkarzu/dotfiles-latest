#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/plugins/front_app.sh

if [ "$SENDER" = "front_app_switched" ]; then
  # if [ "$INFO" = "kitty" ]; then
  #   ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/kitty_name.sh
  #   exit 0
  # fi
  sketchybar --set $NAME label="$INFO" icon.background.image="app.$INFO"
fi
