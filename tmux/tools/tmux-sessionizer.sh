#!/usr/bin/env bash

# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer
# Filename: ~/github/dotfiles-latest/tmux/tools/tmux-sessionizer.sh
# Remember to make this file executable

# Check if exactly one argument is provided
if [[ $# -eq 1 ]]; then
	# Use the provided argument as the selected directory
	selected=$1
else
	# If no argument is provided, use 'find' to list directories in specified paths and 'fzf' for interactive selection
	# selected=$(find ~/github -mindepth 1 -maxdepth 1 -type d | fzf)
	selected=$(find ~/github "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Scripts" -mindepth 1 -maxdepth 1 -type d | fzf)
	# selected=$(find ~/work/builds ~/projects ~/ ~/work ~/personal ~/personal/yt -mindepth 1 -maxdepth 1 -type d | fzf)

	# Debugging
	# tmux display-message -d 10000 "Directory selected via fzf: $selected"
fi

# Exit the script if no directory is selected
if [[ -z $selected ]]; then
	# Debugging
	# tmux display-message -d 10000 "No directory selected. Exiting."

	exit 0
fi

# Format the selected directory name to use as the tmux session name (replace dots with underscores)
selected_name=$(basename "$selected" | tr . _)
# Debug line to see what session name is being generated
# echo "Attempting to create or switch to session: $selected_name"

# Check if tmux is currently running by looking for its process
tmux_running=$(pgrep tmux)

# If tmux is not running and the TMUX environment variable is not set, start a new tmux session with the selected directory
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	# I included quotes in "$selected" because wasn't changing to dirs that have a space
	# Like the iCloud dir
	tmux new-session -s $selected_name -c "$selected"
	exit 0
fi

# If a tmux session with the desired name does not already exist, create it in detached mode
if ! tmux has-session -t=$selected_name 2>/dev/null; then
	# I included quotes in "$selected" because wasn't changing to dirs that have a space
	# Like the iCloud dir
	tmux new-session -ds $selected_name -c "$selected"
fi

# Switch to the tmux session with the name derived from the selected directory
tmux switch-client -t $selected_name
