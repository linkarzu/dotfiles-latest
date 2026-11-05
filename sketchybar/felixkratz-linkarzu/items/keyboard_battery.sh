#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/keyboard_battery.sh
# Battery level of the left and right halves of the connected Forager or Toucan,
# left of the disk graph. ZMK updates the levels slowly and reading them is cheap
# for the keyboard.

# Right click any of these items for the details popup, which also has the Magic
# Mouse. Opening it reads the levels again, and so does its Refresh row.
KEYBOARD_CLICK_SCRIPT="$PLUGIN_DIR/usage_click.sh keyboard.frame; sketchybar --trigger keyboard_battery_update"

# Shift zero-width labels back over the frame. Less than the graphs' overlay: a
# plain item's right padding already counts, a graph's doesn't.
keyboard_frame_padding_right=4
# Wider than the graphs so the keyboard name and the layer icon fit.
keyboard_width=36
keyboard_overlay_padding=$((-keyboard_width + keyboard_frame_padding_right))
keyboard_title_font="$FONT:Heavy:7"
keyboard_level_font="$FONT:Heavy:8"

# The plugin starts this again, see plugins/keyboard_battery.sh.
pkill -f '/keyboard-battery --watch-layer$'

# Filled in by that process: the macOS or Windows logo for the keyboard's layer.
keyboard_mode=(
  drawing=off
  label.font="$FONT:Bold:8"
  label=""
  label.y_offset=9
  label.width=$keyboard_width
  label.align=left
  label.padding_left=2
  label.padding_right=0
  padding_right=$keyboard_overlay_padding
  width=0
  icon.drawing=off
  click_script="$KEYBOARD_CLICK_SCRIPT"
)

keyboard_frame=(
  width=$keyboard_width
  padding_right=$keyboard_frame_padding_right
  drawing=off
  updates=on
  update_freq=300
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  background.border_width=1
  background.border_color=$USAGE_GRAPH_BORDER_COLOR
  background.corner_radius=0
  popup.align=center
  popup.height=20
  click_script="$KEYBOARD_CLICK_SCRIPT"
  script="$PLUGIN_DIR/keyboard_battery.sh"
)

keyboard_title=(
  drawing=off
  label.font="$keyboard_title_font"
  label="--"
  label.y_offset=9
  label.width=$keyboard_width
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$keyboard_overlay_padding
  width=0
  icon.drawing=off
  click_script="$KEYBOARD_CLICK_SCRIPT"
)

keyboard_left=(
  drawing=off
  label.font="$keyboard_level_font"
  label="L --"
  label.y_offset=0
  label.width=$keyboard_width
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$keyboard_overlay_padding
  width=0
  icon.drawing=off
  click_script="$KEYBOARD_CLICK_SCRIPT"
)

keyboard_right=(
  drawing=off
  label.font="$keyboard_level_font"
  label="R --"
  label.y_offset=-9
  label.width=$keyboard_width
  label.align=right
  label.padding_left=0
  label.padding_right=2
  padding_right=$keyboard_overlay_padding
  width=0
  icon.drawing=off
  click_script="$KEYBOARD_CLICK_SCRIPT"
)

keyboard_popup_row=(
  icon.font="$FONT:Bold:12"
  icon.width=140
  icon.padding_left=10
  label.font="$FONT:Semibold:12"
  label.width=170
  label.align=right
  label.padding_right=10
  click_script="sketchybar --set keyboard.frame popup.drawing=off"
)

keyboard_popup_header=(
  "${keyboard_popup_row[@]}"
  icon.color=$GREY
  label.color=$GREY
)

keyboard_popup_refresh=(
  "${keyboard_popup_row[@]}"
  click_script="sketchybar --trigger keyboard_battery_update"
)

sketchybar --add event keyboard_battery_update \
  --add item keyboard.frame right \
  --set keyboard.frame "${keyboard_frame[@]}" \
  --subscribe keyboard.frame system_woke keyboard_battery_update \
  \
  --add item keyboard.title right \
  --set keyboard.title "${keyboard_title[@]}" \
  \
  --add item keyboard.mode right \
  --set keyboard.mode "${keyboard_mode[@]}" \
  \
  --add item keyboard.left right \
  --set keyboard.left "${keyboard_left[@]}" \
  \
  --add item keyboard.right right \
  --set keyboard.right "${keyboard_right[@]}"

# Popup rows are filled in by the plugin on every update, the Layer row by the
# process that fills in keyboard.mode.
sketchybar --add item keyboard.popup.layer popup.keyboard.frame \
  --set keyboard.popup.layer "${keyboard_popup_row[@]}" icon="Layer" label="unknown" label.color=$GREY \
  \
  --add item keyboard.popup.header popup.keyboard.frame \
  --set keyboard.popup.header "${keyboard_popup_header[@]}" icon="Device" label="Level · time left" \
  \
  --add item keyboard.popup.left popup.keyboard.frame \
  --set keyboard.popup.left "${keyboard_popup_row[@]}" icon="Left half" label="--" \
  \
  --add item keyboard.popup.right popup.keyboard.frame \
  --set keyboard.popup.right "${keyboard_popup_row[@]}" icon="Right half" label="--" \
  \
  --add item keyboard.popup.mouse popup.keyboard.frame \
  --set keyboard.popup.mouse "${keyboard_popup_row[@]}" icon="Magic Mouse" label="--" \
  \
  --add item keyboard.popup.charged_header popup.keyboard.frame \
  --set keyboard.popup.charged_header "${keyboard_popup_header[@]}" icon="Last charged" label="" \
  \
  --add item keyboard.popup.left_charged popup.keyboard.frame \
  --set keyboard.popup.left_charged "${keyboard_popup_row[@]}" icon="Left half" label="--" \
  \
  --add item keyboard.popup.right_charged popup.keyboard.frame \
  --set keyboard.popup.right_charged "${keyboard_popup_row[@]}" icon="Right half" label="--" \
  \
  --add item keyboard.popup.mouse_charged popup.keyboard.frame \
  --set keyboard.popup.mouse_charged "${keyboard_popup_row[@]}" icon="Magic Mouse" label="--" \
  \
  --add item keyboard.popup.updated popup.keyboard.frame \
  --set keyboard.popup.updated "${keyboard_popup_header[@]}" icon="Updated" label="--" \
  \
  --add item keyboard.popup.refresh popup.keyboard.frame \
  --set keyboard.popup.refresh "${keyboard_popup_refresh[@]}" icon="Refresh" label="󰑓"
