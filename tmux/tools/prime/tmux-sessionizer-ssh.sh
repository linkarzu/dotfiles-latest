#!/usr/bin/env bash

# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer
# Filename: ~/github/dotfiles-latest/tmux/tools/tmux-sessionizer.sh
# Remember to make this file executable

# Check if exactly one argument is provided
if [[ $# -eq 1 ]]; then
	# Use the provided argument as the selected directory
	selected=$1
	# replace dots with underscores
	selected_name=$(basename "$selected" | tr . _)
	# Debug line to see what session name is being generated
	# tmux display-message -d 10000 "Directory selected via fzf: $selected_name"

	# I don't need to check if tmux is running, because by default, when I open
	# my terminal, tmux opens
	# If a tmux session with the desired name does not already exist, create it in detached mode
	if ! tmux has-session -t=$selected_name 2>/dev/null; then
		# I included quotes in "$selected" because wasn't changing to dirs that have a space
		# Like the iCloud dir
		tmux new-session -ds $selected_name -c "$selected"
	fi

	# Switch to the tmux session with the name derived from the selected directory
	tmux switch-client -t $selected_name
elif [[ $# -eq 2 ]]; then
	# The second argument is now directly used as the session name for SSH connections
	selected_name=$2
	# Start a new tmux session for the SSH connection, regardless of tmux's current state
	if ! tmux has-session -t="$selected_name" 2>/dev/null; then
		tmux new-session -s "$selected_name" -d "ssh $selected_name"
	fi
	tmux switch-client -t "$selected_name"
else
	# If no argument is provided, use 'find' to list directories in specified paths and 'fzf' for interactive selection
	selected=$(find ~/github "$HOME/Library/Mobile Documents/com~apple~CloudDocs/icloud" -mindepth 1 -maxdepth 1 -type d | fzf)
	# selected=$(find ~/work/builds ~/projects ~/ ~/work ~/personal ~/personal/yt -mindepth 1 -maxdepth 1 -type d | fzf)

	# Debugging
	# tmux display-message -d 10000 "Directory selected via fzf: $selected"

	# Exit the script if no directory is selected
	if [[ -z $selected ]]; then
		# Debugging
		# tmux display-message -d 10000 "No directory selected. Exiting."
		exit 0
	fi

	# Proceed with the same steps as if one argument was given if a directory is selected
	if [[ -n $selected ]]; then
		selected_name=$(basename "$selected" | tr . _)
		tmux_running=$(pgrep tmux)
		if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
			tmux new-session -s $selected_name -c "$selected"
		elif ! tmux has-session -t=$selected_name 2>/dev/null; then
			tmux new-session -ds $selected_name -c "$selected"
		fi
		tmux switch-client -t $selected_name
	fi
fi
