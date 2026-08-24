#!/usr/bin/env bash

set -euo pipefail

export PATH="/opt/homebrew/bin:$PATH"
mode="${1:-recording}"
studio_url="${2:-}"
livestream_title="${3:-}"
output_scope="${4:-}"
dotfiles_dir="$HOME/github/dotfiles-latest"
skhdrc="$dotfiles_dir/skhd/skhdrc"
recording_mode_marker="$HOME/.cache/obs-meeting-manager/recording-mode"
work_env_file="$HOME/github/dotfiles-private/work/work-env.sh"

log_step() {
  local step="$1"
  local status="$2"
  shift 2
  printf 'phase=prepare step=%s status=%s%s\n' "$step" "$status" "${*:+ $*}"
}

wait_for_app() {
  local app_name="$1"
  local deadline=$((SECONDS + 15))
  while ((SECONDS < deadline)); do
    if pgrep -f "/${app_name}.app/Contents/" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.25
  done
  return 1
}

if [[ "$mode" == "--finish-livestream" ]]; then
  obs_focus_gate="$HOME/github/dotfiles-private/scripts/macos/mac/obs/set-audio-application/py/obs_focus_gate.py"
  "$dotfiles_dir/scripts/macos/mac/315-fixObsAudio.sh" --wait
  if ! brave_windows="$(timeout 5 yabai -m query --windows)"; then
    log_step brave-audio-window timeout 'observed=yabai-window-query-timeout timeout_seconds=5'
    exit 1
  fi
  if ! brave_audio_window_id="$(
    printf '%s' "$brave_windows" \
      | jq -r '[.[] | select(.app == "Brave Browser" and (.title | contains("Audio playing")))] | max_by(.id).id // empty'
  )"; then
    log_step brave-audio-window failure 'observed=invalid-yabai-window-data'
    exit 1
  fi
  if [[ -z "$brave_audio_window_id" ]]; then
    echo "Could not find the Brave audio-test window to pause." >&2
    exit 1
  fi
  python3 "$obs_focus_gate"
  if ! timeout 5 yabai -m window "$brave_audio_window_id" --focus; then
    log_step brave-audio-window failure 'observed=focus-command-failed-or-timed-out timeout_seconds=5'
    exit 1
  fi
  osascript -e 'tell application "System Events" to keystroke "k"'
  python3 "$HOME/github/dotfiles-private/scripts/macos/mac/obs/set-audio-application/py/wait-for-audio-output.py" \
    "Brave Browser" --timeout 15 --stable-for 1 --expect-stopped
  python3 "$obs_focus_gate"
  echo "Paused the Brave audio-test video."
  exit 0
fi

if [[ -n "$output_scope" && "$output_scope" != "--youtube-only" ]]; then
  echo "Unsupported output scope: $output_scope" >&2
  exit 1
fi

log_step audio-output start 'expected="USB Audio"'
SwitchAudioSource -t output -s "USB Audio"
current_audio_output="$(SwitchAudioSource -c -t output)"
if [[ "$current_audio_output" != "USB Audio" ]]; then
  log_step audio-output failure "observed=$(printf '%q' "$current_audio_output")"
  exit 1
fi
log_step audio-output success 'observed="USB Audio"'

log_step recording-mode start 'expected=marker-present work-session-closed hotkey-disabled'
mkdir -p "$(dirname "$recording_mode_marker")"
active_hotkey='cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh'
disabled_hotkey='# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh'
if grep -Fqx "$active_hotkey" "$skhdrc"; then
  initial_hotkey_state="enabled"
elif grep -Fqx "$disabled_hotkey" "$skhdrc"; then
  initial_hotkey_state="disabled"
else
  log_step recording-mode failure 'hotkey_initial_state=unknown'
  exit 1
fi
recording_mode_marker_tmp="${recording_mode_marker}.$$"
printf 'hotkey_initial=%s\n' "$initial_hotkey_state" >"$recording_mode_marker_tmp"
mv "$recording_mode_marker_tmp" "$recording_mode_marker"
[[ -e "$recording_mode_marker" ]] || {
  log_step recording-mode failure 'marker_present=false'
  exit 1
}
if [[ -f "$work_env_file" ]]; then
  # shellcheck disable=SC1090
  source "$work_env_file"
  main_kitty_socket="$($dotfiles_dir/scripts/macos/mac/misc/549-kittyMainSocket.sh)"
  /Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${main_kitty_socket}" \
    action close_session "$WORK_DAILY_KITTY_SESSION_FILE" >/dev/null 2>&1 || true
  if ! python3 \
    "$HOME/github/dotfiles-private/scripts/macos/mac/obs/meeting/py/work_session_gate.py" \
    --socket "$main_kitty_socket" \
    --work-root "$WORK_OBSIDIAN_DIR" \
    --timeout 5; then
    log_step recording-mode failure 'work_session_state=present-or-unknown'
    exit 1
  fi
fi
sed -i '' 's|^cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
skhd -r
grep -Fqx '# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh' "$skhdrc" || {
  log_step recording-mode failure 'hotkey_disabled=false'
  exit 1
}
log_step recording-mode success 'marker_present=true work_session_closed=true hotkey_disabled=true'

log_step recording-ui start 'expected=font-20 width-70 live-update'
"$dotfiles_dir/scripts/macos/mac/misc/553-applyRecordingUi.sh" 20 70
log_step recording-ui success 'font=20 width=70'

