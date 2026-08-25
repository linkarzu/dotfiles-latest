#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/yabai/yabai_restart.sh
# ~/github/dotfiles-latest/yabai/yabai_restart.sh

# This script is executed from karabiner, but in karabiner docs:
# https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/shell-command/
# The very limited environment variables are passed to the command, $HOME, $UID, $USER, etc.
# Export environment variables in shell_command if your commands depend them.
#
# If you don't do this, the script won't find yabai or jq or any other apps in
# the /opt/homebrew/bin dir
export PATH="/opt/homebrew/bin:$PATH"

config_ready_marker="${YABAI_CONFIG_READY_MARKER:-/tmp/yabai_linkarzu.config-ready}"
restart_log="${YABAI_RESTART_LOG:-/tmp/yabai_linkarzu.restart.log}"
ready_timeout_seconds="${YABAI_RESTART_READY_TIMEOUT_SECONDS:-5}"
poll_seconds="${YABAI_RESTART_POLL_SECONDS:-0.1}"
yabai_bin="${YABAI_BIN:-yabai}"
timeout_bin="${TIMEOUT_BIN:-timeout}"
osascript_bin="${OSASCRIPT_BIN:-osascript}"
restart_started_at="$(/usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time')"

log_restart() {
  local status="$1"
  local details="$2"
  local timing
  timing="$(
    /usr/bin/perl -MPOSIX=strftime -MTime::HiRes=time -e '
      $now = time;
      printf "%s elapsed_ms=%.1f", strftime("%Y-%m-%dT%H:%M:%SZ", gmtime($now)), 1000 * ($now - $ARGV[0]);
    ' "$restart_started_at"
  )"
  printf '%s phase=yabai-restart status=%s %s\n' "$timing" "$status" "$details" >>"$restart_log"
}

notify_failure() {
  "$osascript_bin" -e 'display notification "Yabai restart failed; see /tmp/yabai_linkarzu.restart.log" with title "Yabai"' || true
}

log_restart "start" "expected=config-complete-and-two-consecutive-window-queries"
if ! rm -f "$config_ready_marker"; then
  log_restart "failure" "operation=clear-config-ready-marker"
  notify_failure
  exit 1
fi

"$timeout_bin" 5 "$yabai_bin" --restart-service
exit_status=$?
if ((exit_status != 0)); then
  log_restart "failure" "operation=restart-command exit_status=$exit_status"
  notify_failure
  exit "$exit_status"
fi
log_restart "success" "operation=restart-command observed=command-returned"

deadline=$((SECONDS + ready_timeout_seconds))
attempt=0
consecutive_successes=0
last_observed="query-not-attempted"
while ((SECONDS < deadline)); do
  ((attempt += 1))
  if [[ ! -f "$config_ready_marker" ]]; then
    consecutive_successes=0
    last_observed="config-incomplete"
  elif "$timeout_bin" 2 "$yabai_bin" -m query --windows >/dev/null 2>&1; then
    ((consecutive_successes += 1))
    last_observed="config-ready-query-success-$consecutive_successes"
    if ((consecutive_successes == 2)); then
      log_restart "success" "attempt=$attempt observed=config-complete-and-two-consecutive-window-queries"
      if ! "$osascript_bin" -e 'display notification "Yabai restarted" with title "Yabai"'; then
        log_restart "failure" "operation=success-notification"
        exit 1
      fi
      exit 0
    fi
  else
    consecutive_successes=0
    last_observed="query-unavailable"
  fi
  sleep "$poll_seconds"
done

log_restart "timeout" "attempt=$attempt observed=$last_observed timeout_seconds=$ready_timeout_seconds"
notify_failure
exit 1

# Wait a few seconds after restarting yabai, or the apps will restart too early
# I think this causes the apps not to show with my transparent apps
# sleep 1

# # Restart the apps in apps_transp_ignore to apply the settings
# # Convert the string to an array, properly handling spaces in app names
# # Remove parentheses and split on |
# IFS='|' read -ra apps <<<"$(echo "$apps_transp_ignore" | tr -d '()')"
#
# # Iterate through the array
# for app in "${apps[@]}"; do
#   # Trim leading/trailing whitespace
#   app=$(echo "$app" | xargs)
#   pkill "$app"
#   sleep 1
#   open -a "$app"
#   sleep 1
# done

# IFS='|' read -ra apps <<<"$(echo "$apps_scratchpad" | tr -d '()')"
#
# # Iterate through the array
# for app in "${apps[@]}"; do
#   # Trim leading/trailing whitespace
#   app=$(echo "$app" | xargs)
#   pkill "$app"
#   sleep 0.7
#   open -a "$app"
#   sleep 0.7
# done

# # After yabai is restarted, I want kitty to be moved to a specific position on
# # the screen as it will be my "sticky notes", I also set its size
# ~/github/dotfiles-latest/yabai/positions/kitty-pos.sh

# # Focus Ghostty window before restarting Neovim
# ghostty_window_id=$(yabai -m query --windows | jq '.[] | select(.app == "Ghostty") | .id' | head -n 1)
# if [[ -n "$ghostty_window_id" ]]; then
#   yabai -m window --focus "$ghostty_window_id"
# fi
#
# # Restart Neovim
# open "btt://execute_assigned_actions_for_trigger/?uuid=481BDF1F-D0C3-4B5A-94D2-BD3C881FAA6F"
#
