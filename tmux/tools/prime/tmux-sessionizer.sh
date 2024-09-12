#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/prime/tmux-sessionizer.sh

# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

# NOTE:
# Remember to make this file executable

# Check if one argument is being provided
if [[ $# -eq 1 ]]; then
  # Use the provided argument as the selected directory
  selected=$1
elif [[ $# -eq 0 ]]; then
  # Explicitly specified 0 in case someone decides to pass more than 1 argument
  # Use 'find' to list directories in specified paths and 'fzf' for interactive selection
  selected=$(find ~/github "$HOME/Library/Mobile Documents/com~apple~CloudDocs/github" "/System/Volumes/Data/mnt" -mindepth 1 -maxdepth 1 -type d | fzf)
  # Prime's example below
  # selected=$(find ~/work/builds ~/projects ~/ ~/work ~/personal ~/personal/yt -mindepth 1 -maxdepth 1 -type d | fzf)

  # Debugging, uncomment below if you need to see what's being selected
  # tmux display-message -d 10000 "Directory selected via fzf: $selected"
elif [[ $# -eq 2 ]]; then
  # Use the second argument as the directory path for the find command
  dir_to_search="$2"
  # Make sure the directory exists
  if [[ -d "$dir_to_search" ]]; then
    selected=$(find "$dir_to_search" -mindepth 1 -maxdepth 1 -type d | fzf)
  else
    tmux display-message -d 3000 "Directory does not exist: $dir_to_search"
    exit 1
  fi
else
  # This will hopefully catch your attention
  tmux display-message -d 1000 "This script expects zero, one or two arguments."
  sleep 1
  tmux display-message -d 1000 "This script expects zero  one or two arguments."
  sleep 1
  tmux display-message -d 3000 "This script expects zero  one or two arguments."
  exit 1
fi

# Exit the script if no directory is selected
if [[ -z $selected ]]; then
  # Debugging
  # tmux display-message -d 5000 "No directory selected. Exiting."
  exit 0
fi

# replace '.' and '-' with '_'
# I had some dirs with '-' and couldn't get the value of the corresponding var
# in the mappings file because it was interpreting the '-'
selected_after_tr=$(basename "$selected" | tr '.-' '__')

# NOTE: If you don't want to use the 'karabiner-mappings.sh' file, just rename
# that 'karabiner-mappings.sh' file to something else (or delete it)
# This file adds a letter at the end of my session to remind me of the karabiner shortcut
mappings_file="$HOME/github/dotfiles-latest/tmux/tools/prime/karabiner-mappings.sh"
if [ -f "$mappings_file" ]; then
  source "$mappings_file"
  base_selected=$(basename "$selected_after_tr")
  current_username=$(whoami)
  if [[ "$base_selected" == "$current_username" ]]; then
    # If selected_after_tr equals current username, append "-h"
    selected_name="${base_selected}-${username_suffix}"
  else
    # Get the value of the variable whose name matches base_selected
    mapping_value="${!base_selected}"
    selected_name="${base_selected}-${mapping_value}"
  fi
else
  selected_name=$selected_after_tr
fi

# # Debug line to see what session name is being generated
# tmux display-message -d 5000 "selected_name = $selected_name"

###############################################################################
# I commented this section, uncomment if needed
# I don't need to check if tmux is running, because by default, when I open
# my terminal, tmux opens
###############################################################################
# # Check if tmux is currently running by looking for its process
# tmux_running=$(pgrep tmux)
# # If tmux is not running and the TMUX environment variable is not set,
# # start a new tmux session with the selected directory
# if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
# 	# I included quotes in "$selected" because wasn't changing to dirs that have a space
# 	# Like the iCloud dir
# 	tmux new-session -s $selected_name -c "$selected"
# 	exit 0
# fi
###############################################################################

# If a tmux session with the desired name does not already exist, create it in detached mode
if ! tmux has-session -t=$selected_name 2>/dev/null; then
  # I included quotes in "$selected" because wasn't changing to dirs that have a space
  # Like the iCloud dir
  tmux new-session -ds $selected_name -c "$selected"
fi

# Switch to the tmux session with the name derived from the selected directory
tmux switch-client -t $selected_name
