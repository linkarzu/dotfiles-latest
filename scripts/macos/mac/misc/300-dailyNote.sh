#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh
# ~/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh

# # I tried replacing BetterTouchTool with this, never worked, so fuck it
# # Bring the app to the foreground if it is already open. If not open, launch it
# osascript -e 'tell application "kitty" to activate'
# sleep 0.3
# # Then when I'm in kitty, I need to press ctrl+b and then the number 1 by itself
# # That will execute the tmux command that I need
# osascript -e 'tell application "System Events" to keystroke "b" using {control down}'
# sleep 0.3
# osascript -e 'tell application "System Events" to keystroke "1"'
# sleep 0.3

# Specify below the directory in which you want to create your daily note
main_note_dir=~/github/obsidian_main/250-daily

# Get current date components
current_year=$(date +"%Y")
current_month_num=$(date +"%m")
current_month_abbr=$(date +"%b")
current_day=$(date +"%d")
current_weekday=$(date +"%A")

# Construct the directory structure and filename
note_dir=${main_note_dir}/${current_year}/${current_month_num}-${current_month_abbr}
note_name=${current_year}-${current_month_num}-${current_day}-${current_weekday}
full_path=${note_dir}/${note_name}.md
# Use note name as the session name
tmux_session_name=${note_name}

# Check if the directory exists, if not, create it
if [ ! -d "$note_dir" ]; then
  mkdir -p "$note_dir"
fi

# Create the daily note if it does not already exist
if [ ! -f "$full_path" ]; then
  cat <<EOF >"$full_path"
# Contents

<!-- toc -->

- [Daily note](#daily-note)

<!-- tocstop -->

## Daily note
EOF
fi

###############################################################################
#                      Daily note with Kitty Sessions
###############################################################################

kitty_sess_file="$HOME/github/dotfiles-latest/kitty/sessions/daily.kitty-session"
date_path="${current_year}/${current_month_num}-${current_month_abbr}"

# If today's date_path exists in the session file, just jump to the session
if grep -Fq "$date_path" "$kitty_sess_file"; then
  kitten @ action goto_session "$kitty_sess_file"
  exit 0
fi

# If we reach this point, we need to update the daily note kitty session file
# Extract the current directory from the first 'cd …' line in the session file
current_dir_in_file="$(awk '/^cd[[:space:]]/ {print $2; exit}' "$kitty_sess_file")"

# Escape slashes and '&' for sed (BSD compatible)
old_esc="$(printf '%s' "$current_dir_in_file" | sed -e 's/[\/&]/\\&/g')"
new_esc="$(printf '%s' "$note_dir" | sed -e 's/[\/&]/\\&/g')"

# Replace ALL occurrences of the old directory with the new note_dir (affects cd line and launch path)
tmp_file="${kitty_sess_file}.tmp"
sed -E "s|$old_esc|$new_esc|g" "$kitty_sess_file" >"$tmp_file" && mv "$tmp_file" "$kitty_sess_file"

# Switch to the (updated) session
kitten @ action goto_session "$kitty_sess_file" || echo "WARN: goto_session failed after cd update"

###############################################################################
#                      Daily note with Tmux Sessions
###############################################################################

# # Check if a tmux session with the note name already exists
# if ! tmux has-session -t="$tmux_session_name" 2>/dev/null; then
#   # Create a new tmux session with the note name in detached mode and start
#   # neovim with the daily note, cursor at the last line
#   # + tells neovim to execute a command after opening and G goes to last line
#   # Opened neovim with export NVIM_APPNAME='neobean' && nvim lamw25wmal
#   # Otherwise the instance that was opened always had plugin updates, even though it was neobean
#   # tmux new-session -d -s "$tmux_session_name" -c "$note_dir" "NVIM_APPNAME=neobean nvim +norm\ Go +startinsert $full_path"
#   tmux new-session -d -s "$tmux_session_name" -c "$note_dir" "export MD_HEADING_BG=transparent && NVIM_APPNAME=neobean nvim +norm\ G $full_path"
#   # tmux new-session -d -s "$tmux_session_name" "nvim +norm\ G $full_path"
#   # Create a new tmux session with the note name in detached mode and start neovim with the daily note
#   # tmux new-session -d -s "$tmux_session_name" "nvim $full_path"
# fi
#
# # Check if neovim is running, if not open it
# if ! tmux list-panes -t "$tmux_session_name" -F "#{pane_current_command}" | grep -q "nvim"; then
#   tmux send-keys -t "$tmux_session_name" "NVIM_APPNAME=neobean nvim" C-m
#   tmux send-keys -t "$tmux_session_name" "s"
# fi
#
# # Switch to the tmux session with the note name
# tmux switch-client -t "$tmux_session_name"
