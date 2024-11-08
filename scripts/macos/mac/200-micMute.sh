#!/usr/bin/env bash

# Get the current microphone volume
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

# If volume is less than 60 (including 0), set it to 60
# Otherwise set it to 0
if [[ $MIC_VOLUME -lt 60 ]]; then
  osascript -e 'set volume input volume 60'
else
  osascript -e 'set volume input volume 0'
fi
