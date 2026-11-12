#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/claude_usage.sh

# Shows the Claude session (5 hour) and weekly usage, the same numbers as /usage
# in Claude Code, and the hours:minutes left until each resets: white, yellow
# above 65%, red above 90%. The popup has every limit, including the per model
# weekly ones, with the local time each resets. Runs every minute so the
# countdown moves, but only asks the API again every 5 minutes, after a reset,
# or on a click. Uses the OAuth token Claude Code keeps in the keychain; when it
# has expired the old numbers stay until Claude Code refreshes it. The response
# is kept outside the sketchybar config directory, because writing there would
# hotload sketchybar.
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

if [[ "$SENDER" == "claude_usage_update" || "$SENDER" == "system_woke" ]] || ((age >= max_age || passed > 0)); then
  fetch
fi

[[ -f "$cache" ]] || exit 0

# One tab separated row per limit: name, percent, reset time, time left for the
# popup and for the bar. The reset time is the clock time when it's within a day,
# with the weekday otherwise. Time left is "2h58m", with days in front past a
# day, "1d 17h 21m" in the popup and only "1d17h" on the bar so it fits. Uses .limits, which has the per model weekly limits, and falls back
# to the session and week when the response doesn't have it.
limits="$(jq -r --argjson now "$now" '
  def epoch: sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601;
  def pad: tostring | if length < 2 then "0" + . else . end;
  (.limits // [
    {kind: "session", percent: .five_hour.utilization, resets_at: .five_hour.resets_at},
    {kind: "weekly_all", percent: .seven_day.utilization, resets_at: .seven_day.resets_at}
  ])[]
  | [
      (if .kind == "session" then "Session"
       elif .kind == "weekly_all" then "Week"
       else "Week " + (.scope.model.display_name // .scope.surface // .kind | tostring) end),
      (.percent // 0 | round | tostring),
      (if .resets_at == null then "--" else (.resets_at | epoch) as $t
        | if $t - $now < 86400 then $t | localtime | strftime("%H:%M")
          else $t | localtime | strftime("%a %H:%M") end end),
      (if .resets_at == null then ["--", "--"] else ((.resets_at | epoch) - $now)
        | if . < 0 then 0 else . end
        | (. / 60 | ceil) as $m
        | ($m / 1440 | floor) as $d | ($m % 1440 / 60 | floor) as $h
        | if $d > 0 then ["\($d)d \($h)h \($m % 60)m", "\($d)d\($h)h"]
          else ["\($h)h \($m % 60)m", "\($h)h\($m % 60 | pad)m"] end end)[]
    ]
  | @tsv' "$cache" 2>/dev/null)"

color() {
  if [[ "$1" =~ ^[0-9]+$ ]] && (($1 > 90)); then
    echo "$RED"
  elif [[ "$1" =~ ^[0-9]+$ ]] && (($1 > 65)); then
    echo "$YELLOW"
  else
    echo "$WHITE"
  fi
}

session_pct="--" session_left="--" week_pct="--" week_left="--"
count="$(grep -c . <<<"$limits")"
existing="$(sketchybar --query claude_usage.frame 2>/dev/null |
  jq '[.popup.items[]? | select(startswith("claude_usage.popup.limit."))] | length')"

# Header, a row per limit, Updated and Refresh, in that order.
args=()
if [[ "$count" != "$existing" ]]; then
  args+=(--remove '/claude_usage\.popup\.(header|limit\..*|updated|refresh)/')
  for row in header $(seq -f 'limit.%g' 0 $((count - 1))) updated refresh; do
    args+=(--clone "claude_usage.popup.$row" claude_usage.popup.template
      --set "claude_usage.popup.$row" position=popup.claude_usage.frame drawing=on)
  done
  args+=(--set claude_usage.popup.header icon="Limit" label="Used · resets · left"
    icon.color="$GREY" label.color="$GREY"
    --set claude_usage.popup.updated icon="Updated" icon.color="$GREY" label.color="$GREY"
    --set claude_usage.popup.refresh icon="Refresh" label="󰑓"
    click_script="sketchybar --trigger claude_usage_update")
fi

i=0
while IFS=$'\t' read -r name pct resets left bar_left; do
  [[ -n "$name" ]] || continue
  case "$name" in
  Session) session_pct="$pct" session_left="$bar_left" ;;
  Week) week_pct="$pct" week_left="$bar_left" ;;
  esac
  args+=(--set "claude_usage.popup.limit.$i" icon="$name"
    label="$pct% · $resets · $left" label.color="$(color "$pct")")
  i=$((i + 1))
done <<<"$limits"

sketchybar "${args[@]}" \
  --set claude_usage.session label="$session_pct%" label.color="$(color "$session_pct")" \
  --set claude_usage.session_left label="$session_left" \
  --set claude_usage.week label="$week_pct%" label.color="$(color "$week_pct")" \
  --set claude_usage.week_left label="$week_left" \
  --set claude_usage.popup.updated label="$(date -r "$(stat -f %m "$cache")" +%H:%M:%S)"
