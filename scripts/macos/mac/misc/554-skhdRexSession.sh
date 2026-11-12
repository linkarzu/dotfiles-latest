#!/usr/bin/env bash

# Switch the Rex app to a Rex session by its label
# Needs Remote Control on in Rex: Settings > Server > Client Info

set -euo pipefail
label="$1"

# skhd runs with a short PATH, and rex isn't on it outside Rex terminals
rex="${REX_BIN:-$(ls -d "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/"*/"Rex Server.app/Contents/MacOS/rex" | sort -V | tail -1)}"
session_id="$("$rex" ls --json | /opt/homebrew/bin/jq -r --arg label "$label" '.sessions[] | select(.label == $label) | .session_id' | head -1)"

if [[ -z $session_id ]]; then
  osascript -e "display notification \"No Rex session named $label\" with title \"Rex\""
  exit 1
fi

open -b com.superlogical.rex
"$rex" do session.select session_id="$session_id"
