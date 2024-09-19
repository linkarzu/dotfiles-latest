#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/zshrc/colorscheme-set.sh
# ~/github/dotfiles-latest/zshrc/colorscheme-set.sh

# Get the colorscheme_profile from the first argument
colorscheme_profile="$1"

colorscheme_file="$HOME/github/dotfiles-latest/colorscheme/list/$colorscheme_profile"

active_folder="$HOME/github/dotfiles-latest/colorscheme/active"
mkdir -p "$active_folder"

# Check if the colorscheme file exists
if [ ! -f "$colorscheme_file" ]; then
  echo "Error: colorscheme $colorscheme_file does not exist."
fi

# Get the active file (assuming there's only one file in the active folder)
active_file=$(ls "$active_folder" | head -n 1)
if [ -z "$active_file" ]; then
  echo "Error: No colorscheme active file found in $active_folder."
fi
active_file="$active_folder/$active_file"

# I diff the files in case that the colorscheme being used is updated,
# otherwise if I just compare names those changes won't be picked up
if ! diff -q "$active_file" "$colorscheme_file" >/dev/null; then
  # Remove everything inside the active_folder in case files were added manually
  rm -f "$active_folder"/*
  # If the contents are different, replace the active file
  cp "$colorscheme_file" "$active_folder"
  echo "Updated active colorscheme to $(basename "$colorscheme_file")"

  # Source the active colors file to load the variables
  source "$colorscheme_file"

  # Generate the Kitty configuration file
  kitty_conf_file="$HOME/github/dotfiles-latest/kitty/active-theme.conf"
  {
    echo "foreground            $linkarzu_color14"
    echo "background            $linkarzu_color10"
    echo "selection_foreground  $linkarzu_color14"
    echo "selection_background   $linkarzu_color16"
    echo "url_color             $linkarzu_color03"
    echo "# black"
    echo "color0                $linkarzu_color10"
    echo "color8                $linkarzu_color08"
    echo "# red"
    echo "color1                $linkarzu_color11"
    echo "color9                $linkarzu_color11"
    echo "# green"
    echo "color2                $linkarzu_color02"
    echo "color10               $linkarzu_color02"
    echo "# yellow"
    echo "color3                $linkarzu_color05"
    echo "color11               $linkarzu_color05"
    echo "# blue"
    echo "color4                $linkarzu_color04"
    echo "color12               $linkarzu_color04"
    echo "# magenta"
    echo "color5                $linkarzu_color01"
    echo "color13               $linkarzu_color01"
    echo "# cyan"
    echo "color6                $linkarzu_color03"
    echo "color14               $linkarzu_color03"
    echo "# white"
    echo "color7                $linkarzu_color14"
    echo "color15               $linkarzu_color14"
    echo "# Cursor colors"
    echo "cursor                $linkarzu_color02"
    echo "cursor_text_color     $linkarzu_color14"
    echo "# Tab bar colors"
    echo "active_tab_foreground  $linkarzu_color10"
    echo "active_tab_background   $linkarzu_color02"
    echo "inactive_tab_foreground $linkarzu_color03"
    echo "inactive_tab_background $linkarzu_color10"
    echo "# Marks"
    echo "mark1_foreground      $linkarzu_color10"
    echo "mark1_background      $linkarzu_color11"
    echo "# Splits/Windows"
    echo "active_border_color   $linkarzu_color04"
    echo "inactive_border_color  $linkarzu_color10"
  } >"$kitty_conf_file"

  echo "Kitty configuration updated"

  # Set the tmux colors
  ~/github/dotfiles-latest/tmux/tools/linkarzu/set_tmux_colors.sh
  tmux source-file ~/.tmux.conf

  echo
  echo "Restart the terminal for the colors to be applied"
fi
