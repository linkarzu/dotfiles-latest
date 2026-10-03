#!/usr/bin/env bash

source "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"

# window_focused and space_changed fire together, so runs are serialized.
# Otherwise each could start its own borders process, and a stale run could
# finish last with the wrong color.
lock="${TMPDIR:-/tmp}/update_border_color.lock"
for _ in {1..50}; do
  mkdir "$lock" 2>/dev/null && break
  # A lock older than 5 seconds belongs to a run that died
  if [[ -n "$(find "$lock" -maxdepth 0 -mtime +5s 2>/dev/null)" ]]; then
    rmdir "$lock" 2>/dev/null
  fi
  sleep 0.05
done
trap 'rmdir "$lock" 2>/dev/null' EXIT

set_border() {
  local active_color="$1"
  if pgrep -x borders >/dev/null; then
    # Updates the running instance and exits
    borders active_color="$active_color"
  else
    borders hidpi=on width=5.0 inactive_color=0x00000000 active_color="$active_color" &
    # Give it time to register before the next run looks for it
    sleep 0.3
  fi
}

# update border color only for BSP spaces; invisible elsewhere
if ! space_json=$(timeout 5 yabai -m query --spaces --space); then
  set_border 0x00000000
  exit 1
fi
layout=$(printf '%s' "$space_json" | jq -r '.type')

if [[ "$layout" != "bsp" ]]; then
  set_border 0x00000000
  exit 0
fi

# layout is BSP: count only standard windows you can see. This leaves out
# sticky overlays like the HEX dictation indicator (AXSystemDialog) and kitty
# QAT windows (AXUnknown, Hammerspoon's qat_border.lua draws their border).
index=$(printf '%s' "$space_json" | jq '.index')
n=$(timeout 5 yabai -m query --windows --space "$index" | jq '[.[] |
  select(.subrole == "AXStandardWindow"
    and (."is-minimized" | not)
    and (."is-hidden" | not)
    and (."is-sticky" | not))] | length')

if [[ ${n:-0} -le 1 ]]; then
  set_border 0x00000000
else
  set_border "$GREEN"
fi
