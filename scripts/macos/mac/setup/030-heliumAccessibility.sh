#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

readonly LABEL="com.linkarzu.helium-accessibility"
readonly HELIUM_BINARY="/Applications/Helium.app/Contents/MacOS/Helium"
readonly PLIST_FILE="$HOME/Library/LaunchAgents/$LABEL.plist"
readonly STATE_DIR="$HOME/.local/state/helium-accessibility"
readonly DOMAIN="gui/$(id -u)"

error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<EOF
Usage:
  $(basename "$0") --install
  $(basename "$0") --uninstall
  $(basename "$0") --status

Options:
  --install    Install or replace the login LaunchAgent and start Helium
  --uninstall  Stop and remove the LaunchAgent without removing Helium
  --status     Verify that launchd owns the accessibility-enabled Helium process
  -h, --help   Show this help
EOF
}

agent_is_running() {
  /bin/launchctl print "$DOMAIN/$LABEL" 2>/dev/null | /usr/bin/grep -Eq '^[[:space:]]*state = running$'
}

wait_for_helium_exit() {
  local attempt
  for attempt in {1..50}; do
    if ! /usr/bin/pgrep -x Helium >/dev/null; then
      return 0
    fi
    /bin/sleep 0.1
  done
  return 1
}

install_agent() {
  local temporary_file

  [[ -x "$HELIUM_BINARY" ]] || error "Helium is not installed at $HELIUM_BINARY"
  [[ -d "$HOME/Library/LaunchAgents" ]] || error "LaunchAgents directory not found: $HOME/Library/LaunchAgents"
  /usr/bin/codesign --verify --deep --strict "$HELIUM_BINARY" || error "Helium code-signature verification failed."

  /bin/mkdir -p "$STATE_DIR"
  temporary_file=$(/usr/bin/mktemp "$HOME/Library/LaunchAgents/.helium-accessibility.XXXXXX")
  trap '/bin/rm -f "${temporary_file:-}"' EXIT
  cat >"$temporary_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$HELIUM_BINARY</string>
    <string>--profile-directory=Default</string>
    <string>--force-renderer-accessibility</string>
    <string>--no-startup-window</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>LimitLoadToSessionType</key>
  <string>Aqua</string>
  <key>ProcessType</key>
  <string>Interactive</string>
  <key>StandardOutPath</key>
  <string>$STATE_DIR/helium.log</string>
  <key>StandardErrorPath</key>
  <string>$STATE_DIR/helium-error.log</string>
</dict>
</plist>
EOF
  /usr/bin/plutil -lint "$temporary_file" >/dev/null || error "Generated LaunchAgent is invalid."

  /bin/launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
  if /usr/bin/pgrep -x Helium >/dev/null; then
    /usr/bin/pkill -TERM -x Helium
    wait_for_helium_exit || error "Helium did not stop before the accessibility-enabled launch."
  fi
  /bin/mv -f "$temporary_file" "$PLIST_FILE"
  trap - EXIT

  /bin/launchctl bootstrap "$DOMAIN" "$PLIST_FILE"
  for _attempt in {1..50}; do
    if agent_is_running && /usr/bin/pgrep -x Helium >/dev/null; then
      printf 'Installed and started %s\n' "$LABEL"
      printf 'LaunchAgent: %s\n' "$PLIST_FILE"
      printf 'Logs: %s\n' "$STATE_DIR"
      return 0
    fi
    /bin/sleep 0.1
  done
  error "launchd did not verify an accessibility-enabled Helium process. See $STATE_DIR/helium-error.log"
}

uninstall_agent() {
  /bin/launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
  /bin/rm -f "$PLIST_FILE"
  printf 'Stopped and removed %s\n' "$LABEL"
  printf 'Helium and its profile were left installed.\n'
}

status_agent() {
  if agent_is_running && /usr/bin/pgrep -x Helium >/dev/null; then
    printf 'LaunchAgent: loaded and running\n'
    printf 'Helium renderer accessibility: forced by launchd ProgramArguments\n'
    return 0
  fi
  if /bin/launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
    error "LaunchAgent is loaded but its Helium process is not running."
  fi
  error "LaunchAgent is not loaded. Run $(basename "$0") --install"
}

case "${1:-}" in
--install)
  [[ $# -eq 1 ]] || error '--install does not accept additional arguments.'
  install_agent
  ;;
--uninstall)
  [[ $# -eq 1 ]] || error '--uninstall does not accept additional arguments.'
  uninstall_agent
  ;;
--status)
  [[ $# -eq 1 ]] || error '--status does not accept additional arguments.'
  status_agent
  ;;
-h | --help)
  usage
  ;;
*)
  usage >&2
  exit 1
  ;;
esac
