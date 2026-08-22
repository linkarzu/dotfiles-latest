#!/usr/bin/env bash
set -euo pipefail

audio_dir="$HOME/github/dotfiles-private/scripts/macos/mac/obs/set-audio-application/py"
pid_file="${TMPDIR:-/tmp}/obs-brave-audio-selector.pid"
wait_pid=""

cleanup() {
  if [[ -n "$wait_pid" ]]; then
    kill "$wait_pid" 2>/dev/null || true
  fi
  if [[ -f "$pid_file" && "$(<"$pid_file")" == "$$" ]]; then
    rm -f "$pid_file"
  fi
}

if [[ "${1:-}" == "--wait" ]]; then
  if [[ -f "$pid_file" ]]; then
    previous_pid="$(<"$pid_file")"
    previous_command="$(ps -p "$previous_pid" -o command= 2>/dev/null || true)"
    if [[ "$previous_command" == *"315-fixObsAudio.sh --wait"* ]]; then
      kill "$previous_pid" 2>/dev/null || true
    fi
  fi
  printf '%s\n' "$$" >"$pid_file"
  trap cleanup EXIT INT TERM
  wait_started="$SECONDS"
  python3 "$audio_dir/wait-for-audio-output.py" "Brave Browser" &
  wait_pid="$!"
  wait "$wait_pid"
  wait_pid=""
  printf '[timing] Brave audio detected after %ss\n' "$((SECONDS - wait_started))"
fi

selector_started="$SECONDS"
python3 "$audio_dir/select-brave-in-obs.py"
printf '[timing] OBS Properties sequence completed in %ss\n' "$((SECONDS - selector_started))"
