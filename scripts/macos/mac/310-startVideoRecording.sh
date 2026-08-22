#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:$PATH"
mode="${1:-recording}"
studio_url="${2:-}"
livestream_title="${3:-}"
helium_binary="/Applications/Helium.app/Contents/MacOS/Helium"
youtube_studio_app_id="bgdnkjfekohdpfolipjfgjboaibfacfe"
dotfiles_dir="$HOME/github/dotfiles-latest"
skhdrc="$dotfiles_dir/skhd/skhdrc"
recording_mode_marker="$HOME/.cache/obs-meeting-manager/recording-mode"
work_env_file="$HOME/github/dotfiles-private/work/work-env.sh"

if [[ "$mode" == "--finish-livestream" ]]; then
  "$dotfiles_dir/scripts/macos/mac/315-fixObsAudio.sh" --wait
  brave_audio_window_id="$(
    yabai -m query --windows \
      | jq -r '[.[] | select(.app == "Brave Browser" and (.title | contains("Audio playing")))] | max_by(.id).id // empty'
  )"
  if [[ -z "$brave_audio_window_id" ]]; then
    echo "Could not find the Brave audio-test window to pause." >&2
    exit 1
  fi
  yabai -m window --focus "$brave_audio_window_id"
  osascript -e 'tell application "System Events" to keystroke "k"'
  sleep 1
  if yabai -m query --windows \
    | jq -e --argjson id "$brave_audio_window_id" '.[] | select(.id == $id and (.title | contains("Audio playing")))' \
      >/dev/null; then
    echo "The Brave audio-test video did not pause." >&2
    exit 1
  fi
  obs_window_id="$(
    yabai -m query --windows \
      | jq -r '[.[] | select(.app == "OBS Studio" and (.title | startswith("OBS ")))] | max_by(.id).id // empty'
  )"
  [[ -n "$obs_window_id" ]] && yabai -m window --focus "$obs_window_id"
  echo "Paused the Brave audio-test video."
  osascript -e 'display notification "Ready for final checks" with title "Livestream prepared"'
  exit 0
fi

SwitchAudioSource -t output -s "USB Audio"

mkdir -p "$(dirname "$recording_mode_marker")"
touch "$recording_mode_marker"
if [[ -f "$work_env_file" ]]; then
  # shellcheck disable=SC1090
  source "$work_env_file"
  main_kitty_socket="$($dotfiles_dir/scripts/macos/mac/misc/549-kittyMainSocket.sh)"
  /Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${main_kitty_socket}" \
    action close_session "$WORK_DAILY_KITTY_SESSION_FILE" >/dev/null 2>&1 || true
fi
sed -i '' 's|^cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
skhd -r

"$dotfiles_dir/scripts/macos/mac/misc/553-applyRecordingUi.sh" 20 70

"$HOME/github/dotfiles-latest/scripts/macos/mac/290-refreshMembers.sh"

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

open -a "BetterDisplay"
open -a "KeyCastr"
open -a "KofiAlerts"
open -a "StreamElements"
open -a "TTS"
if [[ "$mode" == "--prepare-livestream" && -n "$studio_url" ]]; then
  broadcast_id="${studio_url#*/video/}"
  broadcast_id="${broadcast_id%%/*}"
  python3 "$HOME/github/dotfiles-private/scripts/macos/mac/obs/socialstream_prepare.py" \
    --broadcast-id "$broadcast_id" \
    --twitch-channel linkarzu \
    --twitch-title "$livestream_title" \
    || exit 1
  "$helium_binary" \
    --profile-directory=Default \
    --app-id="$youtube_studio_app_id" \
    --app-launch-url-for-shortcuts-menu-item="$studio_url" \
    >/dev/null 2>&1 &
  sleep 1
  youtube_studio_window_id="$(
    yabai -m query --windows \
      | jq -r '[.[] | select(.app == "YouTube Studio")] | max_by(.id).id // empty'
  )"
  if [[ -n "$youtube_studio_window_id" ]]; then
    yabai -m window --focus "$youtube_studio_window_id"
  fi
else
  "$dotfiles_dir/scripts/macos/mac/misc/500-switchApp.sh" socialstream
fi

# open -a "DisplayLink Manager"

# Keep the calendar format unchanged when recording starts.
# sed -i '' "s|date '+%a %y/%m/%d %H:%M'|date '+%a %y/%m/%d'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"

"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" recording-on

$HOME/github/dotfiles-latest/yabai/yabai_restart.sh

sleep 10

kitty_id=$(yabai -m query --windows | jq -r '.[] | select(.app == "kitty") | .id' | head -n 1)
[[ -n "$kitty_id" ]] && yabai -m window --focus "$kitty_id" || true

python3 "$dotfiles_dir/sketchybar/felixkratz-linkarzu/plugins/timer.py" sequence Sit:1800,Stand:600 >/dev/null 2>&1 &
