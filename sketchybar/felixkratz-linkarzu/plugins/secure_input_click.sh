#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/secure_input_click.sh
# Right click kills the app holding Secure Input, only the holder can turn it off. TERM first so
# the app exits cleanly, KILL if it's still running after 5 seconds. Only apps in /Applications:
# killing something like loginwindow would log me out. Logs the result next to the plugin's log.

[[ "$BUTTON" == "right" ]] || exit 0

log_file="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/secure-input.log"

log_event() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >>"$log_file"
}

holder_pid() {
  ioreg -l -w 0 -d 1 | grep -o '"kCGSSessionSecureInputPID"=[0-9]*' | head -1 | grep -o '[0-9]*$'
}

pid="$(holder_pid)"
[[ -n "$pid" ]] || exit 0

path="$(ps -o comm= -p "$pid")"
case "$path" in
/Applications/*) ;;
*)
  log_event "RIGHT-CLICK pid=$pid path=\"$path\" result=refused-outside-applications"
  exit 0
  ;;
esac

kill -TERM "$pid"
signal=TERM
for _ in 1 2 3 4 5; do
  sleep 1
  kill -0 "$pid" 2>/dev/null || break
done
if kill -0 "$pid" 2>/dev/null; then
  kill -KILL "$pid"
  signal=KILL
  sleep 1
fi

log_event "RIGHT-CLICK holder=\"${path##*/}\" pid=$pid signal=$signal result=$([[ -z "$(holder_pid)" ]] && echo released || echo still-on)"
