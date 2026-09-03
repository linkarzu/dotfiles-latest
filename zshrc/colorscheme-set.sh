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

persist_colorscheme_profile() {
  local vars_file="$HOME/github/dotfiles-latest/colorscheme/colorscheme-vars.sh"

  if [ ! -f "$vars_file" ]; then
    return 0
  fi

  local tmp_file
  local status_file
  local changed

  tmp_file="$(mktemp "${vars_file}.tmp.XXXXXX")"
  status_file="$(mktemp "${vars_file}.status.XXXXXX")"

  awk -v new_value="$colorscheme_profile" -v status_file="$status_file" '
    BEGIN { found = 0; changed = 0 }
    {
      line = $0
      trimmed = line
      sub(/^[ \t]+/, "", trimmed)
      if (!found && trimmed ~ /^colorscheme_profile=/) {
        found = 1
        desired = "colorscheme_profile=\"" new_value "\""
        if (line != desired) { changed = 1 }
        print desired
        next
      }
      print line
    }
    END {
      if (!found) {
        desired = "colorscheme_profile=\"" new_value "\""
        print desired
        changed = 1
      }
      printf "%d\n", changed > status_file
    }
  ' "$vars_file" >"$tmp_file"

  if [ -f "$status_file" ]; then
    read -r changed <"$status_file"
  fi

  if [ "$changed" = "1" ]; then
    mv "$tmp_file" "$vars_file"
  else
    rm -f "$tmp_file"
  fi

  rm -f "$status_file"
}

# Define paths
colorscheme_file="$HOME/github/dotfiles-latest/colorscheme/list/$colorscheme_profile"
active_file="$HOME/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh"

persist_colorscheme_profile

# Check if the colorscheme file exists
if [ ! -f "$colorscheme_file" ]; then
  error "Colorscheme file '$colorscheme_file' does not exist."
fi

source "$colorscheme_file"
if [ -z "$wallpaper" ]; then
  wallpaper="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Images/wallpapers/official/skyrim-dragon-4.webp"
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

generate_kitty_config() {
  kitty_conf_file="$HOME/github/dotfiles-latest/kitty/active-theme.conf"

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
cursor                $linkarzu_color24
cursor_text_color     $linkarzu_color10
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
}

generate_ghostty_config() {
  ghostty_conf_file="$HOME/github/dotfiles-latest/ghostty/ghostty-theme"

  cat >"$ghostty_conf_file" <<EOF
background = $linkarzu_color10
foreground = $linkarzu_color14

cursor-color = $linkarzu_color24

# black
palette = 0=$linkarzu_color10
palette = 8=$linkarzu_color08
# red
palette = 1=$linkarzu_color11
palette = 9=$linkarzu_color11
# green
palette = 2=$linkarzu_color02
palette = 10=$linkarzu_color02
# yellow
palette = 3=$linkarzu_color05
palette = 11=$linkarzu_color05
# blue
palette = 4=$linkarzu_color04
palette = 12=$linkarzu_color04
# purple
palette = 5=$linkarzu_color01
palette = 13=$linkarzu_color01
# aqua
palette = 6=$linkarzu_color03
palette = 14=$linkarzu_color03
# white
palette = 7=$linkarzu_color14
palette = 15=$linkarzu_color14
EOF

  echo "Ghostty configuration updated at '$ghostty_conf_file'."
}

