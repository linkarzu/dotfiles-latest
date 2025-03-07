#!/usr/bin/env bash

osascript -e 'display dialog "Are you sure you want to restart?" buttons {"Cancel", "Restart"} default button "Cancel"' | grep -q "button returned:Restart" &&
  osascript -e 'tell application "System Events" to restart'
