#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/kitty_name.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/kitty_name.sh

# Sketchybar won't be able to get the kitty title name, unless the socket is
# used. This gets the kitty title when I do cmd+tab from another app
#
# How to get the title from within kitty:
# kitten @ ls | jq -r '.[] | select(.is_focused) | .tabs[] | select(.is_focused) | .windows[] | select(.is_focused) | .title'
TITLE=""
# Try all kitty sockets until we find the focused window title
for SOCK in /tmp/kitty-*; do
  # Skip if not a socket
  [ -S "$SOCK" ] || continue
  # Query this socket for the focused window title
  T=$(/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:$SOCK" ls 2>/dev/null | jq -r '.[] | select(.is_focused) | .tabs[] | select(.is_focused) | .windows[] | select(.is_focused) | .title' || true)
  # If we got a valid title, use it and stop searching
  if [ -n "$T" ] && [ "$T" != "null" ]; then
    TITLE="$T"
    break
  fi
done

# fallback to app name if no title set
if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
  TITLE="kitty"
fi

# Default the SketchyBar variables when running this script directly
# NAME is the item id to update; INFO is the app icon key
NAME="${NAME:-front_app}"
INFO="${INFO:-kitty}"

sketchybar --set "$NAME" label="$TITLE" icon.background.image="app.$INFO"
