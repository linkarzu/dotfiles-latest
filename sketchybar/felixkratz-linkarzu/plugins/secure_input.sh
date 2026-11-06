#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/secure_input.sh
# Shows which app holds macOS Secure Input, from kCGSSessionSecureInputPID, which is only present
# while it's on. -d 1 stops at the root entry that has the key: 12ms against 1.7s for the whole
# registry, this runs every 2 seconds.

pid="$(ioreg -l -w 0 -d 1 | grep -o '"kCGSSessionSecureInputPID"=[0-9]*' | head -1 | grep -o '[0-9]*$')"

if [[ -z "$pid" ]]; then
  sketchybar --set "$NAME" drawing=off --set "$NAME.app" drawing=off
  exit 0
fi

app="$(ps -o comm= -p "$pid")"
app="${app##*/}"
# Capped so a long name stays in the column of the "Secure Input" line above it.
app="${app:0:11}"
sketchybar --set "$NAME" drawing=on --set "$NAME.app" drawing=on label="${app:-PID $pid}"
