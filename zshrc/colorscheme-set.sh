#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/zshrc/colorscheme-set.sh
# ~/github/dotfiles-latest/zshrc/colorscheme-set.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display error messages
error() {
  echo "Error: $1" >&2
  exit 1
}

# Ensure a colorscheme profile is provided
if [ -z "$1" ]; then
  error "No colorscheme profile provided"
fi

colorscheme_profile="$1"

# Define paths
colorscheme_file="$HOME/github/dotfiles-latest/colorscheme/list/$colorscheme_profile"
active_folder="$HOME/github/dotfiles-latest/colorscheme/active"
active_file="$active_folder/active-colorscheme.sh"
kitty_conf_file="$HOME/github/dotfiles-latest/kitty/active-theme.conf"
tmux_set_colors_script="$HOME/github/dotfiles-latest/tmux/tools/linkarzu/set_tmux_colors.sh"

mkdir -p "$active_folder"

# Check if the colorscheme file exists
if [ ! -f "$colorscheme_file" ]; then
  error "Colorscheme file '$colorscheme_file' does not exist."
fi

# If active-colorscheme.sh doesn't exist, create it
if [ ! -f "$active_file" ]; then
  echo "Active colorscheme file not found. Creating '$active_file'."
  cp "$colorscheme_file" "$active_file"
  UPDATED=true
else
  # Compare the new colorscheme with the active one
  if ! diff -q "$active_file" "$colorscheme_file" >/dev/null; then
    UPDATED=true
  else
    UPDATED=false
  fi
fi

# If there's an update, replace the active colorscheme and perform necessary actions
if [ "$UPDATED" = true ]; then
  echo "Updating active colorscheme to '$colorscheme_profile'."

  # Replace the contents of active-colorscheme.sh
  cp "$colorscheme_file" "$active_file"

  # Source the active colorscheme to load variables
  # shellcheck source=/dev/null
  source "$active_file"

  # Generate the Kitty configuration file
  cat >"$kitty_conf_file" <<EOF
foreground            $linkarzu_color14
background            $linkarzu_color10
selection_foreground  $linkarzu_color14
selection_background   $linkarzu_color16
url_color             $linkarzu_color03
# black
color0                $linkarzu_color10
color8                $linkarzu_color08
# red
color1                $linkarzu_color11
color9                $linkarzu_color11
# green
color2                $linkarzu_color02
color10               $linkarzu_color02
# yellow
color3                $linkarzu_color05
color11               $linkarzu_color05
# blue
color4                $linkarzu_color04
color12               $linkarzu_color04
# magenta
color5                $linkarzu_color01
color13               $linkarzu_color01
# cyan
color6                $linkarzu_color03
color14               $linkarzu_color03
# white
color7                $linkarzu_color14
color15               $linkarzu_color14
# Cursor colors
cursor                $linkarzu_color02
cursor_text_color     $linkarzu_color14
# Tab bar colors
active_tab_foreground  $linkarzu_color10
active_tab_background   $linkarzu_color02
inactive_tab_foreground $linkarzu_color03
inactive_tab_background $linkarzu_color10
# Marks
mark1_foreground      $linkarzu_color10
mark1_background      $linkarzu_color11
# Splits/Windows
active_border_color   $linkarzu_color04
inactive_border_color  $linkarzu_color10
EOF

  echo "Kitty configuration updated at '$kitty_conf_file'."

  # Set the tmux colors
  if [ -x "$tmux_set_colors_script" ]; then
    "$tmux_set_colors_script"
    tmux source-file ~/.tmux.conf
    echo "Tmux colors set and tmux configuration reloaded."
  else
    echo "Warning: Tmux set colors script '$tmux_set_colors_script' not found or not executable."
  fi
  echo "Restart the terminal for the colors to be applied."
fi
