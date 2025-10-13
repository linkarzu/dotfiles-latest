#!/usr/bin/env bash

source "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"

# update border color only for BSP spaces; invisible elsewhere
space_json=$(yabai -m query --spaces --space)
layout=$(printf '%s' "$space_json" | jq -r '.type')

if [[ "$layout" != "bsp" ]]; then
  borders hidpi=on width=5.0 inactive_color=0x00000000 active_color=0x00000000 &
  exit 0
fi

# layout is BSP: use window count
n=$(printf '%s' "$space_json" | jq '.windows | length')

if [[ ${n:-0} -eq 1 ]]; then
  borders hidpi=on width=5.0 inactive_color=0x00000000 active_color=0x00000000 &
else
  borders hidpi=on width=5.0 inactive_color=0x00000000 active_color="$GREEN" &
fi
