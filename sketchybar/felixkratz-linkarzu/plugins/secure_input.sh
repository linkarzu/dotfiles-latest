#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/secure_input.sh
# Shows which app holds macOS Secure Input, from kCGSSessionSecureInputPID, which is only present
# while it's on. -d 1 stops at the root entry that has the key: 12ms against 1.7s for the whole
# registry, this runs every 2 seconds.
#
# Also logs every change to ~/.cache/sketchybar/secure-input.log to find out why it gets stuck:
# ON with how long the holder has been running and the focused window, FRONT each time the
# frontmost app changes while it's on, and OFF with how long it lasted. macOS doesn't log any of it.

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
log_file="$cache_dir/secure-input.log"
state_file="$cache_dir/secure-input-state"
mkdir -p "$cache_dir"

log_event() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >>"$log_file"
}

front_app() {
  lsappinfo info -only name "$(lsappinfo front)" | sed -e 's/^"LSDisplayName"="//' -e 's/"$//'
}

pid="$(ioreg -l -w 0 -d 1 | grep -o '"kCGSSessionSecureInputPID"=[0-9]*' | head -1 | grep -o '[0-9]*$')"

if [[ -z "$pid" ]]; then
  if [[ -f "$state_file" ]]; then
    {
      read -r _
      read -r since
      read -r _
      read -r holder
    } <"$state_file"
    log_event "OFF holder=\"$holder\" after=$(($(date +%s) - since))s front=\"$(front_app)\""
    rm -f "$state_file"
  fi
  sketchybar --set "$NAME" drawing=off --set "$NAME.app" drawing=off
  exit 0
fi

app="$(ps -o comm= -p "$pid")"
app="${app##*/}"
front="$(front_app)"

last_pid=""
if [[ -f "$state_file" ]]; then
  {
    read -r last_pid
    read -r since
    read -r last_front
  } <"$state_file"
fi

if [[ "$pid" != "$last_pid" ]]; then
  since="$(date +%s)"
  title="$(yabai -m query --windows --window 2>/dev/null | jq -r '.title // empty' 2>/dev/null)"
  log_event "ON holder=\"$app\" pid=$pid holder_running=$(ps -o etime= -p "$pid" | tr -d ' ') front=\"$front\" title=\"$title\""
elif [[ "$front" != "$last_front" ]]; then
  log_event "FRONT app=\"$front\" holder=\"$app\""
fi
printf '%s\n%s\n%s\n%s\n' "$pid" "$since" "$front" "$app" >"$state_file"

# Capped so a long name stays in the column of the "Secure Input" line above it.
app="${app:0:11}"
sketchybar --set "$NAME" drawing=on --set "$NAME.app" drawing=on label="${app:-PID $pid}"
