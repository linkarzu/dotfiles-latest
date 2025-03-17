#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/zen.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/zen.sh

zen_on() {
  sketchybar --set apple.logo drawing=on \
    --set '/cpu.*/' drawing=on \
    --set calendar icon.drawing=on \
    --set battery drawing=on \
    --set mic drawing=on \
    --set front_app drawing=on label.drawing=off \
    --set brew drawing=off \
    --set volume_icon drawing=off \
    --set spotify.anchor drawing=off \
    --set spotify.play updates=off \
    --set timer drawing=off \
    --set volume drawing=off \
    --set github.bell drawing=off \
    --set wifi drawing=off
}

zen_off() {
  sketchybar --set apple.logo drawing=on \
    --set '/cpu.*/' drawing=on \
    --set calendar icon.drawing=on \
    --set battery drawing=on \
    --set mic drawing=on \
    --set front_app drawing=on label.drawing=on \
    --set brew drawing=on \
    --set volume_icon drawing=on \
    --set spotify.play updates=on \
    --set timer drawing=on \
    --set volume drawing=on \
    --set github.bell drawing=on \
    --set wifi drawing=on
}

if [ "$1" = "on" ]; then
  zen_on
elif [ "$1" = "off" ]; then
  zen_off
else
  # check for something that is off
  if [ "$(sketchybar --query wifi | jq -r ".geometry.drawing")" = "on" ]; then
    zen_on
  else
    zen_off
  fi
fi
