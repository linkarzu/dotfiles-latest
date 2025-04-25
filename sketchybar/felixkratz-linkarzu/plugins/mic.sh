#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh

# https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1216899

source "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"
MIC_NAME_FILE="/tmp/${USER}_mic_name"

# Attempt to get the current input device name
CURRENT_MIC=$(SwitchAudioSource -t input -c)

# List all input devices
AVAILABLE_INPUTS=$(SwitchAudioSource -a -t input)

# Look for a device name that contains "Yeti"
YETI_DEVICE=$(echo "$AVAILABLE_INPUTS" | grep -i "Yeti")

if [[ -n "$YETI_DEVICE" && "$CURRENT_MIC" != "$YETI_DEVICE" ]]; then
  # Only switch if the current device is not already Yeti
  SwitchAudioSource -t input -s "$YETI_DEVICE"
  MIC_NAME=$(echo "$YETI_DEVICE" | awk '{print $1}')
else
  # Use the current input device as MIC_NAME
  MIC_NAME=$(echo "$CURRENT_MIC" | awk '{print $1}')
fi

# When no microphone is connected, SwitchAudioSource gives me back random
# characters and sketchybar shows "Warning: Malformed UTF-8 string"
# Validate MIC_NAME as UTF-8, replace invalid sequences with a '?', then compare with original
VALIDATED_MIC_NAME=$(echo "$MIC_NAME" | iconv -f UTF-8 -t UTF-8//IGNORE)

# I'll be using this in ~/github/dotfiles-latest/scripts/macos/mac/misc/200-micMute.sh
# That file will have something like "Yeti" or "AirPods"
echo "$VALIDATED_MIC_NAME" >"$MIC_NAME_FILE"

# Get the current microphone volume
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

MIC_LABEL="$MIC_NAME-$MIC_VOLUME"

# Check if MIC_NAME is not meaningful
if [[ "$MIC_NAME" != "$VALIDATED_MIC_NAME" || -z "$MIC_NAME" ]]; then
  # If the mic name is not valid or empty
  sketchybar -m --set mic label="" icon= icon.color=$YELLOW label.color=$YELLOW
else
  # Update SketchyBar with the microphone's name and volume
  if [[ $MIC_VOLUME -eq 0 ]]; then
    sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color=$RED label.color=$RED
  elif [[ $MIC_VOLUME -gt 0 && $MIC_VOLUME -lt 90 ]]; then
    if [[ "$MIC_NAME" == Yeti* ]]; then
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color=$BLUE label.color=$BLUE
    else
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color=$ORANGE label.color=$ORANGE
    fi
  elif [[ $MIC_VOLUME -eq 90 ]]; then
    if [[ "$MIC_NAME" == Yeti* ]]; then
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color=$BLUE label.color=$BLUE
    else
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color=$ORANGE label.color=$ORANGE
    fi
  fi
fi
