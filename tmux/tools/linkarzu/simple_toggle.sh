#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/tmux/tools/linkarzu/simple_toggle.sh
# ~/github/dotfiles-latest/tmux/tools/linkarzu/simple_toggle.sh

# This script assumes that TMUX_PANE_DIRECTION is either "bottom" or "right"
# If bottom, move to the top pane and maximize
# If right, move to the left pane and maximize

export TMUX_PANE_DIRECTION="right"

if [[ "$TMUX_PANE_DIRECTION" == "bottom" ]]; then
  tmux select-pane -U
elif [[ "$TMUX_PANE_DIRECTION" == "right" ]]; then
  tmux select-pane -L
fi

tmux resize-pane -Z
