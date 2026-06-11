#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:$PATH"
dotfiles_dir="$HOME/github/dotfiles-latest"
kitty_conf="$dotfiles_dir/kitty/kitty.conf"
neovim_options="$dotfiles_dir/neovim/neobean/lua/config/options.lua"
virt_column_conf="$dotfiles_dir/neovim/neobean/lua/plugins/virt-column.lua"
prettier_conf="$dotfiles_dir/.prettierrc.yaml"

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

sed -i '' 's/^font_size .*/font_size 15/' "$kitty_conf"
set_kitty_font_size 15
set_editor_width 80

"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" off

osascript -e 'display notification "Stopped" with title "Recording stopped 🔴"'

"$HOME/github/scripts-public/macos/mac/310-bannerOff.sh"

pkill "BetterDisplay" 2>/dev/null || true

pkill "KeyCastr" 2>/dev/null || true

pkill -f 'KofiAlerts\.app/Contents/MacOS/app_mode_loader' 2>/dev/null || true

# osascript -e 'tell application "DisplayLink Manager" to quit'

sed -i '' "s|date '+%a %y/%m/%d'|date '+%a %y/%m/%d %H:%M'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"

restart_kitty

sleep 2

$HOME/github/dotfiles-latest/yabai/yabai_restart.sh
