#!/usr/bin/env bash

# Sourceable helper shared by kitty-zoxide-session.sh and 560-skhdTmuxSession.sh.
# Provides:
#   - kitty_remote          talk to the main kitty instance via remote control
#   - focus_or_launch_tmux  write/reuse a kitty-session file that runs
#                           `tmux attach -t <name>` and ask kitty to switch
#                           to it, with an optional explicit project dir
#
# Do not execute this file directly; `source` it from a caller.

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}"
kitty_bin="${KITTY_BIN:-/Applications/kitty.app/Contents/MacOS/kitty}"
main_socket_script="$DOTFILES_DIR/scripts/macos/mac/misc/549-kittyMainSocket.sh"

# Resolved once at source time. kitty_remote re-resolves on every call so a
# transient /tmp/kitty-<pid> socket captured before fzf cannot disappear
# before goto_session runs.
sock="$("$main_socket_script" || true)"

kitty_remote() {
  local current_sock=""
  current_sock="$("$main_socket_script")" || return 1
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

  local project_helper="${FFMPEG_CLIPS_SCRIPTS:-${FFMPEG_CLIPS_ROOT:-$HOME/github/ffmpeg-clips}/scripts}/project_session.py"
  local project_python="${FFMPEG_CLIPS_PYTHON:-python3}"
  local portable_root="" portable_status=3
  if [[ -f "$project_helper" ]]; then
    portable_status=0
    portable_root="$("$project_python" "$project_helper" root "$tmux_session_root")" || portable_status=$?
  elif [[ -e "$tmux_session_root/livestream-project.json" || -L "$tmux_session_root/livestream-project.json" ]]; then
    printf 'Portable project session helper is missing: %s\n' "$project_helper" >&2
    return 1
  fi
  if [[ "$portable_status" -eq 0 ]]; then
    local portable_name
    portable_name="$("$project_python" "$project_helper" name "$portable_root")" || return 1
    if [[ "$tmux_session" != "$portable_name" ]]; then
      printf 'Marked project requires exact session %s, not %s. Reconcile the old session explicitly.\n' "$portable_name" "$tmux_session" >&2
      return 1
    fi
    "$project_python" "$project_helper" launch "$portable_root"
    return
  elif [[ "$portable_status" -ne 3 ]]; then
    return "$portable_status"
  fi

  local portable_binding=""
  portable_binding="$(tmux show-environment -t "=$tmux_session" FFMPEG_CLIPS_PROJECT_ID 2>/dev/null || true)"
  if [[ "$portable_binding" == FFMPEG_CLIPS_PROJECT_ID=?* ]]; then
    printf 'Portable tmux session %s has an unavailable owning root. Explicitly reconcile the old session before restoring it; refusing generic attach.\n' "$tmux_session" >&2
    return 1
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
