#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/forager_battery.sh

# Shows the battery level of both Forager halves, colored like battery.sh: green
# from 80%, yellow from 30%, red below that. Hidden when the keyboard isn't
# connected.
source "$CONFIG_DIR/colors.sh"

source_file="$(dirname "${BASH_SOURCE[0]}")/forager_battery.swift"
bin="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/forager-battery"

if [[ ! -x "$bin" || "$source_file" -nt "$bin" ]]; then
  mkdir -p "$(dirname "$bin")" &&
    swiftc -O -o "$bin.$$" "$source_file" &&
    mv -f "$bin.$$" "$bin"
fi

color() {
  case "$1" in
  [8-9][0-9] | 100) echo "$GREEN" ;;
  [3-7][0-9]) echo "$YELLOW" ;;
  [0-9] | [1-2][0-9]) echo "$RED" ;;
  *) echo "$GREY" ;;
  esac
}

if ! read -r left right < <("$bin" 2>/dev/null) || [[ -z "$right" ]]; then
  sketchybar --set '/forager\..*/' drawing=off
  exit 0
fi

sketchybar --set '/forager\..*/' drawing=on \
  --set forager.left label="L $left" label.color="$(color "$left")" \
  --set forager.right label="R $right" label.color="$(color "$right")"
