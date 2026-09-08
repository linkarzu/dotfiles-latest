#!/usr/bin/env bash

# I use this with hyper+s+t (system task) to execute scripts in the SCRIPTS_DIR
# below. Stuff like running the yabai scripting-addition that I have to do once
# every while

# Path to the directory containing the scripts
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts/macos/mac"
fzf_colors_file="$DOTFILES_DIR/colorscheme/active/active-fzf-colors.sh"
fzf_ai_socket="${TMPDIR:-/tmp}"
fzf_ai_socket="${fzf_ai_socket%/}/linkarzu-system-task-fzf.sock"

# Expose this fzf and every nested fzf to the local AI helper. fzf's normal
# terminal interface is unchanged; the Unix socket only provides state and
# selection actions to processes running as this user.
export FZF_AI_SOCKET="${FZF_AI_SOCKET:-$fzf_ai_socket}"
printf -v fzf_listen_opt '%q' "--listen=$FZF_AI_SOCKET"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} $fzf_listen_opt"

# Ensure fzf is installed
if ! command -v fzf &>/dev/null; then
  echo "fzf is not installed. Please install it first."
  exit 1
fi

if [[ -f "$fzf_colors_file" ]]; then
  # shellcheck disable=SC1090
  source "$fzf_colors_file"
fi

# List available scripts
schemes=()
for script in "$SCRIPTS_DIR"/*.sh; do
  [[ -f "$script" ]] || continue
  schemes+=("${script##*/}")
done

# Check if any scripts available
if [ ${#schemes[@]} -eq 0 ]; then
  echo "No scripts found in $SCRIPTS_DIR."
  exit 1
fi

# Use fzf to select a script
selected_script=$(printf "%s\n" "${schemes[@]}" | fzf --height=100% --reverse --header="Type or move using arrows" --prompt="Select a script to execute > " ${linkarzu_fzf_colors:+--color="$linkarzu_fzf_colors"})

# Check if a selection was made
if [ -z "$selected_script" ]; then
  echo "No script selected."
  exit 0
fi

# Execute the selected script
"$SCRIPTS_DIR/$selected_script"
