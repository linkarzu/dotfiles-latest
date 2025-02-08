#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/500-youtubeChat.sh
# ~/github/dotfiles-latest/scripts/macos/mac/500-youtubeChat.sh

# Prompt the user for the YouTube Live URL
read -rp "Enter the YouTube Live URL: " stream_url

# Extract the stream ID from the given YouTube URL
if [[ ! "$stream_url" =~ youtube\.com/live/([a-zA-Z0-9_-]+) ]]; then
  echo "Invalid YouTube Live URL"
  exit 1
fi

stream_id="${BASH_REMATCH[1]}"

# Open YouTube chat in a dedicated Chrome app window
open -na "Google Chrome" --args --app="https://www.youtube.com/live_chat?v=${stream_id}"

sleep 2

# Execute the yabai positioning script
"$HOME/github/dotfiles-latest/yabai/positions/kitty-pos.sh"
