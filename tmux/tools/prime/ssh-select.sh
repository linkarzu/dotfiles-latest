#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/prime/ssh-select.sh

# Define the path to your file containing SSH host aliases and their keys
HOSTS_FILE="$HOME/github/dotfiles-latest/tmux/tools/prime/ssh_hosts.txt"

# Ensure the HOSTS_FILE exists
if [ ! -f "$HOSTS_FILE" ]; then
	echo "SSH hosts file not found at $HOSTS_FILE"
	exit 1
fi

# Use fzf to select a host, showing both the host and its key
selected=$(cat "$HOSTS_FILE" | fzf --height=40% --reverse)

# Exit if no selection is made
if [[ -z $selected ]]; then
	echo "No host selected. Exiting."
	exit 0
fi

# Extract just the host name from the selection (before the '(')
selected_name=$(echo "$selected" | awk -F " [(]" '{print $1}')

# Now, either attach to an existing session or start a new one
if tmux has-session -t="$selected_name" 2>/dev/null; then
	echo "Attaching to existing session $selected_name"
	tmux switch-client -t "$selected_name"
else
	echo "Creating new session $selected_name"
	tmux new-session -s "$selected_name" -d "ssh $selected_name"
	tmux switch-client -t "$selected_name"
fi
