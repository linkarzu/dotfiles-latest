#!/usr/bin/env bash
set -euo pipefail

audio_dir="$HOME/github/dotfiles-private/scripts/macos/mac/obs/set-audio-application/py"
pid_file="${TMPDIR:-/tmp}/obs-brave-audio-selector.pid"
audio_test_page="$HOME/github/dotfiles-private/scripts/macos/mac/obs/set-audio-application/audio-test/brave-audio-test.html"
audio_test_url="file://$audio_test_page"
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
      deadline=$((SECONDS + 5))
      while kill -0 "$previous_pid" 2>/dev/null; do
        current_command="$(ps -p "$previous_pid" -o command= 2>/dev/null || true)"
        [[ "$current_command" != *"315-fixObsAudio.sh --wait"* ]] && break
        if ((SECONDS >= deadline)); then
          printf 'Previous Brave audio watcher %s did not stop.\n' "$previous_pid" >&2
          exit 1
        fi
        sleep 0.2
      done
    fi
  fi
  printf '%s\n' "$$" >"$pid_file"
  trap cleanup EXIT INT TERM
  wait_started="$SECONDS"
  open -a "Brave Browser" "$audio_test_page"
  python3 "$audio_dir/brave-youtube-playback.py" --url "$audio_test_url" --timeout 15
  python3 "$audio_dir/wait-for-audio-output.py" "Brave Browser" --timeout 14 --stable-for 5
  printf '[timing] Brave audio detected after %ss\n' "$((SECONDS - wait_started))"
fi

selector_started="$SECONDS"
python3 "$audio_dir/select-brave-in-obs.py"
printf '[timing] OBS audio verification completed in %ss\n' "$((SECONDS - selector_started))"
