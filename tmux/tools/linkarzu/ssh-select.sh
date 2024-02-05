#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/linkarzu/ssh-select.sh

# Define the path to your file containing SSH host aliases and their keys
HOSTS_FILE="$HOME/github/dotfiles-latest/tmux/tools/linkarzu/ssh-hosts.txt"

# Ensure the HOSTS_FILE exists
if [ ! -f "$HOSTS_FILE" ]; then
	echo "SSH hosts file not found at $HOSTS_FILE"
	exit 1
fi

FZF_HEADER=$'- The letter in () like (j) is just to remember the karabiner mapping
- Hosts with () will have it removed before SSHing to them
- You can also have hosts without the () and they will work fine'

# Use fzf to select a host, showing both the host and its key
# selected=$(cat "$HOSTS_FILE" | fzf --height=40% --reverse)
selected=$(cat "$HOSTS_FILE" | grep -v '^#' | fzf --height=40% --reverse --header="$FZF_HEADER" --prompt="Type or select SSH host: ")

# Exit if no selection is made
if [[ -z $selected ]]; then
	echo "No host selected. Exiting."
	exit 0
fi

# Extract just the host name from the selection (before the '(')
SSH_NAME=$(echo "$selected" | awk -F " [(]" '{print $1}')

# Add 'ssh' to beginning of name for easier identification
SELECTED_NAME="ssh-$SSH_NAME"

if ! tmux has-session -t=$SELECTED_NAME 2>/dev/null; then
	tmux new-session -s "$SELECTED_NAME" -d "ssh $SSH_NAME"
fi
# Switch to the tmux session with the name derived from the selected directory
tmux switch-client -t $SELECTED_NAME
