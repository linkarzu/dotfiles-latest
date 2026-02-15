#!/bin/sh

# I want SketchyBar to be hidden when certain apps are focused
# Add this here and also check the code added to the sketchybarrc file
# https://github.com/FelixKratz/SketchyBar/discussions/349#discussioncomment-5535282
case "$INFO" in
"DaVinci Resolve" | "VirtualBox" | "remote-viewer")
  sketchybar --bar hidden=on
  ;;
*) sketchybar --bar hidden=off ;;
esac
