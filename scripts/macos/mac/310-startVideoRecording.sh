#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:$PATH"
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

osascript -e 'display notification "Started" with title "Recording started 🟢"'

pkill "Slack" 2>/dev/null || true
pkill "MSTeams" 2>/dev/null || true
pkill "Microsoft Edge" 2>/dev/null || true
pkill "Microsoft Outlook" 2>/dev/null || true
pkill "Mail" 2>/dev/null || true
osascript -e 'tell application "Finder" to close every window' >/dev/null 2>&1 || true

# I used this in tmux, don't use tmux anymore
"$HOME/github/scripts-public/macos/mac/305-bannerOn.sh"

open -a "BetterDisplay"
open -a "KeyCastr"
open -a "KofiAlerts"
open -a "StreamElements"
open -a "TTS"
open -a "Brave Browser"

# open -a "DisplayLink Manager"

sed -i '' "s|date '+%a %y/%m/%d %H:%M'|date '+%a %y/%m/%d'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"

"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" on

# Disable my work related daily note, so I don't access it even by mistake
sed -i '' 's|^cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
skhd -r

restart_kitty

$HOME/github/dotfiles-latest/yabai/yabai_restart.sh

sleep 10

kitty_id=$(yabai -m query --windows | jq -r '.[] | select(.app == "kitty") | .id' | head -n 1)
[[ -n "$kitty_id" ]] && yabai -m window --focus "$kitty_id" || true

python3 "$dotfiles_dir/sketchybar/felixkratz-linkarzu/plugins/timer.py" sequence Sit:1800,Stand:600 >/dev/null 2>&1 &
