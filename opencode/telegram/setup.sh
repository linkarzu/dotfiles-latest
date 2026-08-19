#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly BRIDGE_SCRIPT="$SCRIPT_DIR/bridge.mjs"
readonly CONFIG_DIR="$HOME/.config/opencode-telegram-bridge"
readonly CONFIG_FILE="$CONFIG_DIR/credentials.json"
readonly PLUGIN_SECRET_FILE="$CONFIG_DIR/plugin-secret"
readonly PLIST_FILE="$HOME/Library/LaunchAgents/com.linkarzu.opencode-telegram-bridge.plist"
readonly LABEL="com.linkarzu.opencode-telegram-bridge"

error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  setup.sh --configure
  setup.sh --set-delay SECONDS
  setup.sh --install
  setup.sh --uninstall
  setup.sh --status

Options:
  --configure  Guide bot creation and securely save its token and allowed user ID
  --set-delay  Set unresolved attention delay (5-3600 seconds; default 240)
  --install    Install or replace the macOS LaunchAgent and start the bridge
  --uninstall  Stop and remove the LaunchAgent (credentials are preserved)
  --status     Show LaunchAgent and local bridge status
  -h, --help   Show this help

Credentials are stored outside the dotfiles repository at:
  ~/.config/opencode-telegram-bridge/credentials.json
EOF
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "Required command not found: $1"
}

