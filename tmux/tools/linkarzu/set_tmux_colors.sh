#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/linkarzu/set_tmux_colors.sh
# ~/github/dotfiles-latest/tmux/tools/linkarzu/set_tmux_colors.sh

# Source the colorscheme file
source "$HOME/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh"

# Output tmux set commands
# I use this for my custom tmux banner on the right side
tmux set -g @catppuccin_directory_color "$linkarzu_color03"

# Color of the ACTIVE window, windows are opened with ctrl+b c
tmux set -g @catppuccin_window_current_color "$linkarzu_color03"
tmux set -g @catppuccin_window_current_background "$linkarzu_color13"

# Color of the rest of the windows that are not active
tmux set -g @catppuccin_window_default_color "$linkarzu_color15"
tmux set -g @catppuccin_window_default_background "$linkarzu_color10"

# The following 2 colors are for the lines that separate tmux splits
tmux set -g @catppuccin_pane_active_border_style "fg=$linkarzu_color03"
tmux set -g @catppuccin_pane_border_style "fg=$linkarzu_color09"

# This is the classic colored tmux bar that goes across the entire screen
# set -g @catppuccin_status_background "theme"
tmux set -g @catppuccin_status_background "$linkarzu_color10"

# default for catppuccin_session_color is #{?client_prefix,$thm_red,$thm_green}
# https://github.com/catppuccin/tmux/issues/140#issuecomment-1956204278
tmux set -g @catppuccin_session_color "#{?client_prefix,$linkarzu_color04,$linkarzu_color02}"

# This sets the color of the window text, #W shows the application name
tmux set -g @catppuccin_window_default_fill "number"
tmux set -g @catppuccin_window_default_text "#[fg=$linkarzu_color14]#W"
tmux set -g @catppuccin_window_current_fill "number"
tmux set -g @catppuccin_window_current_text "#[fg=$linkarzu_color14]#W"

# Put this option below the '@catppuccin_window_current_text' option for it to
# override it, otherwise it won't work
# I got the 'window_zoomed_flag' tip from 'DevOps Toolbox' youtuber
# https://youtu.be/GH3kpsbbERo?si=4ZoV090qVbble7np
#
# Second option shows a message when panes are syncronized
tmux set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,#[fg=$linkarzu_color04] (   ),}#{?pane_synchronized,#[fg=$linkarzu_color04] SYNCHRONIZED-PANES,}"
