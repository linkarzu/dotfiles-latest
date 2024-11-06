#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/dnd.sh

source "$CONFIG_DIR/colors.sh"

DND_ENABLED=$(plutil -convert json -o - ~/Library/DoNotDisturb/DB/Assertions.json | jq -r '.data[0].storeAssertionRecords')

# Check if DND is enabled or not
if [ "$DND_ENABLED" = null ]; then
  # DND is off - hide the icon
  sketchybar -m --set dnd label="" icon.drawing=off
else
  # DND is on - show the icon
  # sketchybar -m --set dnd label="DND" icon=􀆺 icon.color=$GREEN label.color=$GREEN icon.drawing=on
  # sketchybar -m --set dnd label="DND" icon=􀆺 icon.color=$BLUE label.color=$BLUE icon.drawing=on
  sketchybar -m --set dnd label="DND" icon=􀆺 icon.color=$ORANGE label.color=$ORANGE icon.drawing=on
fi
