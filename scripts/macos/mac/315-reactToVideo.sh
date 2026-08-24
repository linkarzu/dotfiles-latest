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

Create a Discord forum post for a YouTube video or X/Twitter post and apply
the configured react-to tag.

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

fetch_youtube_title() {
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

is_x_url() {
  [[ "$1" =~ ^https?://(www\.|mobile\.)?(x\.com|twitter\.com)(/|$) ]]
}

is_x_post_url() {
  [[ "$1" =~ ^https?://(www\.|mobile\.)?(x\.com|twitter\.com)/[^/?#]+/status/[0-9]+([/?#].*)?$ ]]
}

fetch_x_post() {
  local post_url=$1 metadata post_text author title

  if ! metadata=$(curl --silent --show-error --fail-with-body --max-time 20 \
    --get \
    --data-urlencode "url=$post_url" \
    --data-urlencode 'omit_script=true' \
    --data-urlencode 'dnt=true' \
    'https://publish.x.com/oembed'); then
    error 'X could not find a public post at that URL.'
  fi

  if ! post_text=$(jq -er '
    .html
    | select(type == "string")
    | capture("<p[^>]*>(?<text>.*?)</p>"; "s").text
    | gsub("<br ?/?>"; "\n"; "i")
    | gsub("<[^>]+>"; "")
    | gsub("&amp;"; "&")
    | gsub("&lt;"; "<")
    | gsub("&gt;"; ">")
    | gsub("&quot;"; "\"")
    | gsub("&#39;|&apos;"; "\u0027")
    | gsub("&nbsp;"; " ")
    | gsub("[ \t]+"; " ")
    | gsub(" *\n *"; "\n")
    | gsub("^\n+|\n+$"; "")
    | select(length > 0)
  ' <<<"$metadata"); then
    error 'X returned invalid post text.'
  fi

  author=$(jq -r '.author_name | select(type == "string" and length > 0) // "X user"' <<<"$metadata")
  title=$(jq -nr --arg text "$post_text" --arg author "$author" '
    $text
    | gsub("https?://[^[:space:]]+"; "")
    | gsub("(pic\\.)?twitter\\.com/[^[:space:]]+"; "")
    | gsub("[[:space:]]+"; " ")
    | gsub("^ +| +$"; "")
    | if length == 0 then "Post by " + $author + " on X" else . end
    | .[0:100]
  ')

  POST_TITLE=$title
  if ! POST_CONTENT=$(jq -nr --arg text "$post_text" --arg url "$post_url" '
    ("\n\nOriginal post: " + $url) as $suffix
    | (2000 - ($suffix | length)) as $text_limit
    | if $text_limit < 3 then
        error("X URL is too long for a Discord message")
      elif ($text | length) <= $text_limit then
        $text + $suffix
      else
        $text[0:($text_limit - 3)] + "..." + $suffix
      end
  '); then
    error 'The X URL is too long for a Discord message.'
  fi
}

create_forum_post() {
  local title=$1 content=$2 payload response api_message guild_id thread_id

  payload=$(jq -n \
    --arg title "$title" \
    --arg content "$content" \
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
  local shared_url title content

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

  if ! IFS= read -rp 'Enter a YouTube or X/Twitter URL: ' shared_url; then
    error 'Could not read the URL.'
  fi
  [[ "$shared_url" =~ ^https?:// ]] || error 'Enter a complete HTTP or HTTPS URL.'

  if is_x_url "$shared_url"; then
    is_x_post_url "$shared_url" || error 'Enter a complete X/Twitter status URL.'
    fetch_x_post "$shared_url"
    title=$POST_TITLE
    content=$POST_CONTENT
  else
    title=$(fetch_youtube_title "$shared_url")
    content=$shared_url
  fi

  create_forum_post "$title" "$content"
}

main "$@"
