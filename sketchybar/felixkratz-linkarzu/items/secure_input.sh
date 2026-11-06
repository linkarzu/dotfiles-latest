#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/secure_input.sh
# Warns while macOS Secure Input is on and names the app holding it. skhd can't see keys during
# Secure Input, so bindings stop working and their chords reach the focused app instead.
# Hidden the rest of the time. Two lines in a shared column, like the calendar, so it fits on a
# full bar.

secure_input_width=50

secure_input=(
  updates=on
  update_freq=2
  drawing=off
  label="Secure Input"
  label.font="$FONT:Black:8.0"
  label.color=$RED
  label.width=$secure_input_width
  label.align=center
  label.y_offset=5
  label.padding_left=0
  label.padding_right=0
  width=0
  icon.drawing=off
  script="$PLUGIN_DIR/secure_input.sh"
)

# Carries the lock too, centered on both lines to the left of the column.
secure_input_icon_width=12

secure_input_app=(
  drawing=off
  icon="󰌾"
  icon.font="$FONT:Bold:15.0"
  icon.color=$RED
  icon.width=$secure_input_icon_width
  icon.padding_left=0
  icon.padding_right=0
  label.font="$FONT:Black:8.0"
  label.color=$RED
  label.width=$secure_input_width
  label.align=center
  label.y_offset=-5
  label.padding_left=0
  label.padding_right=0
  padding_left=12
  width=$((secure_input_width + secure_input_icon_width))
)

sketchybar --add item secure_input right \
  --set secure_input "${secure_input[@]}" \
  --subscribe secure_input system_woke \
  \
  --add item secure_input.app right \
  --set secure_input.app "${secure_input_app[@]}"
