#!/bin/env/bash

# https://github.com/Pe8er/dotfiles/blob/00d5d13a781f1d9c0ae4f518c79a96d6c8e286db/config.symlink/sketchybar/items/dnd.sh

dnd=(
	script="$PLUGIN_DIR/dnd.sh"
	label.drawing=off
	update_freq=10
	icon=􀆺
	--add event focus_on "_NSDoNotDisturbEnabledNotification"
	--add event focus_off "_NSDoNotDisturbDisabledNotification"
	--subscribe dnd focus_on focus_off mouse.clicked
)

sketchybar \
	--add item dnd right \
	--set dnd "${dnd[@]}"
