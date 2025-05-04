#!/usr/bin/env bash

# This script is executed from karabiner, but in karabiner docs:
# https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/shell-command/
# The very limited environment variables are passed to the command, $HOME, $UID, $USER, etc.
# Export environment variables in shell_command if your commands depend them.
#
# If you don't do this, the script won't find yabai or jq or any other apps in
# the /opt/homebrew/bin dir
#
# In this case, I had to add this line, otherwise it would run the sketchybar
# script below mic.sh
export PATH="/opt/homebrew/bin:$PATH"

bash -c "cd '$HOME/github/dotfiles-latest' && NVIM_APPNAME=neobean Neovide"
