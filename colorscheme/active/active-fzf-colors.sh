#!/usr/bin/env bash

colorscheme_file="$HOME/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh"

if [[ -f "$colorscheme_file" ]]; then
  # shellcheck disable=SC1090
  source "$colorscheme_file"
fi

linkarzu_fzf_colors="bg:${linkarzu_color10},fg:${linkarzu_color14}"
linkarzu_fzf_colors+=",hl:${linkarzu_color03},hl+:${linkarzu_color03}"
linkarzu_fzf_colors+=",info:${linkarzu_color09},header:${linkarzu_color09}"
linkarzu_fzf_colors+=",prompt:${linkarzu_color02}"
linkarzu_fzf_colors+=",pointer:${linkarzu_color11}"
linkarzu_fzf_colors+=",marker:${linkarzu_color12}"
linkarzu_fzf_colors+=",spinner:${linkarzu_color13}"
linkarzu_fzf_colors+=",fg+:${linkarzu_color14}"
linkarzu_fzf_colors+=",bg+:${linkarzu_color13}"
linkarzu_fzf_colors+=",gutter:${linkarzu_color10}"

export linkarzu_fzf_colors
