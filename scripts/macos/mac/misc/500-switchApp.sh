#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/misc/500-switchApp.sh
# ~/github/dotfiles-latest/scripts/macos/mac/misc/500-switchApp.sh

APP="$1"
kitty_launched=0

if [[ "$APP" == "kitty" ]]; then
  kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
  home_session="$HOME/github/dotfiles-latest/kitty/sessions/home.kitty-session"
  sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1 || true)"
  if [[ -z "${sock:-}" ]] || ! "$kitty_bin" @ --to "unix:${sock}" ls >/dev/null 2>&1; then
    # Launch kitty in the home session without blocking this script
    open -a "kitty" --args --session "$home_session" >/dev/null 2>&1 || true
    kitty_launched=1
  fi
fi

# Check if there is already a window for the app
ID="$(yabai -m query --windows | jq -r --arg app "$APP" '[.[] | select(.app==$app)][0].id')"

if [[ -n "$ID" && "$ID" != null ]]; then
  # App window exists → focus it
  yabai -m window --focus "$ID"
else
  # No window → launch and wait until one appears, then focus
  if [[ "$APP" == "kitty" && $kitty_launched -eq 1 ]]; then
    :
  else
    open -a "$APP" >/dev/null 2>&1 || true
  fi
  for _ in {1..40}; do
    ID="$(yabai -m query --windows | jq -r --arg app "$APP" '[.[] | select(.app==$app)][0].id')"
    if [[ -n "$ID" && "$ID" != null ]]; then
      yabai -m window --focus "$ID"
      break
    fi
    sleep 0.2
  done
fi
