#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/brew.sh

source "$CONFIG_DIR/colors.sh"

# This script used to run `brew outdated` directly from SketchyBar's plugin
# shell (`#!/bin/bash`). In that non-interactive SketchyBar environment,
# Homebrew could find `brew` but crashed inside its Ruby process/cask handling.
# Running the same command through `zsh -lc` uses a login zsh like the terminal,
# where `brew outdated | wc -l | tr -d " "` works reliably and returns the count.
if COUNT="$(zsh -lc 'brew outdated | wc -l | tr -d " "')"; then
  RC=0
else
  RC=$?
  COUNT="!"
  COLOR=$RED
fi

case "$COUNT" in
[6-9][0-9] | [1-9][0-9][0-9]*)
  COLOR=0xffef555f
  ;;
[3-5][0-9])
  COLOR=$ORANGE
  ;;
[1-2][0-9])
  COLOR=$YELLOW
  ;;
[1-9])
  COLOR=$WHITE
  ;;
0)
  COLOR=$GREEN
  COUNT=􀆅
  ;;
esac

sketchybar --set $NAME label=$COUNT icon.color=$COLOR
