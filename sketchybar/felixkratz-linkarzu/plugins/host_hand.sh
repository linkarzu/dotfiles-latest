#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/host_hand.sh
# Shows my hand state for the prepared or live show and toggles it on click through
# meeting_manager.py --toggle-host-hand (the same action as Enter-O-H and the QAT).
# Right click opens the mute menu (host_hand_mute.sh).

source "$CONFIG_DIR/colors.sh"

active="$HOME/.cache/obs-meeting-manager/active-livestream.json"
manager_dir="$HOME/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager/scripts/macos/mac/obs/meeting/py"

if [[ "$SENDER" == "mouse.exited.global" ]]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

if [[ "$SENDER" == "mouse.clicked" && "$BUTTON" == "right" ]]; then
  sketchybar --set "$NAME" popup.drawing=toggle
  exit 0
fi

if [[ "$SENDER" == "mouse.clicked" ]]; then
  python="$manager_dir/.venv/bin/python"
  [[ -x "$python" ]] || python=python3
  mkdir -p "$HOME/.cache/obs-meeting-manager"
  "$python" "$manager_dir/meeting_manager.py" --toggle-host-hand >>"$HOME/.cache/obs-meeting-manager/host-hand.log" 2>&1
fi

# Same rule as meeting_manager's is_open_terminal_event / is_guest_show_event: Open Terminal
# records the dynamic collection; a guest show has a meeting and guests.
state="hidden"
if [[ -f "$active" ]]; then
  event="$(jq -r '.eventPath // empty' "$active" 2>/dev/null)"
  if [[ -n "$event" && -f "$event" ]]; then
    state="$(jq -r '
      if (.obs.sceneCollection == "4-guest-livestream-dynamic")
         or ((.meeting | type) == "object" and ((.guestCount // 0) > 0))
      then (if .hostHand.raised == true then "up" else "down" end)
      else "hidden" end' "$event" 2>/dev/null)"
  fi
fi

case "$state" in
up) sketchybar --set "$NAME" drawing=on icon.color="$YELLOW" ;;
down) sketchybar --set "$NAME" drawing=on icon.color="$GREY" ;;
*) sketchybar --set "$NAME" drawing=off popup.drawing=off ;;
esac
