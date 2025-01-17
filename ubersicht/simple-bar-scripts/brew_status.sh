#!/bin/bash

# Filename: ~/github/dotfiles-latest/ubersicht/simple-bar-scripts/brew_status.sh
# ~/github/dotfiles-latest/ubersicht/simple-bar-scripts/brew_status.sh

# If I don't add this, the script won't find any of the apps in the /opt/homebrew/bin dir
# So it won't run: nvim --server /tmp/skitty-neobean-socket --remote-send
export PATH="/opt/homebrew/bin:$PATH"

COUNT="$(brew outdated | wc -l | tr -d ' ')"

if [ "$COUNT" -eq 0 ]; then
  echo "🟩 $COUNT"
elif [ "$COUNT" -lt 12 ]; then
  echo "🟨 $COUNT"
else
  echo "🟥 $COUNT"
fi
