#!/usr/bin/env bash

source "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"

# This script is executed from karabiner, but in karabiner docs:
# https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/shell-command/
# The very limited environment variables are passed to the command, $HOME, $UID, $USER, etc.
# Export environment variables in shell_command if your commands depend them.
#
# If you don't do this, the script won't find yabai or jq or any other apps in
# the /opt/homebrew/bin dir
#
# In this case, I had to add this line, otherwise it would run the sketchybar
# script below mic.sh
export PATH="/opt/homebrew/bin:$PATH"
MIC_NAME_FILE="/tmp/${USER}_mic_name"
MIC_NAME=$(cat "$MIC_NAME_FILE" 2>/dev/null)

# Get the current microphone volume
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

# Get current mic as swill switch to it after muting all mics
CURRENT_MIC=$(SwitchAudioSource -t input -c)

# Check if MIC_VOLUME is a number
if [[ "$MIC_VOLUME" =~ ^[0-9]+$ ]]; then
  # If volume is less than 60 (including 0), set it to 60
  if [ "$MIC_VOLUME" -gt 0 ]; then
    sketchybar -m --set mic label="$MIC_NAME-0 " icon= icon.color=$RED label.color=$RED
    # Mute all microphones, not onlyt he active one
    while IFS= read -r device; do
      # Skip the iPhone microphone
      if [[ "$device" == *iPhone* ]]; then
        continue
      fi
      SwitchAudioSource -t input -s "$device"
      osascript -e "set volume input volume 0"
    done < <(SwitchAudioSource -t input -a | awk -v ORS="\n" '1')
    # Restore the original microphone
    SwitchAudioSource -t input -s "$CURRENT_MIC"
    # osascript -e 'display notification "Mic Muted 🔇" with title "Muted 🔴"'
    ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
    # Otherwise set it to 0
  else
    if [[ "$MIC_NAME" == Yeti* ]]; then
      sketchybar -m --set mic label="$MIC_NAME-60 " icon= icon.color=$BLUE label.color=$BLUE
    else
      sketchybar -m --set mic label="$MIC_NAME-60 " icon= icon.color=$ORANGE label.color=$ORANGE
    fi
    # Unmute all microphones, not onlyt he active one
    while IFS= read -r device; do
      # Skip the iPhone microphone
      if [[ "$device" == *iPhone* ]]; then
        continue
      fi
      SwitchAudioSource -t input -s "$device"
      osascript -e "set volume input volume 60"
    done < <(SwitchAudioSource -t input -a | awk -v ORS="\n" '1')
    # Restore the original microphone
    SwitchAudioSource -t input -s "$CURRENT_MIC"
    # osascript -e 'display notification "Mic Unmuted 🔈" with title "Unmuted 🟢"'
    ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
  fi
else
  osascript -e 'display notification "Make sure its connected" with title "Mic not detected"'
fi