generate_btop_config() {
  btop_conf_file="$HOME/github/dotfiles-latest/btop/themes/btop-theme.theme"

  cat >"$btop_conf_file" <<EOF
# Main background, empty for terminal default, need to be empty if you want transparent background
theme[main_bg]=""

# Main text color
theme[main_fg]="$linkarzu_color14"

# Title color for boxes
theme[title]="$linkarzu_color14"

# Highlight color for keyboard shortcuts
theme[hi_fg]="$linkarzu_color02"

# Background color of selected item in processes box
theme[selected_bg]="$linkarzu_color04"

# Foreground color of selected item in processes box
theme[selected_fg]="$linkarzu_color14"

# Color of inactive/disabled text
theme[inactive_fg]="$linkarzu_color09"

# Color of text appearing on top of graphs, i.e uptime and current network graph scaling
theme[graph_text]="$linkarzu_color14"

# Background color of the percentage meters
theme[meter_bg]="$linkarzu_color17"

# Misc colors for processes box including mini cpu graphs, details memory graph and details status text
theme[proc_misc]="$linkarzu_color01"

# Cpu box outline color
theme[cpu_box]="$linkarzu_color04"

# Memory/disks box outline color
theme[mem_box]="$linkarzu_color02"

# Net up/down box outline color
theme[net_box]="$linkarzu_color03"

# Processes box outline color
theme[proc_box]="$linkarzu_color05"

# Box divider line and small boxes line color
theme[div_line]="$linkarzu_color17"

# Temperature graph colors
theme[temp_start]="$linkarzu_color01"
theme[temp_mid]="$linkarzu_color16"
theme[temp_end]="$linkarzu_color06"

# CPU graph colors
theme[cpu_start]="$linkarzu_color01"
theme[cpu_mid]="$linkarzu_color05"
theme[cpu_end]="$linkarzu_color02"

# Mem/Disk free meter
theme[free_start]="$linkarzu_color18"
theme[free_mid]="$linkarzu_color16"
theme[free_end]="$linkarzu_color06"

# Mem/Disk cached meter
theme[cached_start]="$linkarzu_color03"
theme[cached_mid]="$linkarzu_color05"
theme[cached_end]="$linkarzu_color08"

# Mem/Disk available meter
theme[available_start]="$linkarzu_color21"
theme[available_mid]="$linkarzu_color01"
theme[available_end]="$linkarzu_color04"

# Mem/Disk used meter
theme[used_start]="$linkarzu_color19"
theme[used_mid]="$linkarzu_color05"
theme[used_end]="$linkarzu_color02"

# Download graph colors
theme[download_start]="$linkarzu_color01"
theme[download_mid]="$linkarzu_color02"
theme[download_end]="$linkarzu_color05"

# Upload graph colors
theme[upload_start]="$linkarzu_color08"
theme[upload_mid]="$linkarzu_color16"
theme[upload_end]="$linkarzu_color06"

# Process box color gradient for threads, mem and cpu usage
theme[process_start]="$linkarzu_color03"
theme[process_mid]="$linkarzu_color02"
theme[process_end]="$linkarzu_color06"
EOF

  echo "Btop configuration updated at '$btop_conf_file'."
}

generate_starship_config() {
  # Define the path to the active-config.toml
  starship_conf_file="$HOME/github/dotfiles-latest/starship-config/active-config.toml"

  # Generate the Starship configuration file
  cat >"$starship_conf_file" <<EOF
# This will show the time on a 2nd line
# Add a "\\" at the end of an item, if you want the next item to show on the same line
# U+E000 is the custom Linkarzu Logo glyph in ./logo-font/LinkarzuLogo-Regular.ttf
format = """
\$username\\
\$hostname\\
\$time\\
[\\uE000 ](${linkarzu_color02} bold)\\
\$all\\
\$directory
\$character
"""

[character]
success_symbol = '[❯❯❯❯](${linkarzu_color02} bold)'
error_symbol = '[XXXX](${linkarzu_color11} bold)'
vicmd_symbol = '[❮❮❮❮](${linkarzu_color04} bold)'

[battery]
disabled = true

[gcloud]
disabled = true

[time]
style = '${linkarzu_color04} bold'
disabled = false
format = '[\[\$time\]](\$style)'
# https://docs.rs/chrono/0.4.7/chrono/format/strftime/index.html
# %T	00:34:60	Hour-minute-second format. Same to %H:%M:%S.
# time_format = '%y/%m/%d %T'
time_format = '%y/%m/%d'

# For this to show up correctly, you need to have cluster access
# So your ~/.kube/config needs to be configured on the local machine
[kubernetes]
disabled = true
# context = user@cluster
# format = '[\$user@\$cluster \(\$namespace\)](${linkarzu_color05}) '
# format = '[\$cluster \(\$namespace\)](${linkarzu_color05}) '
# Apply separate colors for cluster and namespace
format = '[\$cluster](${linkarzu_color05} bold) [\$namespace](${linkarzu_color02} bold) '
# format = 'on [⛵ (\$user on )(\$cluster in )\$context \(\$namespace\)](dimmed green) '
# Only dirs that have this file inside will show the kubernetes prompt
# detect_files = ['900-detectkubernetes.sh']
# detect_env_vars = ['STAR_USE_KUBE']
# contexts = [
#   { context_pattern = "dev.local.cluster.k8s", style = "green", symbol = "💔 " },
# ]

[username]
style_user = '${linkarzu_color04} bold'
style_root = 'white bold'
format = '[\$user](\$style).@.'
show_always = true

[hostname]
ssh_only = true
format = '(white bold)[\$hostname](${linkarzu_color02} bold)'

[directory]
style = '${linkarzu_color03} bold'
truncation_length = 0
truncate_to_repo = false

[ruby]
detect_variables = []
detect_files = ['Gemfile', '.ruby-version']
EOF

  echo "Starship configuration updated at '$starship_conf_file'."
}

