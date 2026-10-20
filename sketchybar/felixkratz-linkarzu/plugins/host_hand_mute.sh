#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/host_hand_mute.sh
# Mute (on) or unmute (off) every guest of the prepared or live show through vdo.ninja's API, from the
# hand icon's right-click menu. Only the host can undo a mute; guests can't unmute themselves.

sketchybar --set host_hand popup.drawing=off

manager_dir="$HOME/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager/scripts/macos/mac/obs/meeting/py"
python="$manager_dir/.venv/bin/python"
[[ -x "$python" ]] || python=python3
mkdir -p "$HOME/.cache/obs-meeting-manager"
result="$("$python" "$manager_dir/meeting_manager.py" --mute-all-guests "$1" 2>&1 | tee -a "$HOME/.cache/obs-meeting-manager/host-hand.log" | tail -1)"
result="${result#\[?\] }"
/usr/bin/osascript - "$result" <<'APPLESCRIPT'
on run argv
  display notification (item 1 of argv) with title "Guests"
end run
APPLESCRIPT
