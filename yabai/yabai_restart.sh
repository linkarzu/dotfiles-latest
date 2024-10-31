#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/yabai/yabai_env.sh
# ~/github/dotfiles-latest/yabai/yabai_env.sh

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

# Restart the apps in apps_transp_ignore to apply the settings
for app in $(echo $apps_transp_ignore | tr -d '()' | tr '|' ' '); do
  osascript -e "tell application \"$app\" to quit"
  osascript -e "delay 0.5"
  osascript -e "tell application \"$app\" to activate"
done

# After yabai is restarted, I want kitty to be moved to a specific position on
# the screen as it will be my "sticky notes", I also set its size
~/github/dotfiles-latest/yabai/positions/kitty-pos.sh
