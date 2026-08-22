#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:$PATH"
mode="${1:-recording}"
studio_url="${2:-}"
livestream_title="${3:-}"
helium_binary="/Applications/Helium.app/Contents/MacOS/Helium"
youtube_studio_app_id="bgdnkjfekohdpfolipjfgjboaibfacfe"
SwitchAudioSource -t output -s "USB Audio"
dotfiles_dir="$HOME/github/dotfiles-latest"
kitty_conf="$dotfiles_dir/kitty/kitty.conf"
neovim_options="$dotfiles_dir/neovim/neobean/lua/config/options.lua"
virt_column_conf="$dotfiles_dir/neovim/neobean/lua/plugins/virt-column.lua"
prettier_conf="$dotfiles_dir/.prettierrc.yaml"
website_prettier_conf="/System/Volumes/Data/mnt/github_nfs/linkarzu.github.io/.prettierrc.yaml"
skhdrc="$dotfiles_dir/skhd/skhdrc"

set_kitty_font_size() {
  local size="$1"
  local changed=0

  for sock in /tmp/kitty-*; do
    [[ -S "$sock" ]] || continue
    if /Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" set-font-size --all "$size" >/dev/null 2>&1; then
      changed=1
    fi
  done

  if [[ "$changed" -eq 0 ]]; then
    /Applications/kitty.app/Contents/MacOS/kitty @ set-font-size --all "$size" >/dev/null 2>&1 || true
  fi
}

set_editor_width() {
  local width="$1"

  sed -i '' -E "/^else$/,/^  vim.opt.wrap = true$/ s/^([[:space:]]*vim\.opt\.textwidth = )[0-9]+/\\1${width}/" "$neovim_options"
  sed -i '' -E "s/^([[:space:]]*virtcolumn = \")[0-9]+(\",)/\\1${width}\\2/" "$virt_column_conf"
  sed -i '' -E "/^  - files: \"\\*\\.md\"$/,/^  - files:/ s/^([[:space:]]*printWidth: )[0-9]+/\\1${width}/" "$prettier_conf"
  sed -i '' -E "/^  - files: \"\\*\\.md\"$/,/^  - files:/ s/^([[:space:]]*printWidth: )[0-9]+/\\1${width}/" "$website_prettier_conf"
}

restart_kitty() {
  nohup /bin/bash -c '
    osascript -e '\''tell application "kitty" to quit'\'' >/dev/null 2>&1 || true
    for _ in {1..20}; do
      pgrep -x "kitty" >/dev/null 2>&1 || break
      sleep 0.2
    done
    open -a "kitty"
  ' >/dev/null 2>&1 &
}

sed -i '' 's/^font_size .*/font_size 20/' "$kitty_conf"
set_kitty_font_size 20
set_editor_width 70

"$HOME/github/dotfiles-latest/scripts/macos/mac/290-refreshMembers.sh"

if [[ "$mode" == "--prepare-livestream" ]]; then
  osascript -e 'display notification "Ready for final checks" with title "Livestream prepared"'
else
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
open -a "Brave Browser"
nohup "$dotfiles_dir/scripts/macos/mac/315-fixObsAudio.sh" --wait \
  >"${TMPDIR:-/tmp}/obs-brave-audio-selector.log" 2>&1 &
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

# Disable my work related daily note, so I don't access it even by mistake
sed -i '' 's|^cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
skhd -r

# restart_kitty

$HOME/github/dotfiles-latest/yabai/yabai_restart.sh

sleep 10

kitty_id=$(yabai -m query --windows | jq -r '.[] | select(.app == "kitty") | .id' | head -n 1)
[[ -n "$kitty_id" ]] && yabai -m window --focus "$kitty_id" || true

python3 "$dotfiles_dir/sketchybar/felixkratz-linkarzu/plugins/timer.py" sequence Sit:1800,Stand:600 >/dev/null 2>&1 &
