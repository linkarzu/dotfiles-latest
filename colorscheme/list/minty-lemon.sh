#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/colorscheme/list/linkarzu-colors.sh
# ~/github/dotfiles-latest/colorscheme/list/linkarzu-colors.sh

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
linkarzu_color18=#20925b
# Markdown heading 2 - color02
linkarzu_color19=#027d95
# Markdown heading 3 - color03
linkarzu_color20=#4d9472
# Markdown heading 4 - color01
linkarzu_color21=#2f8696
# Markdown heading 5 - color05
linkarzu_color22=#029494
# Markdown heading 6 - color08
# Also inactive tmux window, make it 6 darker to the right
linkarzu_color23=#1f645e
# Markdown heading foreground
# usually set to color10 which is the terminal background
linkarzu_color26=#0D1116

linkarzu_color04=#37f499
linkarzu_color02=#04d1f9
linkarzu_color03=#81f8bf
linkarzu_color01=#4fe0fc
linkarzu_color05=#04F9F8
linkarzu_color08=#4ffced
linkarzu_color06=#9deefd

# Colors to the right from https://www.colorhexa.com
# Terminal and neovim background
linkarzu_color10=#0D1116
# Lualine across, 1 color to the right of background
linkarzu_color17=#141b22
# Markdown codeblock, 2 to the right of background
linkarzu_color07=#1c242f
# Background of inactive tmux pane, 3 to the right of background
linkarzu_color25=#232e3b
# line across cursor, 5 to the right of background
linkarzu_color13=#314154
# Tmux inactive windows, 7 colors to the right of background
linkarzu_color15=#013e4a

# Comments
linkarzu_color09=#a5afc2
# Underline spellbad, color02 7 tones to the left in colorhexa
linkarzu_color11=#026072
# Underline spellcap, color04 7 tones to the left in colorhexa
linkarzu_color12=#089954
# Cursor and tmux windows text
linkarzu_color14=#ebfafa
# Selected text
linkarzu_color16=#ccfce5
# Cursor color, color04 9 tones to the left in colorhexa
linkarzu_color24=#06743f
