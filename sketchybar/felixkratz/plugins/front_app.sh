#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/plugins/front_app.sh

if [ "$SENDER" = "front_app_switched" ]; then
	sketchybar --set $NAME label="$INFO" icon.background.image="app.$INFO"
fi
