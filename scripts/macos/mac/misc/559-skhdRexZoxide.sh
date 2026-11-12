#!/usr/bin/env bash

# Zoxide picker for Rex: the same floating fzf as 558-skhdQatZoxide.sh, but
# the folder or ssh host you pick opens as a Rex session (or switches to it)
# Needs Remote Control on in Rex: Settings > Server > Client Info

set -euo pipefail

qat_config="$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf"
kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
zoxide_script="$HOME/github/dotfiles-latest/kitty/scripts/kitty-zoxide-session.sh"
rex_session_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/554-skhdRexSession.sh"
fzf_colors_file="$HOME/github/dotfiles-latest/colorscheme/active/active-fzf-colors.sh"
script_path="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/559-skhdRexZoxide.sh"

rex_bin() {
  ls -d "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/"*/"Rex Server.app/Contents/MacOS/rex" | sort -V | tail -1
}

rex_session_exists() {
  "$(rex_bin)" ls --json | jq -e --arg label "$1" 'any(.sessions[]; .label == $label)' >/dev/null
}

open_in_rex() {
  local selected="$1"
  local label=""
  local rex
  rex="$(rex_bin)"

  if [[ "$selected" == ssh:* ]]; then
    label="ssh-$(printf "%s" "${selected#ssh:}" | tr -cs 'A-Za-z0-9._-' '_')"
    rex_session_exists "$label" || "$rex" new "$label" -- ssh "${selected#ssh:}" >/dev/null
  else
    case "$selected" in
    "~") selected="$HOME" ;;
    "~/"*) selected="$HOME/${selected#\~/}" ;;
    esac
    label="$(printf "%s" "$(basename "$selected")" | tr -cs 'A-Za-z0-9._-' '_')"
    rex_session_exists "$label" || "$rex" new --cwd "$selected" "$label" >/dev/null
    zoxide add -- "$selected" >/dev/null 2>&1 || true
  fi

  "$rex_session_script" "$label"
}

if [[ "${1:-}" == "--pick" ]]; then
  if [[ -f "$fzf_colors_file" ]]; then
    # shellcheck disable=SC1090
    source "$fzf_colors_file"
  fi

  # Folders and ssh hosts come from the kitty picker's own menu (tmux left out)
  printf '\033[2J\033[H'
  sel="$(
    "$zoxide_script" --reload | grep -v '^tmux:' |
      fzf --exact --ansi --reverse --no-multi --with-nth=2.. --no-sort \
        --tiebreak=index --header="Type to filter, enter open, esc quit" \
        --prompt="Open in Rex (zoxide + ssh) > " \
        ${linkarzu_fzf_colors:+--color="$linkarzu_fzf_colors"}
  )" || exit 0

  open_in_rex "$(printf "%s" "$sel" | awk -F'\t' '{print $1}')"
  exit 0
fi

# Each press opens the picker in its own floating kitty panel, which closes
# once a folder is picked. A background launch gets the Kitty server's PATH,
# which lacks Homebrew (fzf), so pass skhd's PATH along
sock="$("$HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh")"
"$kitty_bin" @ --to "unix:${sock}" \
  action launch --type=background --env "PATH=$PATH" kitten quick-access-terminal \
  --config "$qat_config" \
  --instance-group rex-zoxide \
  /bin/bash "$script_path" --pick