log_step member-overlay start 'expected=refresh-complete'
"$HOME/github/dotfiles-latest/scripts/macos/mac/290-refreshMembers.sh"
[[ -s "$HOME/github/dotfiles-private/scripts/macos/mac/yt-members-overlay/overlay/index.html" ]] || {
  log_step member-overlay failure 'index_present=false'
  exit 1
}
log_step member-overlay success 'index_present=true'

if [[ "$mode" != "--prepare-livestream" ]]; then
  osascript -e 'display notification "Started" with title "Recording started 🟢"'
fi

pkill "Slack" 2>/dev/null || true
pkill "MSTeams" 2>/dev/null || true
pkill "Microsoft Edge" 2>/dev/null || true
pkill "Microsoft Outlook" 2>/dev/null || true
pkill "Mail" 2>/dev/null || true
osascript -e 'tell application "Finder" to close every window' >/dev/null 2>&1 || true

# I used this in tmux, don't use tmux anymore
rm -f "${TMPDIR:-/tmp}/sketchybar-streaming-16-minute-reminder"
"$HOME/github/scripts-public/macos/mac/305-bannerOn.sh"

for support_app in KeyCastr KofiAlerts StreamElements TTS; do
  log_step support-app start "app=$(printf '%q' "$support_app")"
  open -a "$support_app"
  if ! wait_for_app "$support_app"; then
    log_step support-app failure "app=$(printf '%q' "$support_app") process_present=false"
    exit 1
  fi
  log_step support-app success "app=$(printf '%q' "$support_app") process_present=true"
done
if [[ "$mode" == "--prepare-livestream" && -n "$studio_url" ]]; then
  broadcast_id="${studio_url#*/video/}"
  broadcast_id="${broadcast_id%%/*}"
  socialstream_command=(
    python3 "$HOME/github/dotfiles-private/scripts/macos/mac/obs/socialstream_prepare.py"
    --broadcast-id "$broadcast_id"
  )
  if [[ "$output_scope" == "--youtube-only" ]]; then
    socialstream_command+=(--youtube-only)
  else
    socialstream_command+=(--twitch-channel linkarzu --twitch-title "$livestream_title")
  fi
  printf 'phase=prepare step=socialstream status=start broadcast_id=%s youtube_only=%s\n' \
    "$broadcast_id" "$([[ "$output_scope" == "--youtube-only" ]] && printf true || printf false)"
  "${socialstream_command[@]}" || exit 1
  printf 'phase=prepare step=socialstream status=success broadcast_id=%s\n' "$broadcast_id"
  python3 \
    "$HOME/github/dotfiles-private/scripts/macos/mac/obs/meeting/py/youtube_studio_window.py" \
    --studio-url "$studio_url" \
    --timeout 15
else
  "$dotfiles_dir/scripts/macos/mac/misc/500-switchApp.sh" socialstream
fi

# open -a "DisplayLink Manager"

# Keep the calendar format unchanged when recording starts.
# sed -i '' "s|date '+%a %y/%m/%d %H:%M'|date '+%a %y/%m/%d'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"

log_step dnd start 'expected=recording-on'
"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" recording-on
log_step dnd success 'mode=recording-on'

timer_log="$HOME/.cache/obs-meeting-manager/recording-timer.log"
timer_pid_file="/tmp/sketchybar_timer.pid"
timer_ready_file="/tmp/sketchybar_timer.ready"
mkdir -p "$(dirname "$timer_log")"
rm -f "$timer_ready_file"
python3 "$dotfiles_dir/sketchybar/felixkratz-linkarzu/plugins/timer.py" sequence Sit:1800,Stand:600 \
  >>"$timer_log" 2>&1 &
timer_launcher_pid=$!
timer_deadline=$((SECONDS + 5))
while true; do
  if [[ -s "$timer_pid_file" && -s "$timer_ready_file" ]]; then
    timer_pid="$(<"$timer_pid_file")"
    ready_pid="$(<"$timer_ready_file")"
    if [[ "$timer_pid" == "$ready_pid" && "$timer_pid" == "$timer_launcher_pid" ]] \
      && kill -0 "$timer_pid" 2>/dev/null; then
      break
    fi
  fi
  if ((SECONDS >= timer_deadline)); then
    kill "$timer_launcher_pid" 2>/dev/null || true
    stop_deadline=$((SECONDS + 5))
    while kill -0 "$timer_launcher_pid" 2>/dev/null; do
      if ((SECONDS >= stop_deadline)); then
        kill -KILL "$timer_launcher_pid" 2>/dev/null || true
        break
      fi
      sleep 0.1
    done
    wait "$timer_launcher_pid" 2>/dev/null || true
    if [[ -s "$timer_pid_file" && "$(<"$timer_pid_file")" == "$timer_launcher_pid" ]]; then
      rm -f "$timer_pid_file"
    fi
    if [[ -s "$timer_ready_file" && "$(<"$timer_ready_file")" == "$timer_launcher_pid" ]]; then
      rm -f "$timer_ready_file"
    fi
    log_step recording-timer failure \
      "ready=false launcher_pid=$timer_launcher_pid process_present=$(kill -0 "$timer_launcher_pid" 2>/dev/null && printf true || printf false) log_path=$timer_log"
    exit 1
  fi
  sleep 0.1
done
log_step recording-timer success "pid=$timer_pid process_alive=true ready=true log_path=$timer_log"
