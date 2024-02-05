#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/linkarzu/ssh-select.sh

# NOTE:
# Remember to make this file executable

# Define the path to your file containing SSH host aliases and their keys
hosts_file="$HOME/github/dotfiles-latest/tmux/tools/linkarzu/ssh-hosts.sh"

# Ensure the hosts_file exists
if [ ! -f "$hosts_file" ]; then
	tmux display-message -d 3000 "ssh hosts file not found"
	sleep 3
	exit 1
fi

# Source the SSH hosts mappings
# Sent to dev null in case there are hosts added without mappings
# I.E 'docker2' instead of 'docker3="j"'
source $hosts_file >/dev/null 2>&1

fzf_header=$'- The letter after the '=' is just to remember my karabiner mappings
- Hosts with '=' will have it removed before SSHing to them
- You can also have hosts without the '=' and they will work fine'

# Use fzf to select a host, showing both the host and its key
selected=$(cat "$hosts_file" | grep -v '^#' | fzf --height=40% --reverse --header="$fzf_header" --prompt="Type or select SSH host: ")
# Debugging
# tmux display-message -d 3000 "selected: $selected"
# sleep 3

# Exit if no selection is made
if [[ -z $selected ]]; then
	echo "No host selected. Exiting."
	exit 0
fi

# Extract the variable name from the selection
ssh_name=$(echo "$selected" | cut -d'=' -f1)

selected_after_tr=$(basename "$ssh_name" | tr '.-' '__')

# NOTE: If you don't want to use the 'ssh-hosts.sh' file, just rename
# that 'ssh-hosts.sh' file to something else (or delete it)
# This file adds a letter at the end of my session to remind me of the karabiner shortcut
mappings_file=$hosts_file
if [ -f "$mappings_file" ]; then
	# source "$mappings_file"
	# Get the value of the variable whose name matches $base_selected
	mapping_value="${!selected_after_tr}"
	# If mapping value is not empty
	if [ -n "$mapping_value" ]; then
		selected_name="SSH-${selected_after_tr}-${mapping_value}"
	else
		# If the mapping value is empty
		selected_name="SSH-${selected_after_tr}"
	fi
else
	selected_name="SSH-${selected_after_tr}"
fi

# If a tmux session with the desired name does not already exist, create it in detached mode
if ! tmux has-session -t=$selected_name 2>/dev/null; then
	tmux new-session -s "$selected_name" -d "ssh $ssh_name"
fi

# Switch to the tmux session with the name derived from the selected directory
tmux switch-client -t $selected_name
