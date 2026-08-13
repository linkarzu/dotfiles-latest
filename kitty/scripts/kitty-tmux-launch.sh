#!/usr/bin/env bash

# Sourceable helper shared by kitty-zoxide-session.sh and 560-skhdTmuxSession.sh.
# Provides:
#   - kitty_remote          talk to the main kitty instance via remote control
#   - focus_or_launch_tmux  write/reuse a kitty-session file that runs
#                           `tmux attach -t <name>` and ask kitty to switch
#                           to it, with an optional explicit project dir
#
# Do not execute this file directly; `source` it from a caller.

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
main_socket_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh"

# Resolved once at source time. kitty_remote re-resolves on every call so a
# transient /tmp/kitty-<pid> socket captured before fzf cannot disappear
# before goto_session runs.
sock="$($main_socket_script || true)"

kitty_remote() {
  local current_sock=""
  current_sock="$($main_socket_script)" || return 1
  "$kitty_bin" @ --to "unix:${current_sock}" "$@"
}

focus_or_launch_tmux() {
  local tmux_session="$1"
  local project_dir="${2:-}"
  local tmux_session_root=""
  local cd_target=""
  local safe_session=""
  local session_name=""
  local session_dir="/tmp/kitty-zoxide-sessions"
  local session_file=""
  local current_root=""

  if [[ -n "$project_dir" ]]; then
    tmux_session_root="$project_dir"
    case "$project_dir" in
      "$HOME")
        cd_target="~"
        ;;
      "$HOME"/*)
        cd_target="~${project_dir#"$HOME"}"
        ;;
      *)
        cd_target="$project_dir"
        ;;
    esac
  else
    if ! tmux_session_root="$(tmux display-message -p -t "${tmux_session}:" '#{session_path}')" || [[ -z "$tmux_session_root" ]]; then
      echo "Could not determine the root directory for tmux session: $tmux_session" >&2
      return 1
    fi
    cd_target="$tmux_session_root"
  fi

  # Best-effort: if the session already exists in a different cwd, realign it
  # before the next attach. Skipped silently if the send fails (e.g. the only
  # pane is detached or busy with a prompt).
  if [[ -n "$project_dir" ]] && tmux has-session -t "$tmux_session" 2>/dev/null; then
    current_root="$(tmux display-message -p -t "${tmux_session}:" '#{session_path}' 2>/dev/null || true)"
    if [[ -n "$current_root" && "$current_root" != "$project_dir" ]]; then
      tmux send-keys -t "${tmux_session}:" "cd '${project_dir}'" C-m 2>/dev/null || true
    fi
  fi

  safe_session="$(printf "%s" "$tmux_session" | tr -cs 'A-Za-z0-9._-' '_')"
  session_name="tmux-${safe_session}"

  mkdir -p "$session_dir"
  session_file="${session_dir}/${session_name}.kitty-session"

  cat >"$session_file" <<EOF
layout tall
cd ${cd_target}
launch --title "${session_name}" tmux attach -t "${tmux_session}"
focus
focus_os_window
EOF

  kitty_remote action goto_session "$session_file"
}