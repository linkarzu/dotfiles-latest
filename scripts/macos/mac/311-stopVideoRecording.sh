#!/usr/bin/env bash

set -euo pipefail

export PATH="/opt/homebrew/bin:$PATH"
dotfiles_dir="$HOME/github/dotfiles-latest"
skhdrc="$dotfiles_dir/skhd/skhdrc"
recording_mode_marker="$HOME/.cache/obs-meeting-manager/recording-mode"
timer_pid_file="/tmp/sketchybar_timer.pid"
timer_ready_file="/tmp/sketchybar_timer.ready"

log_step() {
  local step="$1"
  local status="$2"
  shift 2
  printf 'phase=cleanup step=%s status=%s%s\n' "$step" "$status" "${*:+ $*}"
}

wait_for_process_absent() {
  local label="$1"
  local pattern="$2"
  local deadline=$((SECONDS + 5))
  while pgrep -f "$pattern" >/dev/null 2>&1; do
    if ((SECONDS >= deadline)); then
      log_step support-app failure "app=$label process_present=true"
      return 1
    fi
    sleep 0.2
  done
  log_step support-app success "app=$label process_present=false"
}

log_step audio-output start 'expected="MacBook Pro Speakers"'
SwitchAudioSource -t output -s "MacBook Pro Speakers"
current_audio_output="$(SwitchAudioSource -c -t output)"
if [[ "$current_audio_output" != "MacBook Pro Speakers" ]]; then
  log_step audio-output failure "observed=$(printf '%q' "$current_audio_output")"
  exit 1
fi
log_step audio-output success 'observed="MacBook Pro Speakers"'

log_step recording-ui start 'expected=font-15 width-80 live-update'
"$dotfiles_dir/scripts/macos/mac/misc/553-applyRecordingUi.sh" 15 80
log_step recording-ui success 'font=15 width=80'

log_step dnd start 'expected=initial-state-restored'
"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" recording-off
log_step dnd success 'initial_state_restored=true'

rm -f "${TMPDIR:-/tmp}/sketchybar-streaming-16-minute-reminder"
"$HOME/github/scripts-public/macos/mac/310-bannerOff.sh"

support_apps=(
  'BetterDisplay|/BetterDisplay.app/Contents/'
  'KeyCastr|/KeyCastr.app/Contents/'
  'Brave_Browser|/Brave Browser.app/Contents/'
  'KofiAlerts|/KofiAlerts.app/Contents/MacOS/app_mode_loader'
  'StreamElements|/StreamElements.app/Contents/MacOS/app_mode_loader'
  'TTS|/TTS.app/Contents/MacOS/app_mode_loader'
)
for entry in "${support_apps[@]}"; do
  label="${entry%%|*}"
  pattern="${entry#*|}"
  log_step support-app start "app=$label expected=process-absent"
  pkill -f "$pattern" 2>/dev/null || true
  wait_for_process_absent "$label" "$pattern"
done

brave_audio_pid_file="${TMPDIR:-/tmp}/obs-brave-audio-selector.pid"
if [[ -f "$brave_audio_pid_file" ]]; then
  brave_audio_pid="$(<"$brave_audio_pid_file")"
  brave_audio_command="$(ps -p "$brave_audio_pid" -o command= 2>/dev/null || true)"
  if [[ "$brave_audio_command" == *"315-fixObsAudio.sh --wait"* ]]; then
    log_step audio-watcher start "pid=$brave_audio_pid expected=process-absent"
    kill "$brave_audio_pid" 2>/dev/null || true
    deadline=$((SECONDS + 5))
    while kill -0 "$brave_audio_pid" 2>/dev/null; do
      if ((SECONDS >= deadline)); then
        log_step audio-watcher failure "pid=$brave_audio_pid process_present=true"
        exit 1
      fi
      sleep 0.2
    done
    log_step audio-watcher success "pid=$brave_audio_pid process_present=false"
  fi
  rm -f "$brave_audio_pid_file"
fi
if [[ -e "$brave_audio_pid_file" ]]; then
  log_step audio-watcher failure 'pid_file_present=true'
  exit 1
fi
log_step audio-watcher success 'pid_file_present=false'

# osascript -e 'tell application "DisplayLink Manager" to quit'

# Keep the calendar format unchanged when recording stops.
# sed -i '' "s|date '+%a %y/%m/%d'|date '+%a %y/%m/%d %H:%M'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"

# Restore the work hotkey to the exact state recorded before preparation.
log_step recording-mode start 'expected=initial-hotkey-state marker-absent'
expected_hotkey_line=""
if [[ -f "$recording_mode_marker" ]]; then
  marker_state="$(<"$recording_mode_marker")"
  case "$marker_state" in
  hotkey_initial=enabled)
    sed -i '' 's|^# cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
    expected_hotkey_line='cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh'
    ;;
  hotkey_initial=disabled)
    sed -i '' 's|^cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
    expected_hotkey_line='# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh'
    ;;
  *)
    log_step recording-mode failure 'hotkey_initial_state=invalid'
    exit 1
    ;;
  esac
  skhd -r
  grep -Fqx "$expected_hotkey_line" "$skhdrc" || {
    log_step recording-mode failure 'hotkey_restored=false'
    exit 1
  }
fi
log_step recording-mode success 'hotkey_initial_state_restored=true recovery_marker_preserved=true'

log_step yabai-restart start 'expected=query-ready'
"$HOME/github/dotfiles-latest/yabai/yabai_restart.sh"
deadline=$((SECONDS + 15))
while ! yabai -m query --windows >/dev/null 2>&1; do
  if ((SECONDS >= deadline)); then
    log_step yabai-restart failure 'query_ready=false'
    exit 1
  fi
  sleep 0.25
done
log_step yabai-restart success 'query_ready=true'

kitty_id="$(yabai -m query --windows | jq -r '[.[] | select(.app == "kitty")] | first.id // empty')"
if [[ -n "$kitty_id" ]]; then
  yabai -m window --focus "$kitty_id"
fi

timer_pid=""
if [[ -s "$timer_pid_file" ]]; then
  timer_pid="$(<"$timer_pid_file")"
fi
log_step recording-timer start 'expected=process-absent pid-file-absent'
python3 "$dotfiles_dir/sketchybar/felixkratz-linkarzu/plugins/timer.py" stop
if [[ -n "$timer_pid" ]] && kill -0 "$timer_pid" 2>/dev/null; then
  timer_command="$(ps -p "$timer_pid" -o command= 2>/dev/null || true)"
  if [[ "$timer_command" == *"timer.py"* ]]; then
    log_step recording-timer failure "pid=$timer_pid process_present=true"
    exit 1
  fi
fi
if [[ -e "$timer_pid_file" ]]; then
  log_step recording-timer failure 'pid_file_present=true'
  exit 1
fi
if [[ -e "$timer_ready_file" ]]; then
  log_step recording-timer failure 'ready_file_present=true'
  exit 1
fi
log_step recording-timer success 'process_present=false pid_file_present=false ready_file_present=false'
rm -f "$recording_mode_marker"
if [[ -e "$recording_mode_marker" ]]; then
  log_step recovery-state failure 'marker_present=true'
  exit 1
fi
log_step recovery-state success 'marker_present=false cleanup_gates_complete=true'
if osascript -e 'display notification "Stopped" with title "Recording stopped 🔴"'; then
  log_step notification success 'displayed=true'
else
  log_step notification failure 'displayed=false optional=true'
fi
log_step cleanup success 'observed=restored-and-verified'
