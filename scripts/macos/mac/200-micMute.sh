#!/usr/bin/env bash

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

# Get the current microphone volume
MIC_STATUS=$(osascript -e 'input volume of (get volume settings)')

# Check if MIC_STATUS is a number
if [[ "$MIC_STATUS" =~ ^[0-9]+$ ]]; then
  # If volume is less than 60 (including 0), set it to 60
  if [ "$MIC_STATUS" -gt 0 ]; then
    osascript -e 'set volume input volume 0'
    # osascript -e 'display notification "Mic Muted 🔇" with title "Muted 🔴"'
    ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
    # Otherwise set it to 0
  else
    osascript -e 'set volume input volume 60'
    # osascript -e 'display notification "Mic Unmuted 🔈" with title "Unmuted 🟢"'
    ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
  fi
else
  osascript -e 'display notification "Make sure its connected" with title "Mic not detected"'
fi
