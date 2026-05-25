#!/usr/bin/env bash

set -euo pipefail

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"

# QAT windows create their own /tmp/kitty-* sockets. External commands that use
# the first socket from `ls /tmp/kitty-*` can accidentally control a floating QAT
# instead of the main kitty app. Return only the socket owned by the main kitty
# process.
for sock in /tmp/kitty-*; do
  [[ -S "$sock" ]] || continue
  pid="${sock##*-}"
  command="$(ps -p "$pid" -o command= 2>/dev/null || true)"

  if [[ "$command" == "$kitty_bin"* ]]; then
    printf '%s\n' "$sock"
    exit 0
  fi
done

echo "No main kitty socket found." >&2
exit 1
