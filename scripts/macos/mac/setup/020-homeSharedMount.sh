#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

readonly LABEL="com.linkarzu.home-shared-mount"
readonly SMB_URL="smb://samba.home.linkarzu.com/home-shared"
readonly MOUNT_POINT="/Volumes/home-shared"
readonly PLIST_FILE="$HOME/Library/LaunchAgents/$LABEL.plist"
readonly STATE_DIR="$HOME/.local/state/home-shared-mount"
readonly SCRIPT_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"

error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<EOF
Usage:
  $(basename "$0") --install
  $(basename "$0") --uninstall
  $(basename "$0") --mount
  $(basename "$0") --status

Options:
  --install    Install or replace the macOS LaunchAgent and mount the share
  --uninstall  Stop and remove the LaunchAgent; leave any active mount intact
  --mount      Mount $SMB_URL when it is not already mounted
  --status     Show LaunchAgent and mount status
  -h, --help   Show this help

Authentication is read by macOS from Keychain. No SMB credentials are stored
in this script or in the generated LaunchAgent.
EOF
}

is_mounted() {
  /sbin/mount | /usr/bin/grep -Fq " on $MOUNT_POINT (smbfs"
}

mount_share() {
  local attempt

  if is_mounted; then
    printf 'Already mounted: %s\n' "$MOUNT_POINT"
    return 0
  fi

  /usr/bin/osascript - "$SMB_URL" <<'APPLESCRIPT'
on run arguments
  mount volume (item 1 of arguments)
end run
APPLESCRIPT

  for attempt in {1..15}; do
    if is_mounted; then
      printf 'Mounted: %s\n' "$MOUNT_POINT"
      return 0
    fi
    /bin/sleep 1
  done

  error "macOS did not mount $SMB_URL at $MOUNT_POINT"
}

install_agent() {
  local temporary_file domain

  [[ -d "$HOME/Library/LaunchAgents" ]] || error "LaunchAgents directory not found: $HOME/Library/LaunchAgents"
  [[ -x "$SCRIPT_PATH" ]] || error "Setup script must be executable: $SCRIPT_PATH"

  /bin/mkdir -p "$STATE_DIR"
  temporary_file=$(/usr/bin/mktemp "$HOME/Library/LaunchAgents/.home-shared-mount.XXXXXX")
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
    <string>$SCRIPT_PATH</string>
    <string>--mount</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>30</integer>
  <key>ProcessType</key>
  <string>Background</string>
  <key>StandardOutPath</key>
  <string>$STATE_DIR/mount.log</string>
  <key>StandardErrorPath</key>
  <string>$STATE_DIR/mount-error.log</string>
</dict>
</plist>
EOF
  /usr/bin/plutil -lint "$temporary_file" >/dev/null || error 'Generated LaunchAgent is invalid.'
  /bin/mv -f "$temporary_file" "$PLIST_FILE"
  trap - EXIT

  domain="gui/$(id -u)"
  /bin/launchctl bootout "$domain/$LABEL" >/dev/null 2>&1 || true
  /bin/launchctl bootstrap "$domain" "$PLIST_FILE"
  /bin/launchctl print "$domain/$LABEL" >/dev/null || error "Could not load $LABEL"
  /bin/launchctl kickstart -k "$domain/$LABEL"

  printf 'Installed and started %s\n' "$LABEL"
  printf 'LaunchAgent: %s\n' "$PLIST_FILE"
  printf 'Logs: %s\n' "$STATE_DIR"
}

uninstall_agent() {
  /bin/launchctl bootout "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
  /bin/rm -f "$PLIST_FILE"
  printf 'Stopped and removed %s\n' "$LABEL"
  printf 'Any active SMB mount and Keychain credentials were left intact.\n'
}

status_agent() {
  if /bin/launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
    printf 'LaunchAgent: loaded\n'
  else
    printf 'LaunchAgent: not loaded\n'
  fi

  if is_mounted; then
    printf 'SMB mount: active at %s\n' "$MOUNT_POINT"
    /sbin/mount | /usr/bin/grep -F " on $MOUNT_POINT (smbfs"
  else
    printf 'SMB mount: not mounted at %s\n' "$MOUNT_POINT"
  fi
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
--mount)
  [[ $# -eq 1 ]] || error '--mount does not accept additional arguments.'
  mount_share
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
