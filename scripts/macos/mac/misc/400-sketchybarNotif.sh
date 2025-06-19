#!/usr/bin/env bash

# Call this script and pass an argument to it, it will show that argument in
# sketchybar as a message for the sleep amount of time

# ~/github/dotfiles-latest/scripts/macos/mac/misc/400-sketchybarNotif.sh

# This script is executed from karabiner, but in karabiner docs:
# https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/shell-command/
# The very limited environment variables are passed to the command, $HOME, $UID, $USER, etc.
# Export environment variables in shell_command if your commands depend them.
#
# If you don't do this, the script won't find yabai or jq or any other apps in
# the /opt/homebrew/bin dir
export PATH="/opt/homebrew/bin:$PATH"

# Notification text comes from the first argument
NOTIF_LABEL="${1:-}"

sketchybar -m --set notification label="$NOTIF_LABEL" icon='' icon.color=$BLUE label.color=$BLUE icon.drawing=on
sleep 1
sketchybar -m --set notification label='' icon.drawing=off
