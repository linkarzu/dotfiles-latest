#!/usr/bin/env bash

# These files have to be executable

# Lighter markdown headings
# 4 colors to the right for these ligher headings
# https://www.color-hex.com/color/987afb
#
# Given that color A (#987afb) becomes color B (#5b4996) when darkened 4 steps
# to the right, apply the same darkening ratio/pattern to calculate what color
# C (#37f499) becomes when darkened 4 steps to the right.
#
# Markdown heading 1 - color04
linkarzu_color18=#494949
# Markdown heading 2 - color02
linkarzu_color19=#2a2a2a
# Markdown heading 3 - color03
linkarzu_color20=#1a1a1a
# Markdown heading 4 - color01
linkarzu_color21=#7f6900
# Markdown heading 5 - color05
linkarzu_color22=#5b4c00
# Markdown heading 6 - color08
linkarzu_color23=#999999
# Markdown heading foreground
# usually set to color10 which is the terminal background
linkarzu_color26=#000000

linkarzu_color04=#b2b2b2
linkarzu_color02=#939393
linkarzu_color03=#d1d1d1
linkarzu_color01=#d4b000
linkarzu_color05=#997f00
linkarzu_color08=#ffffff
linkarzu_color06=#027085

# Colors to the right from https://www.colorhexa.com
# Terminal and neovim background
linkarzu_color10=#000000
# Lualine across, 1 color to the right of background
linkarzu_color17=#0a0a0a
# Markdown codeblock, 2 to the right of background
linkarzu_color07=#141414
# Background of inactive tmux pane, 3 to the right of background
linkarzu_color25=#1f1f1f
# line across cursor, 5 to the right of background
linkarzu_color13=#333333
# Tmux inactive windows, 7 colors to the right of background
linkarzu_color15=#474747

# Comments
linkarzu_color09=#5c5c5c
# Underline spellbad
linkarzu_color11=#ff7676
# Underline spellcap
linkarzu_color12=#b7a54c
# Cursor and tmux windows text
linkarzu_color14=#ffffff
# Selected text
linkarzu_color16=#0390ac
# Cursor color
linkarzu_color24=#04d1f9

# Wallpaper for this colorscheme
wallpaper="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Images/wallpapers/batman/batman7.png"
