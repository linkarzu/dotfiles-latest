#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/claude_usage.sh

# Shows the Claude session (5 hour) and weekly usage, the same numbers as /usage
# in Claude Code, and the time left until each resets: white, yellow above 65%,
# red above 90%. The popup has every Claude limit, including the per model weekly
# ones, then the Codex ones, the same numbers as /status in Codex, each with the
# local time it resets. Runs every minute so the countdown moves, but only asks
# the APIs again every 5 minutes, after a reset, on wake, or on a click. Uses the
# tokens Claude Code keeps in the keychain and Codex in ~/.codex/auth.json; when
# one has expired the old numbers stay until that app refreshes it. The responses
# are kept outside the sketchybar config directory, because writing there would
# hotload sketchybar.
source "$CONFIG_DIR/colors.sh"

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
claude_cache="$cache_dir/claude-usage.json"
codex_cache="$cache_dir/codex-usage.json"
codex_auth="$HOME/.codex/auth.json"
max_age=300

mkdir -p "$cache_dir"

# Saves the response to $1 when it has $2, so a failed request keeps the old one.
save() {
  jq -e "$2" "$1.$$" >/dev/null 2>&1 && mv -f "$1.$$" "$1"
  rm -f "$1.$$"
}

fetch_claude() {
  local token
  token="$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null |
    jq -r '.claudeAiOauth.accessToken // empty')"
  [[ -n "$token" ]] || return 1
  curl --silent --fail --max-time 10 https://api.anthropic.com/api/oauth/usage \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" >"$claude_cache.$$"
  save "$claude_cache" '.five_hour'
}

fetch_codex() {
  local token account
  [[ -r "$codex_auth" ]] || return 1
  token="$(jq -r '.tokens.access_token // empty' "$codex_auth")"
  account="$(jq -r '.tokens.account_id // empty' "$codex_auth")"
  [[ -n "$token" ]] || return 1
  curl --silent --fail --max-time 10 https://chatgpt.com/backend-api/wham/usage \
    -H "Authorization: Bearer $token" \
    -H "ChatGPT-Account-Id: $account" \
    -H "User-Agent: codex_cli_rs" >"$codex_cache.$$"
  save "$codex_cache" '.rate_limit'
}