reload_kitty_colors() {
  local kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
  local theme_file="$HOME/github/dotfiles-latest/kitty/active-theme.conf"
  local socket
  local updated=0

  if [ ! -x "$kitty_bin" ]; then
    echo "Warning: Kitty is not installed; skipping live color reload." >&2
    return 0
  fi

  for socket in /tmp/kitty-*; do
    [ -S "$socket" ] || continue
    if timeout 5 "$kitty_bin" @ --to "unix:${socket}" \
      set-colors --all --configured "$theme_file" >/dev/null 2>&1; then
      updated=$((updated + 1))
    else
      echo "Warning: Could not reload Kitty colors through '$socket'." >&2
    fi
  done

  echo "Reloaded colors in $updated running Kitty instance(s)."
}

reload_opencode_colors() {
  local kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
  local socket
  local kitty_state
  local window_ids
  local window_id
  local updated=0

  if [ ! -x "$kitty_bin" ]; then
    echo "Warning: Kitty is not installed; skipping OpenCode color reload." >&2
    return 0
  fi

  for socket in /tmp/kitty-*; do
    [ -S "$socket" ] || continue

    if ! kitty_state="$(
      timeout 5 "$kitty_bin" @ --to "unix:${socket}" ls 2>/dev/null
    )"; then
      echo "Warning: Could not inspect Kitty windows through '$socket' for OpenCode." >&2
      continue
    fi

    if ! window_ids="$(
      printf '%s' "$kitty_state" | /usr/bin/python3 -c '
import json
import os
import sys

for os_window in json.load(sys.stdin):
    for tab in os_window.get("tabs", []):
        for window in tab.get("windows", []):
            if not window.get("in_alternate_screen"):
                continue
            for process in window.get("foreground_processes", []):
                command = process.get("cmdline") or []
                if command and os.path.basename(command[0]) == "opencode":
                    print(window["id"])
                    break
'
    )"; then
      echo "Warning: Could not parse Kitty windows from '$socket' for OpenCode." >&2
      continue
    fi

    while IFS= read -r window_id; do
      [ -n "$window_id" ] || continue
      if timeout 5 "$kitty_bin" @ --to "unix:${socket}" \
        send-text --match "id:${window_id}" '\e[?997;1n' >/dev/null 2>&1; then
        updated=$((updated + 1))
      else
        echo "Warning: Could not notify OpenCode in Kitty window '$window_id'." >&2
      fi
    done <<<"$window_ids"
  done

  echo "Notified $updated running OpenCode TUI instance(s) of the terminal color change."
}