validate_private_config() {
  local current_user directory_owner directory_mode config_owner config_mode secret_owner secret_mode

  [[ -d "$CONFIG_DIR" ]] || error "Configuration directory not found. Run: $0 --configure"
  [[ ! -L "$CONFIG_DIR" ]] || error "Configuration directory must not be a symlink: $CONFIG_DIR"
  [[ -f "$CONFIG_FILE" ]] || error "Credentials not found. Run: $0 --configure"
  [[ ! -L "$CONFIG_FILE" ]] || error "Credentials file must not be a symlink: $CONFIG_FILE"
  [[ -f "$PLUGIN_SECRET_FILE" ]] || error "Plugin secret not found. Run: $0 --configure"
  [[ ! -L "$PLUGIN_SECRET_FILE" ]] || error "Plugin secret must not be a symlink: $PLUGIN_SECRET_FILE"

  current_user=$(id -u)
  directory_owner=$(stat -f '%u' "$CONFIG_DIR")
  directory_mode=$(stat -f '%Lp' "$CONFIG_DIR")
  config_owner=$(stat -f '%u' "$CONFIG_FILE")
  config_mode=$(stat -f '%Lp' "$CONFIG_FILE")
  secret_owner=$(stat -f '%u' "$PLUGIN_SECRET_FILE")
  secret_mode=$(stat -f '%Lp' "$PLUGIN_SECRET_FILE")

  [[ "$directory_owner" == "$current_user" ]] || error "Configuration directory is not owned by the current user: $CONFIG_DIR"
  [[ "$directory_mode" == '700' ]] || error "Configuration directory permissions must be 0700, found $directory_mode: $CONFIG_DIR"
  [[ "$config_owner" == "$current_user" ]] || error "Credentials file is not owned by the current user: $CONFIG_FILE"
  [[ "$config_mode" == '600' ]] || error "Credentials file permissions must be 0600, found $config_mode: $CONFIG_FILE"
  [[ "$secret_owner" == "$current_user" ]] || error "Plugin secret is not owned by the current user: $PLUGIN_SECRET_FILE"
  [[ "$secret_mode" == '600' ]] || error "Plugin secret permissions must be 0600, found $secret_mode: $PLUGIN_SECRET_FILE"

  jq -e '
    (.bot_token | type == "string" and test("^[0-9]+:[A-Za-z0-9_-]+$")) and
    (.allowed_user_id | type == "string" and test("^[0-9]+$")) and
    (.chat_id | type == "string" and test("^-?[0-9]+$")) and
    ((.attention_delay_seconds // 240) | type == "number" and floor == . and . >= 5 and . <= 3600)
  ' "$CONFIG_FILE" >/dev/null || error "Invalid credentials in $CONFIG_FILE. Run: $0 --configure"
  [[ "$(tr -d '\n' <"$PLUGIN_SECRET_FILE")" =~ ^[a-f0-9]{64}$ ]] ||
    error "Invalid plugin secret in $PLUGIN_SECRET_FILE. Run: $0 --configure"
}

telegram_get() {
  local token=$1 method=$2
  exec 3<<<"url = \"https://api.telegram.org/bot${token}/${method}\""
  curl --silent --show-error --fail-with-body --max-time 35 --config /dev/fd/3
  exec 3<&-
}

configure() {
  local token response user_id temporary_file temporary_secret bot_name candidates update_offset plugin_secret

  require_command curl
  require_command jq
  require_command openssl

  cat <<'EOF'
Create a private Telegram bot:
  1. In Telegram, open the verified @BotFather account.
  2. Send /newbot.
  3. Choose any display name.
  4. Choose a unique username ending in "bot".
  5. Copy the HTTP API token BotFather gives you.

The token grants full control of the bot. Input is hidden and the token will
only be stored in an owner-readable file outside this repository.
EOF
  if ! IFS= read -rsp 'Bot token (input hidden): ' token; then
    printf '\n' >&2
    error 'Could not read the bot token.'
  fi
  printf '\n'
  [[ "$token" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]] || error 'The bot token format is invalid.'

  if ! response=$(telegram_get "$token" getMe); then
    error 'Telegram rejected the bot token.'
  fi
  bot_name=$(jq -er '.result.username | select(type == "string" and length > 0)' <<<"$response") ||
    error 'Telegram returned an invalid bot identity.'
  printf 'Verified bot: @%s\n\n' "$bot_name"

  response=$(telegram_get "$token" 'getUpdates?timeout=0') ||
    error 'Could not establish the Telegram update position.'
  update_offset=$(jq '[.result[]?.update_id] | max // -1 | . + 1' <<<"$response")

  printf 'Open @%s in Telegram and send it /start.\n' "$bot_name"
  IFS= read -rp 'Press Return after you have sent /start: ' || error 'Could not read input.'
  if ! response=$(telegram_get "$token" "getUpdates?offset=${update_offset}&timeout=5&allowed_updates=%5B%22message%22%5D"); then
    error 'Could not retrieve the bot conversation from Telegram.'
  fi
  candidates=$(jq -r '
    [.result[]?.message?
      | select(.chat.type == "private" and .chat.id == .from.id)
      | select((.text // "") | test("^/start(@[A-Za-z0-9_]+)?([[:space:]]|$)"))
      | {id: (.from.id | tostring), name: ((.from.first_name // "") + " " + (.from.last_name // "") | rtrimstr(" "))}]
    | unique_by(.id)
    | .[]
    | "\(.id)\t\(.name)"
  ' <<<"$response")

  if [[ -z "$candidates" ]]; then
    error "No private /start message found. Send /start to @$bot_name and run --configure again."
  fi
  printf 'Telegram users found:\n%s\n' "$candidates"
  if [[ "$(wc -l <<<"$candidates" | tr -d ' ')" == '1' ]]; then
    user_id=${candidates%%$'\t'*}
    printf 'Using Telegram user ID: %s\n' "$user_id"
  else
    IFS= read -rp 'Your numeric Telegram user ID: ' user_id || error 'Could not read the user ID.'
  fi
  [[ "$user_id" =~ ^[0-9]+$ ]] || error 'The Telegram user ID must contain only digits.'
  awk -F '\t' -v id="$user_id" '$1 == id { found = 1 } END { exit !found }' <<<"$candidates" ||
    error 'That user ID was not found in the bot private messages.'

  umask 077
  [[ ! -L "$CONFIG_DIR" ]] || error "Configuration directory must not be a symlink: $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
  chmod 700 "$CONFIG_DIR"
  [[ ! -L "$CONFIG_FILE" ]] || error "Credentials file must not be a symlink: $CONFIG_FILE"
  [[ ! -L "$PLUGIN_SECRET_FILE" ]] || error "Plugin secret must not be a symlink: $PLUGIN_SECRET_FILE"
  temporary_file=$(mktemp "$CONFIG_DIR/.credentials.json.XXXXXX")
  temporary_secret=$(mktemp "$CONFIG_DIR/.plugin-secret.XXXXXX")
  trap 'rm -f "${temporary_file:-}" "${temporary_secret:-}"' EXIT
  plugin_secret=$(openssl rand -hex 32)
  printf '%s\0%s\0' "$token" "$user_id" |
    jq -Rs 'split("\u0000") | {bot_token: .[0], allowed_user_id: .[1], chat_id: .[1], attention_delay_seconds: 240}' >"$temporary_file"
  chmod 600 "$temporary_file"
  printf '%s\n' "$plugin_secret" >"$temporary_secret"
  chmod 600 "$temporary_secret"
  mv -f "$temporary_file" "$CONFIG_FILE"
  mv -f "$temporary_secret" "$PLUGIN_SECRET_FILE"
  chmod 600 "$CONFIG_FILE"
  chmod 600 "$PLUGIN_SECRET_FILE"
  trap - EXIT

  printf '\nCredentials saved with owner-only permissions: %s\n' "$CONFIG_FILE"
  printf 'Next, install and start the bridge with:\n  %s --install\n' "$0"
}

set_delay() {
  local seconds=$1 temporary_file

  require_command jq
  [[ "$seconds" =~ ^[0-9]+$ ]] || error 'Delay must be an integer between 5 and 3600 seconds.'
  ((seconds >= 5 && seconds <= 3600)) || error 'Delay must be between 5 and 3600 seconds.'
  validate_private_config

  umask 077
  temporary_file=$(mktemp "$CONFIG_DIR/.credentials.json.XXXXXX")
  trap 'rm -f "${temporary_file:-}"' EXIT
  jq --argjson seconds "$seconds" '.attention_delay_seconds = $seconds' "$CONFIG_FILE" >"$temporary_file"
  chmod 600 "$temporary_file"
  mv -f "$temporary_file" "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
  trap - EXIT
  printf 'Attention delay set to %s seconds. Run %s --install to restart the bridge.\n' "$seconds" "$0"
}

install_agent() {
  local temporary_file domain attempt

  require_command jq
  require_command node
  validate_private_config
  [[ -f "$BRIDGE_SCRIPT" ]] || error "Bridge script not found: $BRIDGE_SCRIPT"
  [[ -d "$HOME/Library/LaunchAgents" ]] || error "LaunchAgents directory not found: $HOME/Library/LaunchAgents"

  temporary_file=$(mktemp "$HOME/Library/LaunchAgents/.opencode-telegram.XXXXXX")
  trap 'rm -f "${temporary_file:-}"' EXIT
  cat >"$temporary_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$(command -v node)</string>
    <string>$BRIDGE_SCRIPT</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$CONFIG_DIR/bridge.log</string>
  <key>StandardErrorPath</key>
  <string>$CONFIG_DIR/bridge-error.log</string>
</dict>
</plist>
EOF
  plutil -lint "$temporary_file" >/dev/null || error 'Generated LaunchAgent is invalid.'
  mv -f "$temporary_file" "$PLIST_FILE"
  trap - EXIT

  domain="gui/$(id -u)"
  launchctl bootout "$domain/$LABEL" >/dev/null 2>&1 || true
  for attempt in {1..10}; do
    if launchctl bootstrap "$domain" "$PLIST_FILE" >/dev/null 2>&1; then
      break
    fi
    sleep 0.2
  done
  launchctl print "$domain/$LABEL" >/dev/null 2>&1 || error "Could not load $LABEL"
  launchctl kickstart -k "$domain/$LABEL"
  printf 'Installed and started %s\n' "$LABEL"
  printf 'Bridge log: %s/bridge.log\n' "$CONFIG_DIR"
}

uninstall_agent() {
  launchctl bootout "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
  rm -f "$PLIST_FILE"
  printf 'Stopped and removed %s\n' "$LABEL"
  printf 'Credentials were preserved at %s\n' "$CONFIG_FILE"
}

status_agent() {
  if launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
    printf 'LaunchAgent: running\n'
  else
    printf 'LaunchAgent: not running\n'
  fi
  if curl --silent --fail --max-time 2 http://127.0.0.1:47653/health | jq .; then
    return
  fi
  printf 'Bridge API: unavailable\n'
}

case "${1:-}" in
--configure)
  [[ $# -eq 1 ]] || error '--configure does not accept additional arguments.'
  configure
  ;;
--set-delay)
  [[ $# -eq 2 ]] || error '--set-delay requires exactly one number of seconds.'
  set_delay "$2"
  ;;
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
  require_command curl
  require_command jq
  status_agent
  ;;
-h | --help | '')
  usage
  ;;
*)
  usage >&2
  error "Unknown option: $1"
  ;;
esac
