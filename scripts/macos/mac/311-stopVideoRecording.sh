#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:$PATH"
SwitchAudioSource -t output -s "MacBook Pro Speakers"
dotfiles_dir="$HOME/github/dotfiles-latest"
skhdrc="$dotfiles_dir/skhd/skhdrc"
recording_mode_marker="$HOME/.cache/obs-meeting-manager/recording-mode"

"$dotfiles_dir/scripts/macos/mac/misc/553-applyRecordingUi.sh" 15 80

"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" recording-off

osascript -e 'display notification "Stopped" with title "Recording stopped 🔴"'

rm -f "${TMPDIR:-/tmp}/sketchybar-streaming-16-minute-reminder"
"$HOME/github/scripts-public/macos/mac/310-bannerOff.sh"

pkill "BetterDisplay" 2>/dev/null || true
pkill "KeyCastr" 2>/dev/null || true
pkill "Brave Browser" 2>/dev/null || true
brave_audio_pid_file="${TMPDIR:-/tmp}/obs-brave-audio-selector.pid"
if [[ -f "$brave_audio_pid_file" ]]; then
  brave_audio_pid="$(<"$brave_audio_pid_file")"
  brave_audio_command="$(ps -p "$brave_audio_pid" -o command= 2>/dev/null || true)"
  if [[ "$brave_audio_command" == *"315-fixObsAudio.sh --wait"* ]]; then
    kill "$brave_audio_pid" 2>/dev/null || true
  fi
  rm -f "$brave_audio_pid_file"
fi
pkill -f 'KofiAlerts\.app/Contents/MacOS/app_mode_loader' 2>/dev/null || true
pkill -f 'StreamElements\.app/Contents/MacOS/app_mode_loader' 2>/dev/null || true
pkill -f 'TTS\.app/Contents/MacOS/app_mode_loader' 2>/dev/null || true

# osascript -e 'tell application "DisplayLink Manager" to quit'

# Keep the calendar format unchanged when recording stops.
# sed -i '' "s|date '+%a %y/%m/%d'|date '+%a %y/%m/%d %H:%M'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"

# re-enable my work related daily note, so I don't access it even by mistake
sed -i '' 's|^# cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
skhd -r
rm -f "$recording_mode_marker"

$HOME/github/dotfiles-latest/yabai/yabai_restart.sh

sleep 10

kitty_id=$(yabai -m query --windows | jq -r '.[] | select(.app == "kitty") | .id' | head -n 1)
[[ -n "$kitty_id" ]] && yabai -m window --focus "$kitty_id" || true

python3 "$dotfiles_dir/sketchybar/felixkratz-linkarzu/plugins/timer.py" stop >/dev/null 2>&1 || true
