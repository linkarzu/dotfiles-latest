#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:$PATH"
kitty_conf="$HOME/github/dotfiles-latest/kitty/kitty.conf"

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

sed -i '' 's/^font_size .*/font_size 18/' "$kitty_conf"
set_kitty_font_size 18

osascript -e 'display notification "Started" with title "Recording started 🟢"'

pkill "Slack" 2>/dev/null || true

"$HOME/github/scripts-public/macos/mac/305-bannerOn.sh"

open -a "BetterDisplay"

open -a "KeyCastr"

# open -a "DisplayLink Manager"

sed -i '' "s|date '+%a %y/%m/%d %H:%M'|date '+%a %y/%m/%d'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"

"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" on
