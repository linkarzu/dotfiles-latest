#!/usr/bin/env bash

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/github/dotfiles-latest}"
HS_BIN="${HS_BIN:-$(command -v hs || true)}"
YABAI_BIN="${YABAI_BIN:-$(command -v yabai || true)}"

notify() {
  /usr/bin/osascript -e "display notification \"$1\" with title \"Display toggle\"" >/dev/null
}

fail() {
  notify "$1"
  printf '%s\n' "$1" >&2
  exit 1
}

[[ -n "$HS_BIN" ]] || fail "Hammerspoon CLI not found"
[[ -n "$YABAI_BIN" ]] || fail "yabai not found"

if [[ "${1:-}" == "--status" ]]; then
  result="$($HS_BIN -c 'print(displayMirrorToggle.status())')"
  printf '%s\n' "${result##*$'\n'}"
  exit 0
fi

result="$($HS_BIN -c '
  local ok, state = displayMirrorToggle.toggle()
  print((ok and "ok:" or "error:") .. state)
')"
result="${result##*$'\n'}"

case "$result" in
  ok:mirrored)
    expected_displays=1
    message="MacBook display mirror enabled"
    ;;
  ok:extended)
    expected_displays=2
    message="External display restored"
    ;;
  error:*)
    fail "${result#error:}"
    ;;
  *)
    fail "Unexpected Hammerspoon response: $result"
    ;;
esac

for _ in {1..50}; do
  display_count="$($YABAI_BIN -m query --displays 2>/dev/null | jq -r 'length' 2>/dev/null || true)"
  [[ "$display_count" == "$expected_displays" ]] && break
  sleep 0.1
done

[[ "${display_count:-}" == "$expected_displays" ]] || fail "Timed out waiting for $expected_displays display(s)"

if [[ "$result" == "ok:extended" ]]; then
  "$DOTFILES_DIR/yabai/yabai_restart.sh"
else
  notify "$message"
fi
