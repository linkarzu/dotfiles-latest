#!/usr/bin/env bash

# I use this with hyper+s+t (system task) to execute scripts in the SCRIPTS_DIR
# below. Stuff like running the yabai scripting-addition that I have to do once
# every while

# Path to the directory containing the scripts
SCRIPTS_DIR="$HOME/github/dotfiles-latest/scripts/macos/mac"

# Ensure fzf is installed
if ! command -v fzf &>/dev/null; then
  echo "fzf is not installed. Please install it first."
  exit 1
fi

# List available scripts
schemes=($(ls "$SCRIPTS_DIR"/*.sh | xargs -n 1 basename))

# Check if any scripts available
if [ ${#schemes[@]} -eq 0 ]; then
  echo "No scripts found in $SCRIPTS_DIR."
  exit 1
fi

# Use fzf to select a script
selected_script=$(printf "%s\n" "${schemes[@]}" | fzf --height=40% --reverse --header="Select a script to execute" --prompt="Script > ")

# Check if a selection was made
if [ -z "$selected_script" ]; then
  echo "No script selected."
  exit 0
fi

# Execute the selected script
"$SCRIPTS_DIR/$selected_script"
