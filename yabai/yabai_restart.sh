#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/yabai/yabai_restart.sh
# ~/github/dotfiles-latest/yabai/yabai_restart.sh

source "$HOME/github/dotfiles-latest/yabai/yabai_env.sh"

# This script is executed from karabiner, but in karabiner docs:
# https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/shell-command/
# The very limited environment variables are passed to the command, $HOME, $UID, $USER, etc.
# Export environment variables in shell_command if your commands depend them.
#
# If you don't do this, the script won't find yabai or jq or any other apps in
# the /opt/homebrew/bin dir
export PATH="/opt/homebrew/bin:$PATH"

yabai --restart-service

# Wait a few seconds after restarting yabai, or the apps will restart too early
# I think this causes the apps not to show with my transparent apps
# sleep 1

# Restart the apps in apps_transp_ignore to apply the settings
# Convert the string to an array, properly handling spaces in app names
# Remove parentheses and split on |
IFS='|' read -ra apps <<<"$(echo "$apps_transp_ignore" | tr -d '()')"

# Iterate through the array
for app in "${apps[@]}"; do
  # Trim leading/trailing whitespace
  app=$(echo "$app" | xargs)
  pkill "$app"
  sleep 1
  open -a "$app"
  sleep 1
done

# IFS='|' read -ra apps <<<"$(echo "$apps_scratchpad" | tr -d '()')"
#
# # Iterate through the array
# for app in "${apps[@]}"; do
#   # Trim leading/trailing whitespace
#   app=$(echo "$app" | xargs)
#   pkill "$app"
#   sleep 0.7
#   open -a "$app"
#   sleep 0.7
# done

# After yabai is restarted, I want kitty to be moved to a specific position on
# the screen as it will be my "sticky notes", I also set its size
~/github/dotfiles-latest/yabai/positions/kitty-pos.sh

# Focus Ghostty window before restarting Neovim
ghostty_window_id=$(yabai -m query --windows | jq '.[] | select(.app == "Ghostty") | .id' | head -n 1)
if [[ -n "$ghostty_window_id" ]]; then
  yabai -m window --focus "$ghostty_window_id"
fi

# Restart Neovim
open "btt://execute_assigned_actions_for_trigger/?uuid=481BDF1F-D0C3-4B5A-94D2-BD3C881FAA6F"
