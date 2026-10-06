#!/usr/bin/env bash

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/github/dotfiles-latest}"
HS_BIN="${HS_BIN:-$(command -v hs || true)}"
YABAI_BIN="${YABAI_BIN:-$(command -v yabai || true)}"
MIRROR_HELPER="${MIRROR_HELPER:-$DOTFILES_DIR/scripts/macos/mac/misc/displayMirrorRecovery.swift}"
# Built-in HiDPI size while mirrored; smaller means bigger text (default is 1512x982)
MIRROR_RESOLUTION="${MIRROR_RESOLUTION:-1147x745}"
[[ "$MIRROR_RESOLUTION" =~ ^([0-9]+)x([0-9]+)$ ]] || {
  printf 'Invalid MIRROR_RESOLUTION: %s\n' "$MIRROR_RESOLUTION" >&2
  exit 1
}
mirror_w="${BASH_REMATCH[1]}"
mirror_h="${BASH_REMATCH[2]}"

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
[[ -x "$MIRROR_HELPER" ]] || fail "Display mirror helper not found"

if [[ "${1:-}" == "--status" ]]; then
  "$MIRROR_HELPER" status
  exit 0
fi

state="$("$MIRROR_HELPER" status)" || fail "Could not read display mirror state"
case "$state" in
mirrored)
  "$MIRROR_HELPER" unmirror || fail "Could not stop display mirroring"
  expected_displays=2
  message="External display restored"
  ;;
extended)
  result="$("$HS_BIN" -c '
      local ok, response = displayMirrorToggle.start()
      print((ok and "ok:" or "error:") .. response)
    ')" || fail "Hammerspoon could not start display mirroring"
  result="${result##*$'\n'}"
  [[ "$result" == "ok:mirrored" ]] || fail "${result#error:}"
  expected_displays=1
  message="MacBook display mirror enabled"
  ;;
*)
  fail "Unexpected display mirror state: $state"
  ;;
esac

for _ in {1..50}; do
  display_count="$("$YABAI_BIN" -m query --displays 2>/dev/null | jq -r 'length' 2>/dev/null || true)"
  [[ "$display_count" == "$expected_displays" ]] && break
  sleep 0.1
done

[[ "${display_count:-}" == "$expected_displays" ]] || fail "Timed out waiting for $expected_displays display(s)"

if [[ "$state" == "mirrored" ]]; then
  result="$("$HS_BIN" -c '
    local ok, response = displayMirrorToggle.restoreMode()
    print((ok and "ok:" or "error:") .. response)
  ')" || fail "Hammerspoon could not restore built-in display mode"
  result="${result##*$'\n'}"
  [[ "$result" == ok:* ]] || fail "${result#error:}"
  "$DOTFILES_DIR/yabai/yabai_restart.sh"
else
  result="$("$HS_BIN" -c "
    local ok, response = displayMirrorToggle.setMirrorMode($mirror_w, $mirror_h)
    print((ok and 'ok:' or 'error:') .. response)
  ")" || fail "Hammerspoon could not set mirror resolution"
  result="${result##*$'\n'}"
  [[ "$result" == ok:* ]] || fail "${result#error:}"
  # yabairc picks its paddings from the resolution, so reload it for this mode
  "$DOTFILES_DIR/yabai/yabai_restart.sh"
  notify "$message"
fi
