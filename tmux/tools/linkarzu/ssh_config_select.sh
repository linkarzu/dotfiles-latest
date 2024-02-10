#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/linkarzu/ssh-config-select.sh

# NOTE:
# Remember to make this file executable

# NOTE:
# This scripts goes through your `~/.ssh/config` file and lists them in an fzf
# menu, it will check if there's a static mapping configured for the host in
# the `ssh-hosts` file, if there is one, it will create the session and add
# the mapping at the end of the session name

# Define the path to your SSH config and hosts mapping file
ssh_config="$HOME/.ssh/config"
karabiner_mappings="$HOME/github/dotfiles-latest/tmux/tools/linkarzu/karabiner-mappings.sh"

# Ensure the ssh_config exists
if [ ! -f "$ssh_config" ]; then
	tmux display-message -d 3000 "SSH config file not found"
	sleep 3
	exit 1
fi

# Source the SSH hosts mappings if available
if [ -f "$karabiner_mappings" ]; then
	source "$karabiner_mappings" >/dev/null 2>&1
fi

fzf_header=$'Select an SSH host to connect to:'

# Use fzf to select a host
selected_host=$(awk '/^Host / && !/\*/ {print $2}' "$ssh_config" | fzf --height=40% --reverse --header="$fzf_header" --prompt="Type or select SSH host: ")

# Exit if no selection is made
if [[ -z $selected_host ]]; then
	echo "No host selected. Exiting."
	exit 0
fi

# Normalize the host name for session naming
selected_after_tr=$(echo "$selected_host" | tr '.-' '__')
# tmux display-message -d 3000 "selected_after_tr = $selected_after_tr"

# Check if a static mapping exists for this host so that a new session is not created
mappings_file=$karabiner_mappings
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
	tmux new-session -s "$selected_name" -d "ssh $selected_host"
fi

# Switch to the tmux session with the name derived from the selected directory
tmux switch-client -t $selected_name
