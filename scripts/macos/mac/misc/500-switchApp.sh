#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/misc/500-switchApp.sh
# ~/github/dotfiles-latest/scripts/macos/mac/misc/500-switchApp.sh

APP="$1"

# Check if there is already a window for the app
ID="$(yabai -m query --windows | jq -r --arg app "$APP" '[.[] | select(.app==$app)][0].id')"

if [[ -n "$ID" && "$ID" != null ]]; then
  # App window exists → focus it
  yabai -m window --focus "$ID"
else
  # No window → launch and wait until one appears, then focus
  open -a "$APP" >/dev/null 2>&1 || true
  for _ in {1..40}; do
    ID="$(yabai -m query --windows | jq -r --arg app "$APP" '[.[] | select(.app==$app)][0].id')"
    if [[ -n "$ID" && "$ID" != null ]]; then
      yabai -m window --focus "$ID"
      break
    fi
    sleep 0.2
  done
fi
