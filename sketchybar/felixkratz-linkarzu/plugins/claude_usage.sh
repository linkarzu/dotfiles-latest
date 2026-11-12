#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/claude_usage.sh

# Shows the Claude session (5 hour) and weekly usage, the same numbers as /usage
# in Claude Code, and the hours:minutes left until each resets: white, yellow
# above 65%, red above 90%. Runs every minute so the countdown moves, but only
# asks the API again every 5 minutes, after a reset, or on a click. Uses the
# OAuth token Claude Code keeps in the keychain; when it has expired the old
# numbers stay until Claude Code refreshes it. The response is kept outside the
# sketchybar config directory, because writing there would hotload sketchybar.
source "$CONFIG_DIR/colors.sh"

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
cache="$cache_dir/claude-usage.json"
max_age=300

mkdir -p "$cache_dir"

fetch() {
  local token
  token="$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null |
    jq -r '.claudeAiOauth.accessToken // empty')"
  [[ -n "$token" ]] || return 1
  curl --silent --fail --max-time 10 https://api.anthropic.com/api/oauth/usage \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" >"$cache.$$" &&
    jq -e '.five_hour' "$cache.$$" >/dev/null &&
    mv -f "$cache.$$" "$cache"
  rm -f "$cache.$$"
}

now=$(date +%s)
age=$max_age
[[ -f "$cache" ]] && age=$((now - $(stat -f %m "$cache")))

# A reset that already passed means the cached numbers are stale too.
passed=0
if [[ -f "$cache" ]]; then
  passed="$(jq --argjson now "$now" '
    [.five_hour.resets_at, .seven_day.resets_at][]
    | select(. != null)
    | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601
    | select(. <= $now)' "$cache" 2>/dev/null | wc -l | tr -d ' ')"
fi

if [[ "$SENDER" == "mouse.clicked" || "$SENDER" == "system_woke" ]] || ((age >= max_age || passed > 0)); then
  fetch
fi

[[ -f "$cache" ]] || exit 0

# Prints "<percent> <hours:minutes left>" for a window, "-- --" when it isn't in
# the response, and the time as "--" when nothing has started it yet.
row() {
  jq -r --arg key "$1" --argjson now "$now" '
    .[$key] as $w
    | if $w == null then "-- --"
      else
        ($w.utilization // 0 | round | tostring) + " " +
        (if $w.resets_at == null then "--"
         else ($w.resets_at | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601) - $now
           | if . < 0 then 0 else . end
           | (. / 60 | ceil) as $m
           | "\($m / 60 | floor):\($m % 60 | tostring | if length < 2 then "0" + . else . end)"
         end)
      end' "$cache"
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

read -r session_pct session_left < <(row five_hour)
read -r week_pct week_left < <(row seven_day)

sketchybar --set claude_usage.session \
  label="$(printf 'S %3s %6s' "$session_pct" "$session_left")" \
  label.color="$(color "$session_pct")" \
  --set claude_usage.week \
  label="$(printf 'W %3s %6s' "$week_pct" "$week_left")" \
  label.color="$(color "$week_pct")"
