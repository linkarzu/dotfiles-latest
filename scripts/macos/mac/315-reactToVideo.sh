#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

readonly CONFIG_DIR="$HOME/.config/discord-react-to"
readonly CONFIG_FILE="$CONFIG_DIR/credentials.json"

error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  315-reactToVideo.sh
  315-reactToVideo.sh --configure

Create a Discord forum post for a YouTube video and apply the configured
react-to tag.

Options:
  --configure  Securely save the Discord webhook URL and react-to tag ID
  -h, --help   Show this help

Discord setup:
  1. Create a webhook for the forum channel under Edit Channel > Integrations.
  2. Enable Developer Mode in Discord and copy the react-to tag ID.
  3. Run this script once with --configure.

Credentials are stored outside the dotfiles repository at:
  ~/.config/discord-react-to/credentials.json
EOF
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "Required command not found: $1"
}

valid_webhook_url() {
  [[ "$1" =~ ^https://(canary\.|ptb\.)?discord(app)?\.com/api(/v[0-9]+)?/webhooks/[0-9]+/[A-Za-z0-9._-]+$ ]]
}

configure() {
  local webhook_url tag_id temporary_file

  require_command jq

  printf 'The webhook URL will be stored locally with owner-only permissions.\n'
  if ! IFS= read -rsp 'Discord forum webhook URL (input hidden): ' webhook_url; then
    printf '\n' >&2
    error 'Could not read the webhook URL.'
  fi
  printf '\n'

  valid_webhook_url "$webhook_url" || error 'The webhook URL is not a valid Discord webhook URL.'

  if ! IFS= read -rp 'react-to tag ID: ' tag_id; then
    error 'Could not read the tag ID.'
  fi
  [[ "$tag_id" =~ ^[0-9]+$ ]] || error 'The tag ID must contain only digits.'

  umask 077
  [[ ! -L "$CONFIG_DIR" ]] || error "Configuration directory must not be a symlink: $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
  chmod 700 "$CONFIG_DIR"

  [[ ! -L "$CONFIG_FILE" ]] || error "Credentials file must not be a symlink: $CONFIG_FILE"
  temporary_file=$(mktemp "$CONFIG_DIR/.credentials.json.XXXXXX")
  trap 'rm -f "${temporary_file:-}"' EXIT

  printf '%s\0%s\0' "$webhook_url" "$tag_id" |
    jq -Rs 'split("\u0000") | {webhook_url: .[0], react_to_tag_id: .[1]}' >"$temporary_file"
  chmod 600 "$temporary_file"
  mv -f "$temporary_file" "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
  trap - EXIT

  printf 'Discord credentials saved with owner-only permissions: %s\n' "$CONFIG_FILE"
}

validate_private_config() {
  local config_owner config_mode directory_owner directory_mode current_user

  [[ -d "$CONFIG_DIR" ]] || error "Configuration directory not found. Run: $0 --configure"
  [[ ! -L "$CONFIG_DIR" ]] || error "Configuration directory must not be a symlink: $CONFIG_DIR"
  [[ -f "$CONFIG_FILE" ]] || error "Credentials not found. Run: $0 --configure"
  [[ ! -L "$CONFIG_FILE" ]] || error "Credentials file must not be a symlink: $CONFIG_FILE"

  current_user=$(id -u)
  directory_owner=$(stat -f '%u' "$CONFIG_DIR")
  directory_mode=$(stat -f '%Lp' "$CONFIG_DIR")
  config_owner=$(stat -f '%u' "$CONFIG_FILE")
  config_mode=$(stat -f '%Lp' "$CONFIG_FILE")

  [[ "$directory_owner" == "$current_user" ]] || error "Configuration directory is not owned by the current user: $CONFIG_DIR"
  [[ "$directory_mode" == '700' ]] || error "Configuration directory permissions must be 0700, found $directory_mode: $CONFIG_DIR"
  [[ "$config_owner" == "$current_user" ]] || error "Credentials file is not owned by the current user: $CONFIG_FILE"
  [[ "$config_mode" == '600' ]] || error "Credentials file permissions must be 0600, found $config_mode: $CONFIG_FILE"
}

load_config() {
  local loaded_webhook loaded_tag

  require_command jq
  validate_private_config

  if ! loaded_webhook=$(jq -er '.webhook_url | select(type == "string" and length > 0)' "$CONFIG_FILE"); then
    error "Invalid webhook_url in $CONFIG_FILE. Run: $0 --configure"
  fi
  if ! loaded_tag=$(jq -er '.react_to_tag_id | select(type == "string" and test("^[0-9]+$"))' "$CONFIG_FILE"); then
    error "Invalid react_to_tag_id in $CONFIG_FILE. Run: $0 --configure"
  fi
  valid_webhook_url "$loaded_webhook" || error "Invalid Discord webhook URL in $CONFIG_FILE. Run: $0 --configure"

  WEBHOOK_URL=$loaded_webhook
  REACT_TO_TAG_ID=$loaded_tag
}

fetch_video_title() {
  local video_url=$1 metadata

  if ! metadata=$(curl --silent --show-error --fail-with-body --max-time 20 \
    --get \
    --data-urlencode "url=$video_url" \
    --data-urlencode 'format=json' \
    'https://www.youtube.com/oembed'); then
    error 'YouTube could not find a public video at that URL.'
  fi

  jq -er '.title | select(type == "string" and length > 0) | .[0:100]' <<<"$metadata" ||
    error 'YouTube returned an invalid video title.'
}

create_forum_post() {
  local video_url=$1 title=$2 payload response api_message guild_id thread_id

  payload=$(jq -n \
    --arg title "$title" \
    --arg content "$video_url" \
    --arg tag_id "$REACT_TO_TAG_ID" \
    '{
      thread_name: $title,
      content: $content,
      applied_tags: [$tag_id],
      allowed_mentions: {parse: []}
    }')

  # Supplying curl's URL through a file descriptor keeps the webhook token out
  # of the process command line.
  exec 3<<<"url = \"${WEBHOOK_URL}?wait=true\""
  if ! response=$(curl --silent --show-error --fail-with-body --max-time 30 \
    --config /dev/fd/3 \
    --request POST \
    --header 'Content-Type: application/json' \
    --data-binary "$payload"); then
    exec 3<&-
    api_message=$(jq -r '.message // empty' <<<"${response:-}" 2>/dev/null || true)
    if [[ -n "$api_message" ]]; then
      error "Discord rejected the post: $api_message"
    fi
    error 'Discord rejected the post. Check the webhook, tag ID, and channel permissions.'
  fi
  exec 3<&-

  guild_id=$(jq -r '.guild_id // empty' <<<"$response")
  thread_id=$(jq -r '.channel_id // empty' <<<"$response")

  printf 'Created Discord post: %s\n' "$title"
  if [[ "$guild_id" =~ ^[0-9]+$ && "$thread_id" =~ ^[0-9]+$ ]]; then
    printf 'https://discord.com/channels/%s/%s\n' "$guild_id" "$thread_id"
  fi
}

main() {
  local video_url title

  case "${1:-}" in
  --configure)
    [[ $# -eq 1 ]] || error 'The --configure option does not accept additional arguments.'
    configure
    return
    ;;
  -h | --help)
    usage
    return
    ;;
  '') ;;
  *)
    usage >&2
    error "Unknown option: $1"
    ;;
  esac

  require_command curl
  load_config

  if ! IFS= read -rp 'Enter the YouTube video URL: ' video_url; then
    error 'Could not read the video URL.'
  fi
  [[ "$video_url" =~ ^https?:// ]] || error 'Enter a complete HTTP or HTTPS YouTube URL.'

  title=$(fetch_video_title "$video_url")
  create_forum_post "$video_url" "$title"
}

main "$@"
