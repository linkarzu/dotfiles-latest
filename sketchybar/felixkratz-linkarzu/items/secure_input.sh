#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/secure_input.sh
# Warns while macOS Secure Input is on and names the app holding it. skhd can't see keys during
# Secure Input, so bindings stop working and their chords reach the focused app instead.
# Hidden the rest of the time.

secure_input=(
  updates=on
  update_freq=2
  drawing=off
  icon="󰌾"
  icon.font="$FONT:Bold:15.0"
  icon.color=$RED
  label.color=$RED
  label.padding_right=6
  script="$PLUGIN_DIR/secure_input.sh"
)

sketchybar --add item secure_input right \
  --set secure_input "${secure_input[@]}" \
  --subscribe secure_input system_woke
