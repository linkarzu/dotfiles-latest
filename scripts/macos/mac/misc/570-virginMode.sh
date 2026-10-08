#!/usr/bin/env bash

# Toggles "virgin mode", triggered by voice through HEX
# (~/.config/hex/hex.config.ts) with "virgin mode on|off".
#
#   Both first focus kitty and switch to its home session.
#
#   on  -> kitty cursor-trail-lightning, opacity 0.75,
#          says "virgin mode activated", anime-purple-eyes wallpaper
#   off -> kitty cursor-trail-blaze, opacity 0.83,
#          says "virgin mode deactivated", colorscheme's wallpaper
#
# Clips live in sounds/virgin-mode/ and were made with gemini-tts.py
# (voice Zephyr)
#
# Usage: 570-virginMode.sh on|off

set -euo pipefail

# HEX runs this with PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin, and
# 500-switchApp.sh needs yabai and jq from Homebrew
export PATH="/opt/homebrew/bin:$PATH"

DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
misc_dir="$DOTFILES_DIR/scripts/macos/mac/misc"
kitty_conf="$DOTFILES_DIR/kitty/kitty.conf"
virgin_wallpaper="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Images/wallpapers/official/anime-purple-eyes.jpg"

# Focuses kitty and switches to its home session, then waits a moment so the
# change happens in front of you. Failures only warn, so the HEX
# transformation still treats the command as handled instead of pasting it.
show_kitty_home() {
  "$misc_dir/500-switchApp.sh" kitty >/dev/null 2>&1 ||
    echo "Could not focus kitty" >&2
  "$misc_dir/550-skhdSession.sh" "$DOTFILES_DIR/kitty/sessions/home.kitty-session" >/dev/null 2>&1 ||
    echo "Could not switch to the home kitty session" >&2
  sleep 1
}

# Runs an awk program over kitty.conf and writes the result back through the
# existing file so its permissions and inode are kept.
edit_kitty_conf() {
  local tmp=""
  tmp="$(mktemp)"
  awk "$@" "$kitty_conf" >"$tmp"
  cat "$tmp" >"$kitty_conf"
  rm -f "$tmp"
}

# Comments every `custom_shaders` line in kitty.conf except the requested one.
set_kitty_shader() {
  local shader="$1"

  if ! grep -Eq "^#* *custom_shaders +${shader} *$" "$kitty_conf"; then
    echo "Shader '$shader' is not listed in $kitty_conf" >&2
    return 1
  fi

  edit_kitty_conf -v want="$shader" '
    /^#* *custom_shaders / {
      name = $0
      sub(/^#* *custom_shaders +/, "", name)
      sub(/ +$/, "", name)
      print (name == want ? "" : "# ") "custom_shaders " name
      next
    }
    { print }
  '
}

# Applies only on reload because kitty.conf sets dynamic_background_opacity.
set_kitty_opacity() {
  edit_kitty_conf -v opacity="$1" '
    /^background_opacity / { print "background_opacity " opacity; next }
    { print }
  '
}

# SIGUSR1 makes every running kitty reload kitty.conf, same as load_config_file.
reload_kitty() {
  pkill -USR1 -x kitty || true
}

# Sets the wallpaper on every Space the same way the colorscheme selector does.
# A failure only warns, so the HEX transformation still treats the command as
# handled instead of pasting it.
set_wallpaper() {
  /usr/bin/python3 "$DOTFILES_DIR/colorscheme/set-wallpaper-all-spaces.py" "$1" >/dev/null ||
    echo "Could not set wallpaper: $1" >&2
}

# Plays an announcement through the OBS "91-sfx" Media source, so only the
# clip reaches the stream, and falls back to afplay when OBS isn't running.
# It runs in the background with output detached so callers like the HEX
# transformation don't wait for the clip to finish.
obs_sfx_player="$HOME/github/dotfiles-private/scripts/macos/mac/obs/sfx/py/play-sfx.py"
announce() {
  local clip="$DOTFILES_DIR/sounds/virgin-mode/$1.wav"
  {
    /usr/bin/python3 "$obs_sfx_player" "$clip" || afplay "$clip"
  } >/dev/null 2>&1 &
}

case "${1:-}" in
on)
  show_kitty_home
  set_kitty_shader cursor-trail-lightning
  set_kitty_opacity 0.75
  reload_kitty
  announce activated
  set_wallpaper "$virgin_wallpaper"
  ;;
off)
  show_kitty_home
  set_kitty_shader cursor-trail-blaze
  set_kitty_opacity 0.83
  reload_kitty
  announce deactivated
  # The colorscheme selector keeps its wallpaper path here, and virgin mode
  # never changes it
  set_wallpaper "$(cat "$DOTFILES_DIR/colorscheme/active/active-wallpaper")"
  ;;
*)
  echo "Usage: $(basename "$0") on|off" >&2
  exit 1
  ;;
esac
