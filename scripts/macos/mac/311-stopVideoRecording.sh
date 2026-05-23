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

sed -i '' 's/^font_size .*/font_size 15/' "$kitty_conf"
set_kitty_font_size 15

"$HOME/github/dotfiles-latest/scripts/macos/mac/misc/230-dnd.sh" off

osascript -e 'display notification "Stopped" with title "Recording stopped 🔴"'

"$HOME/github/scripts-public/macos/mac/310-bannerOff.sh"

pkill "BetterDisplay" 2>/dev/null || true

pkill "KeyCastr" 2>/dev/null || true

# osascript -e 'tell application "DisplayLink Manager" to quit'

sed -i '' "s|date '+%a %y/%m/%d'|date '+%a %y/%m/%d %H:%M'|" "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/calendar.sh"
