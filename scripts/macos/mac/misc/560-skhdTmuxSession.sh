#!/usr/bin/env bash

# Ensure a tmux session exists for a project and focus the kitty session that
# wraps it. Mirrors 550-skhdSession.sh for tmux.
#
# Usage: 560-skhdTmuxSession.sh <project-dir-or-video-file>
#
# If the argument is a file, the project dir is its parent. The tmux session
# name is derived from the project dir basename, matching the convention used
# by ffmpeg-clips run-workflow.sh's session_name_for. The project dir is also
# passed to the helper so the generated kitty-session file's `cd` line points
# there -- new tabs opened on that kitty session will start in the project
# dir.

set -euo pipefail

input="${1:-}"

if [[ -z "$input" ]]; then
  echo "usage: $0 <project-dir-or-video-file>" >&2
  exit 1
fi

case "$input" in
  "~")
    input="$HOME"
    ;;
  "~/"*)
    input="$HOME/${input#\~/}"
    ;;
esac

if [[ "$input" != /* ]]; then
  echo "Path must be absolute: $input" >&2
  exit 1
fi

if [[ -f "$input" ]]; then
  project_dir="$(dirname "$input")"
elif [[ -d "$input" ]]; then
  project_dir="$input"
else
  echo "Not a file or directory: $input" >&2
  exit 1
fi

session="$(basename "$project_dir")"
session="$(printf '%s' "$session" | tr -c '[:alnum:]_-' '_')"
[[ -n "$session" ]] || session="ffmpeg-clips"

source "$HOME/github/dotfiles-latest/kitty/scripts/kitty-tmux-launch.sh"

if [[ -z "${sock:-}" ]]; then
  echo "No kitty sockets found in /tmp (kitty not running, or remote control not available)." >&2
  exit 1
fi

if ! tmux has-session -t "$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -c "$project_dir"
fi

focus_or_launch_tmux "$session" "$project_dir"