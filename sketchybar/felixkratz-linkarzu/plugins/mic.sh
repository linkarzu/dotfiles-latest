#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh

# https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1216899

# echo "" >/tmp/mic.sh.log

source "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"
MIC_NAME_FILE="/tmp/${USER}_mic_name"

# Attempt to get the current input device name
CURRENT_MIC=$(SwitchAudioSource -t input -c)
# echo "CURRENT_MIC=$CURRENT_MIC" >>/tmp/mic.sh.log

# List all input devices
AVAILABLE_INPUTS=$(SwitchAudioSource -a -t input)

# Look for a device name that contains the name of the main mic
PREFERRED_MIC=$(echo "$AVAILABLE_INPUTS" | grep -i "Shure")
# echo "PREFERRED_MIC=$PREFERRED_MIC" >>/tmp/mic.sh.log

if [[ -n "$PREFERRED_MIC" && "$CURRENT_MIC" != "$PREFERRED_MIC" ]]; then
  # Only switch if the current device is not already the main mic
  SwitchAudioSource -t input -s "$PREFERRED_MIC"
  MAIN_MIC_NAME=$(echo "$PREFERRED_MIC" | awk '{print $1}')
else
  # Use the current input device as MIC_NAME
  MAIN_MIC_NAME=$(echo "$CURRENT_MIC" | awk '{print $1}')
fi
# echo "MAIN_MIC_NAME=$MAIN_MIC_NAME" >>/tmp/mic.sh.log

# When no microphone is connected, SwitchAudioSource gives me back random
# characters and sketchybar shows "Warning: Malformed UTF-8 string"
# Validate MIC_NAME as UTF-8, replace invalid sequences with a '?', then compare with original
VALIDATED_MIC_NAME=$(echo "$MAIN_MIC_NAME" | iconv -f UTF-8 -t UTF-8//IGNORE)
# echo "VALIDATED_MIC_NAME=$VALIDATED_MIC_NAME" >>/tmp/mic.sh.log

# I'll be using this in ~/github/dotfiles-latest/scripts/macos/mac/misc/200-micMute.sh
# That file will have something like "Yeti" or "AirPods"
echo "$VALIDATED_MIC_NAME" >"$MIC_NAME_FILE"

# Get the current microphone volume
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')
# echo "MIC_VOLUME=$MIC_VOLUME" >>/tmp/mic.sh.log

MIC_LABEL="$MAIN_MIC_NAME-$MIC_VOLUME"
# echo "MIC_LABEL=$MIC_LABEL" >>/tmp/mic.sh.log

# This comes from an exported variable
# echo "MIC_LEVEL=$MIC_LEVEL" >>/tmp/mic.sh.log

# Check if MIC_NAME is not meaningful
if [[ "$MAIN_MIC_NAME" != "$VALIDATED_MIC_NAME" || -z "$MAIN_MIC_NAME" ]]; then
  # If the mic name is not valid or empty
  sketchybar -m --set mic label="INVALID" icon= icon.color="$YELLOW" label.color="$YELLOW"
else
  # Update SketchyBar with the microphone's name and volume
  if [[ $MIC_VOLUME -eq 0 ]]; then
    sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color="$RED" label.color="$RED"
  elif [[ $MIC_VOLUME -gt 0 && $MIC_VOLUME -lt $MIC_LEVEL ]]; then
    if [[ "$MAIN_MIC_NAME" == Shure* ]]; then
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color="$BLUE" label.color="$BLUE"
    else
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color="$ORANGE" label.color="$ORANGE"
    fi
  elif [[ $MIC_VOLUME -eq $MIC_LEVEL ]]; then
    if [[ "$MAIN_MIC_NAME" == Shure* ]]; then
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color="$BLUE" label.color="$BLUE"
    else
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color="$ORANGE" label.color="$ORANGE"
    fi
  else
    if [[ "$MAIN_MIC_NAME" == Shure* ]]; then
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color="$BLUE" label.color="$BLUE"
    else
      sketchybar -m --set mic label="$MIC_LABEL " icon= icon.color="$ORANGE" label.color="$ORANGE"
    fi
  fi
fi
