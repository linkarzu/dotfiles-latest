# https://github.com/FelixKratz/SketchyBar/discussions/12

#!/bin/bash

mic=(
	update_freq=3
	script="$PLUGIN_DIR/mic.sh"
	click_script="$PLUGIN_DIR/mic_click.sh"
)

sketchybar --add item mic right \
	--set mic "${mic[@]}" \
	--subscribe mic volume_change
