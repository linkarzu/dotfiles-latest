#!/usr/bin/env bash

# Get the current microphone volume
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

# If volume is less than 60 (including 0), set it to 60
# Otherwise set it to 0
if [[ $MIC_VOLUME -gt 0 ]]; then
  osascript -e 'set volume input volume 0'
  osascript -e 'display notification "Mic Muted 🔇" with title "Muted 🔴"'
else
  osascript -e 'set volume input volume 60'
  osascript -e 'display notification "Mic Unmuted 🔈" with title "Unmuted 🟢"'
fi
