#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/linkarzu/tmux-sshonizer-agen.sh

# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

# NOTE:
# Remember to make this file executable

# Check if one argument is being provided
if [[ $# -eq 1 ]]; then
	# Use the provided argument as the selected directory
	ssh_name=$1
elif [[ $# -eq 0 ]]; then
	# Explicitly specified 0 in case someone decides to pass more than 1 argument
	# Call the ssh-select script which will open fzf to select a host
	~/github/dotfiles-latest/tmux/tools/linkarzu/ssh-select.sh
	# Debugging, uncomment below if you need to see what's being selected
	# tmux display-message -d 10000 "Directory selected via fzf: $ssh_name"
else
	# This will hopefully catch your attention
	tmux display-message -d 500 "This script expects zero or one argument."
	sleep 1
	tmux display-message -d 500 "This script expects zero or one argument."
	sleep 1
	tmux display-message -d 5000 "This script expects zero or one argument."
fi

# # Add 'ssh' to beginning of name for easier identification
# # selected_name=$ssh_name
# selected_name="SSH-$ssh_name"
# # Debugging below
# # tmux display-message -d 3000 "ssh_name: $ssh_name"
# # sleep 3
# # tmux display-message -d 3000 "selected_name: $selected_name"

# replace '.' and '-' with '_'
# I had some dirs with '-' and couldn't get the value of the corresponding var
# in the mappings file because it was interpreting the '-'
selected_after_tr=$(basename "$ssh_name" | tr '.-' '__')

# NOTE:
# For this to work, you do need to have a `karabiner-mappings.sh` file because that's what's
# going to be shown on the fzf menu
# If you delete the `karabiner-mappings.sh` file, only the `ssh_config_select.sh` script
# will work
mappings_file="$HOME/github/dotfiles-latest/tmux/tools/linkarzu/karabiner-mappings.sh"
if [ -f "$mappings_file" ]; then
	source "$mappings_file"
	# Get the value of the variable whose name matches $base_selected
	mapping_value="${!selected_after_tr}"
	selected_name="SSH-${selected_after_tr}-${mapping_value}"
else
	selected_name="SSH-$ssh_name"$selected_after_tr
fi

###############################################################################
# I commented this section, uncomment if needed
# I don't need to check if tmux is running, because by default, when I open
# my terminal, tmux opens
###############################################################################

# # Check if tmux is currently running by looking for its process
# tmux_running=$(pgrep tmux)
# # If tmux is not running and the TMUX environment variable is not set, start a new tmux session with the selected directory
# if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
# 	# I included quotes in "$ssh_name" because wasn't changing to dirs that have a space
# 	# Like the iCloud dir
# 	tmux new-session -s $ssh_name_name -c "$ssh_name"
# 	exit 0
# fi

###############################################################################

# If a tmux session with the desired name does not already exist, create it in detached mode
if ! tmux has-session -t=$selected_name 2>/dev/null; then
	# I included quotes in "$ssh_name" because wasn't changing to dirs that have a space
	# Like the iCloud dir
	tmux new-session -s "$selected_name" -d "ssh $ssh_name"
fi

# Switch to the tmux session with the name derived from the selected directory
tmux switch-client -t $selected_name
