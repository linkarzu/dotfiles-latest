#!/bin/bash

LAYOUT=$(cat ~/github/dotfiles-latest/tmux/layouts/2x3/layout.txt)
tmux select-layout "$LAYOUT"
