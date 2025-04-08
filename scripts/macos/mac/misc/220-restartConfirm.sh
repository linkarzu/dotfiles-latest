#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/misc/220-restartConfirm.sh
# ~/github/dotfiles-latest/scripts/macos/mac/misc/220-restartConfirm.sh

osascript -e 'display dialog "Are you sure you want to restart?" buttons {"Cancel", "Restart"} default button "Cancel"' | grep -q "button returned:Restart" &&
  osascript -e 'tell application "System Events" to restart'
