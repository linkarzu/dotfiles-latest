#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/yabai/positions/kitty-pos.sh
# ~/github/dotfiles-latest/yabai/positions/kitty-pos.sh

# This script is executed from karabiner, but in karabiner docs:
# https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/shell-command/
# The very limited environment variables are passed to the command, $HOME, $UID, $USER, etc.
# Export environment variables in shell_command if your commands depend them.
#
# If you don't do this, the script won't find yabai or jq or any other apps in
# the /opt/homebrew/bin dir
export PATH="/opt/homebrew/bin:$PATH"

# To find the position and size of an app
# yabai -m query --windows | jq '.[] | select(.app == "kitty") | {frame: .frame, id: .id}'
# yabai -m query --windows is producing malformed JSON with a trailing comma before ]
# yabai -m query --windows | sed 's/,]/]/g' | jq '.[] | select(.app == "kitty") | {frame: .frame, id: .id}'
display_resolution=$(system_profiler SPDisplaysDataType | grep Resolution)
# First condition is to match my macbook pro, the * are used as wildcards
if [[ "$display_resolution" == *"3456 x 2234"* ]]; then
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --move abs:1,139:41
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --resize abs:231:400
  # This elif below is for my macbook pro 14 inch
elif [[ "$display_resolution" == *"3024 x 1964"* ]]; then
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --move abs:1123:39
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --resize abs:231:400
  # This elif below is for my short format videos 9:16
elif [[ "$display_resolution" == *"1536 x 2048"* ]]; then
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --move abs:4:805
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --resize abs:290:215
  # Else below will match my 27 inch monitor
else
  # yabai -m window --focus "$(yabai -m query --windows | sed 's/,]/]/g' | jq '.[] | select(.app == "kitty") | .id')" --move abs:1369:39
  # yabai -m window --focus "$(yabai -m query --windows | sed 's/,]/]/g' | jq '.[] | select(.app == "kitty") | .id')" --resize abs:231:400
  # yabai -m window --focus "$(yabai -m query --windows | sed 's/,]/]/g' | jq '.[] | select(.app == "Google Chrome") | .id')" --move abs:1369:545
  # yabai -m window --focus "$(yabai -m query --windows | sed 's/,]/]/g' | jq '.[] | select(.app == "Google Chrome") | .id')" --resize abs:231:355
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --move abs:1369:39
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "kitty") | .id')" --resize abs:231:400
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "Google Chrome") | .id')" --move abs:1369:545
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "Google Chrome") | .id')" --resize abs:231:355
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "Spotify") | .id')" --move abs:173:120
  yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "Spotify") | .id')" --resize abs:1027:708
  # yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "Udemy") | .id')" --move abs:0:38
  # yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "Udemy") | .id')" --resize abs:912:862
  # yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "WezTerm") | .id')" --move abs:912:39
  # yabai -m window --focus "$(yabai -m query --windows | jq '.[] | select(.app == "WezTerm") | .id')" --resize abs:688:862
fi