# Each response as {name, percent, resets}, resets in epoch seconds, or null
# when nothing has started the window yet.
claude_limits='
  def epoch: sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601;
  (.limits // [
    {kind: "session", percent: .five_hour.utilization, resets_at: .five_hour.resets_at},
    {kind: "weekly_all", percent: .seven_day.utilization, resets_at: .seven_day.resets_at}
  ])[]
  | {
      name: (if .kind == "session" then "Session"
             elif .kind == "weekly_all" then "Week"
             else "Week " + (.scope.model.display_name // .scope.surface // .kind | tostring) end),
      percent: (.percent // 0),
      resets: (if .resets_at == null then null else .resets_at | epoch end)
    }'

# Codex reports an unused window as resetting a full window from now.
codex_limits='
  def window($prefix):
    select(. != null)
    | {
        name: ($prefix + (if .limit_window_seconds == 18000 then "Session"
                          elif .limit_window_seconds == 604800 then "Week"
                          else "\(.limit_window_seconds / 3600 | round)h" end)),
        percent: (.used_percent // 0),
        resets: (if (.used_percent // 0) == 0 and .reset_after_seconds >= .limit_window_seconds
                 then null else .reset_at end)
      };
  (.rate_limit.primary_window | window("")),
  (.rate_limit.secondary_window | window("")),
  (.additional_rate_limits // [] | .[]
    | (.limit_name // .metered_feature // "Other" | tostring) as $n
    | (.rate_limit.primary_window, .rate_limit.secondary_window) | window($n + " "))'

stale() {
  local cache="$1" limits="$2" age
  [[ -f "$cache" ]] || return 0
  age=$((now - $(stat -f %m "$cache")))
  ((age >= max_age)) && return 0
  # A reset that already passed means the cached numbers are stale too.
  jq -e --argjson now "$now" "[$limits | select(.resets != null and .resets <= \$now)] | length > 0" \
    "$cache" >/dev/null 2>&1
}

now=$(date +%s)
force=0
[[ "$SENDER" == "claude_usage_update" || "$SENDER" == "system_woke" ]] && force=1
if ((force)) || stale "$claude_cache" "$claude_limits"; then
  fetch_claude &
fi
if ((force)) || stale "$codex_cache" "$codex_limits"; then
  fetch_codex &
fi
wait

# One tab separated row per limit: name, percent, reset time, time left for the
# popup and for the bar. The reset time is the clock time when it's within a day,
# with the weekday otherwise. Time left is "2h58m", with days in front past a
# day, "1d 17h 21m" in the popup and only "1d17h" on the bar so it fits.
rows() {
  [[ -f "$1" ]] || return
  jq -r --argjson now "$now" "
    def pad: tostring | if length < 2 then \"0\" + . else . end;
    $2
    | [
        .name,
        (.percent | round | tostring),
        (if .resets == null then \"--\"
         elif .resets - \$now < 86400 then .resets | localtime | strftime(\"%H:%M\")
         else .resets | localtime | strftime(\"%a %H:%M\") end),
        (if .resets == null then [\"--\", \"--\"] else .resets - \$now
          | if . < 0 then 0 else . end
          | (. / 60 | ceil) as \$m
          | (\$m / 1440 | floor) as \$d | (\$m % 1440 / 60 | floor) as \$h
          | if \$d > 0 then [\"\\(\$d)d \\(\$h)h \\(\$m % 60)m\", \"\\(\$d)d\\(\$h)h\"]
            else [\"\\(\$h)h \\(\$m % 60)m\", \"\\(\$h)h\\(\$m % 60 | pad)m\"] end end)[]
      ]
    | @tsv" "$1" 2>/dev/null
}

updated() {
  if [[ -f "$1" ]]; then
    echo "updated $(date -r "$(stat -f %m "$1")" +%H:%M:%S)"
  else
    echo "no data"
  fi
}

color() {
  if [[ "$1" =~ ^[0-9]+$ ]] && (($1 > 90)); then
    echo "$RED"
  elif [[ "$1" =~ ^[0-9]+$ ]] && (($1 > 65)); then
    echo "$YELLOW"
  else
    echo "$WHITE"
  fi
}

claude_rows="$(rows "$claude_cache" "$claude_limits")"
codex_rows="$(rows "$codex_cache" "$codex_limits")"

# The popup: a column header, then a heading and a row per limit for Claude and
# for Codex, then Refresh. Every row is set again on each run, the rows are only
# made again when their number changes.
popup=()
popup+=("$(printf 'header\tLimit\tUsed · resets · left')")
popup+=("$(printf 'header\tClaude\t%s' "$(updated "$claude_cache")")")
while IFS= read -r row; do
  [[ -n "$row" ]] && popup+=("limit	$row")
done <<<"$claude_rows"
popup+=("$(printf 'header\tCodex\t%s' "$(updated "$codex_cache")")")
while IFS= read -r row; do
  [[ -n "$row" ]] && popup+=("limit	$row")
done <<<"$codex_rows"
popup+=("$(printf 'refresh\tRefresh\t󰑓')")

args=()
existing="$(sketchybar --query claude_usage.frame 2>/dev/null |
  jq '[.popup.items[]? | select(startswith("claude_usage.popup.row."))] | length')"
if [[ "${#popup[@]}" != "$existing" ]]; then
  args+=(--remove '/claude_usage\.popup\.row\..*/')
  for ((i = 0; i < ${#popup[@]}; i++)); do
    args+=(--clone "claude_usage.popup.row.$i" claude_usage.popup.template
      --set "claude_usage.popup.row.$i" position=popup.claude_usage.frame drawing=on)
  done
fi

for ((i = 0; i < ${#popup[@]}; i++)); do
  IFS=$'\t' read -r kind name pct resets left _ <<<"${popup[$i]}"
  row="claude_usage.popup.row.$i"
  case "$kind" in
  header)
    args+=(--set "$row" icon="$name" label="$pct" icon.color="$GREY" label.color="$GREY"
      click_script="sketchybar --set claude_usage.frame popup.drawing=off")
    ;;
  limit)
    args+=(--set "$row" icon="$name" label="$pct% · $resets · $left"
      icon.color="$WHITE" label.color="$(color "$pct")"
      click_script="sketchybar --set claude_usage.frame popup.drawing=off")
    ;;
  refresh)
    args+=(--set "$row" icon="$name" label="$pct" icon.color="$WHITE" label.color="$WHITE"
      click_script="sketchybar --trigger claude_usage_update")
    ;;
  esac
done

session_pct="--" session_left="--" week_pct="--" week_left="--"
while IFS=$'\t' read -r name pct resets left bar_left; do
  case "$name" in
  Session) session_pct="$pct" session_left="$bar_left" ;;
  Week) week_pct="$pct" week_left="$bar_left" ;;
  esac
done <<<"$claude_rows"

sketchybar "${args[@]}" \
  --set claude_usage.session label="$session_pct%" label.color="$(color "$session_pct")" \
  --set claude_usage.session_left label="$session_left" \
  --set claude_usage.week label="$week_pct%" label.color="$(color "$week_pct")" \
  --set claude_usage.week_left label="$week_left"
