#!/usr/bin/env bash

PLUGIN_DIR="$(dirname "$0")"

minutes=$(osascript -e 'text returned of (display dialog "Timer minutes:" default answer "" buttons {"Cancel", "Start"} default button "Start")' 2>/dev/null)

if [[ -z "$minutes" ]]; then
  exit 0
fi

if [[ ! "$minutes" =~ ^[0-9]+$ ]] || [[ "$minutes" -lt 1 ]]; then
  osascript -e 'display dialog "Enter a whole number greater than 0." buttons {"OK"} default button "OK"' >/dev/null 2>&1
  exit 1
fi

python3 "$PLUGIN_DIR/timer.py" timer "$((minutes * 60))"
