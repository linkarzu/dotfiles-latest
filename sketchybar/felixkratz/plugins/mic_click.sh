#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/plugins/mic_click.sh

source "$CONFIG_DIR/colors.sh"

# Attempt to get the current input device name
MIC_NAME=$(SwitchAudioSource -t input -c)
# I just want the first word, in case it's too long
MIC_NAME=$(echo $MIC_NAME | awk '{print $1}')

# When no microphone is connected, SwitchAudioSource gives me back random
# characters and sketchybar shows "Warning: Malformed UTF-8 string"
# Validate MIC_NAME as UTF-8, replace invalid sequences with a '?', then compare with original
VALIDATED_MIC_NAME=$(echo "$MIC_NAME" | iconv -f UTF-8 -t UTF-8//IGNORE)

# Get the current microphone volume
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

# Check if MIC_NAME is not meaningful
if [[ "$MIC_NAME" != "$VALIDATED_MIC_NAME" || -z "$MIC_NAME" ]]; then
	# If the mic name is not valid or empty
	sketchybar -m --set mic label="" icon=
else
	# Update SketchyBar with the microphone's name and volume
	if [[ $MIC_VOLUME -lt 100 ]]; then
		osascript -e 'set volume input volume 100'
		sketchybar -m --set mic label="$MIC_NAME 100" icon= icon.color=$WHITE label.color=$WHITE
	elif [[ $MIC_VOLUME -gt 0 ]]; then
		osascript -e 'set volume input volume 0'
		sketchybar -m --set mic label="$MIC_NAME 0" icon= icon.color=$RED label.color=$RED
	fi
fi
