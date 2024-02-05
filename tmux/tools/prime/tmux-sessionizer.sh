#!/usr/bin/env bash

# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer
# Filename: ~/github/dotfiles-latest/tmux/tools/tmux-sessionizer.sh
# Remember to make this file executable
# Filename: ~/github/dotfiles-latest/tmux/tools/prime/tmux-sessionizer.sh

# Check if one argument is being provided
if [[ $# -eq 1 ]]; then
	# Use the provided argument as the selected directory
	selected=$1
elif [[ $# -eq 0 ]]; then
	# Explicitly specified 0 in case someone decides to pass more than 1 argument
	# Use 'find' to list directories in specified paths and 'fzf' for interactive selection
	selected=$(find ~/github "$HOME/Library/Mobile Documents/com~apple~CloudDocs/icloud" -mindepth 1 -maxdepth 1 -type d | fzf)
	# selected=$(find ~/work/builds ~/projects ~/ ~/work ~/personal ~/personal/yt -mindepth 1 -maxdepth 1 -type d | fzf)

	# Debugging, uncomment below if you need to see what's being selected
	# tmux display-message -d 10000 "Directory selected via fzf: $selected"
else
	# This will hopefully catch your attention
	tmux display-message -d 500 "This script expects zero or one argument."
	sleep 1
	tmux display-message -d 500 "This script expects zero or one argument."
	sleep 1
	tmux display-message -d 5000 "This script expects zero or one argument."
fi

# Exit the script if no directory is selected
if [[ -z $selected ]]; then
	# Debugging
	# tmux display-message -d 5000 "No directory selected. Exiting."

	exit 0
fi

# replace dots with underscores
selected_name=$(basename "$selected" | tr . _)
# Debug line to see what session name is being generated
# tmux display-message -d 10000 "Directory selected via fzf: $selected_name"

###############################################################################
# I commented this section, uncomment if needed

# I don't need to check if tmux is running, because by default, when I open
# my terminal, tmux opens
###############################################################################

# # Check if tmux is currently running by looking for its process
# tmux_running=$(pgrep tmux)
# # If tmux is not running and the TMUX environment variable is not set, start a new tmux session with the selected directory
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