reload_neovim_colors() {
  local runtime_tmp="${TMPDIR:-/tmp}"
  local server_dir="${runtime_tmp%/}/nvim.${USER}"
  local server
  local updated=0
  local remote_expr='luaeval("(function() _G.linkarzu_colors = require(\"config.colors\"); package.loaded[\"config.colors\"] = nil; return require(\"config.colors\").reload() end)()")'

  if ! command -v nvim >/dev/null 2>&1; then
    echo "Warning: Neovim is not installed; skipping live color reload." >&2
    return 0
  fi

  for server in "$server_dir"/*/neobean.*; do
    [ -S "$server" ] || continue
    if timeout 5 nvim --server "$server" --remote-expr "$remote_expr" >/dev/null 2>&1; then
      updated=$((updated + 1))
    else
      echo "Warning: Could not reload Neobean colors through '$server'." >&2
    fi
  done

  echo "Reloaded colors in $updated running Neobean instance(s)."
}

sync_helium_wallpaper() {
  local wallpaper_path="$1"
  local helium_profile="$HOME/Library/Application Support/net.imput.helium/Default"
  local helium_background="$helium_profile/background.jpg"
  local helium_pending="$helium_profile/.linkarzu-theme-update-pending"
  local helium_state="$helium_profile/.linkarzu-wallpaper-state"
  local helium_helper="$HOME/github/dotfiles-latest/colorscheme/set-helium-wallpaper.applescript"
  local native_wallpaper="$wallpaper_path"
  local temp_dir=""
  local source_hash
  local background_hash
  local cached_source_hash=""
  local cached_background_hash=""
  local native_updated=false
  local attempt
  local reloaded

  if [ ! -f "$wallpaper_path" ]; then
    echo "Warning: Could not update Helium; wallpaper does not exist: '$wallpaper_path'." >&2
    return 0
  fi
  if [ ! -d "$helium_profile" ]; then
    echo "Warning: Helium's default profile was not found; skipping wallpaper sync." >&2
    return 0
  fi
  source_hash="$(shasum -a 256 "$wallpaper_path")"
  source_hash="${source_hash%% *}"
  if [ -f "$helium_state" ]; then
    read -r cached_source_hash cached_background_hash <"$helium_state"
  fi
  if [ -f "$helium_background" ] && [ "$source_hash" = "$cached_source_hash" ] && [ ! -f "$helium_pending" ]; then
    background_hash="$(shasum -a 256 "$helium_background")"
    background_hash="${background_hash%% *}"
    if [ "$background_hash" = "$cached_background_hash" ]; then
      return 0
    fi
  fi

  if ! pgrep -x Helium >/dev/null 2>&1; then
    if cp "$wallpaper_path" "$helium_background"; then
      rm -f "$helium_state"
      touch "$helium_pending"
      echo "Helium wallpaper updated; adaptive colors will be applied the next time the selector runs with Helium open."
    else
      echo "Warning: Could not update Helium's wallpaper." >&2
    fi
    return 0
  fi

  case "${wallpaper_path##*.}" in
    jpg | JPG | jpeg | JPEG | png | PNG | gif | GIF) ;;
    *)
      if command -v magick >/dev/null 2>&1; then
        temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/helium-wallpaper.XXXXXX")"
        native_wallpaper="$temp_dir/wallpaper.png"
        if ! magick "$wallpaper_path" "$native_wallpaper"; then
          native_wallpaper="$wallpaper_path"
        fi
      fi
      ;;
  esac

  if timeout 20 osascript "$helium_helper" "$native_wallpaper" >/dev/null 2>&1; then
    for attempt in 1 2 3 4 5 6 7 8 9 10; do
      if cmp -s "$native_wallpaper" "$helium_background"; then
        native_updated=true
        break
      fi
      sleep 0.1
    done
  fi

  if [ "$native_updated" != true ]; then
    if [ -n "$temp_dir" ]; then
      rm -f "$native_wallpaper"
      rmdir "$temp_dir"
    fi
    echo "Warning: Helium's native wallpaper selection failed; enable View > Developer > Allow JavaScript from Apple Events." >&2
    if cp "$wallpaper_path" "$helium_background"; then
      rm -f "$helium_state"
      touch "$helium_pending"
      echo "Helium wallpaper updated without adaptive colors."
    fi
    return 0
  fi

  if [ "$native_wallpaper" != "$wallpaper_path" ]; then
    cp "$wallpaper_path" "$helium_background"
  fi
  if [ -n "$temp_dir" ]; then
    rm -f "$native_wallpaper"
    rmdir "$temp_dir"
  fi
  rm -f "$helium_pending"
  background_hash="$(shasum -a 256 "$helium_background")"
  background_hash="${background_hash%% *}"
  printf '%s %s\n' "$source_hash" "$background_hash" >"$helium_state"
  echo "Helium wallpaper and adaptive colors updated."

  if reloaded="$(
    timeout 10 osascript \
      -e 'tell application "Helium"' \
      -e 'set reloadedTabs to 0' \
      -e 'repeat with browserWindow in every window' \
      -e 'set activeIndex to active tab index of browserWindow' \
      -e 'repeat with browserTab in every tab of browserWindow' \
      -e 'set tabURL to URL of browserTab' \
      -e 'if (tabURL starts with "chrome://newtab") or (tabURL starts with "chrome://new-tab-page") or (tabURL is "about:newtab") then' \
      -e 'reload browserTab' \
      -e 'set reloadedTabs to reloadedTabs + 1' \
      -e 'end if' \
      -e 'end repeat' \
      -e 'set active tab index of browserWindow to activeIndex' \
      -e 'end repeat' \
      -e 'return reloadedTabs' \
      -e 'end tell' 2>/dev/null
  )"; then
    echo "Reloaded $reloaded Helium new-tab page(s)."
  else
    echo "Warning: Helium's wallpaper changed, but its new-tab pages could not be reloaded." >&2
  fi
}

# If there's an update, replace the active colorscheme and perform necessary actions
if [ "$UPDATED" = true ]; then
  echo "Updating active colorscheme to '$colorscheme_profile'."

  # Replace the contents of active-colorscheme.sh
  cp "$colorscheme_file" "$active_file"

  # I want to copy the colorscheme_file to my neobean config for folks that
  # don't use my colorscheme selector
  cp "$colorscheme_file" "$HOME/github/dotfiles-latest/neovim/neobean/lua/config/active-colorscheme.sh"

  # # Set the tmux colors
  # $HOME/github/dotfiles-latest/tmux/tools/linkarzu/set_tmux_colors.sh
  # tmux source-file ~/.tmux.conf
  # echo "Tmux colors set and tmux configuration reloaded."

  # Set sketchybar colors
  sketchybar --reload

  generate_starship_config

  # Generate the ghostty config file
  generate_ghostty_config
  # osascript $HOME/github/dotfiles-latest/ghostty/reload-config.scpt

  generate_btop_config

  # Generate the Kitty configuration file
  generate_kitty_config
  reload_kitty_colors
  reload_neovim_colors

  # Set the wallpaper
  wallpaper_cache="$HOME/github/dotfiles-latest/colorscheme/active/active-wallpaper"
  last_wallpaper=""
  if [ -f "$wallpaper_cache" ]; then
    last_wallpaper="$(cat "$wallpaper_cache")"
  fi

  if [ "$wallpaper" != "$last_wallpaper" ]; then
    /usr/bin/python3 \
      "$HOME/github/dotfiles-latest/colorscheme/set-wallpaper-all-spaces.py" \
      "$wallpaper"
    printf '%s' "$wallpaper" >"$wallpaper_cache"
  fi
  # Also restart yabai for my skitty-notes colors
  ~/github/dotfiles-latest/yabai/yabai_restart.sh

  # Keep this final so OpenCode refreshes after every generated file is ready.
  reload_opencode_colors
fi

# Keep Helium in sync even when reapplying the already-active profile.
sync_helium_wallpaper "$wallpaper"
