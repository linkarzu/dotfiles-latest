#!/usr/bin/env bash

set -u

source "$CONFIG_DIR/colors.sh"
if [[ -f "$CONFIG_DIR/opencode.conf" ]]; then
  # shellcheck disable=SC1091
  source "$CONFIG_DIR/opencode.conf"
fi

selector="$HOME/github/dotfiles-latest/kitty/scripts/kitty-opencode-sessions.sh"
bridge_url="http://127.0.0.1:47653"
bridge_secret_file="$HOME/.config/opencode-telegram-bridge/plugin-secret"
opencode_icon="󰚩"
phone_mode_icon="󰏲"
refresh_lock="/tmp/sketchybar-opencode-refresh.lock"
popup_open_file="/tmp/sketchybar-opencode-popup-open"
focus_pending_file="/tmp/sketchybar-opencode-focus-pending"
popup_state_file="/tmp/sketchybar-opencode-popup.json"
hammerspoon_bin="/opt/homebrew/bin/hs"
OPENCODE_POPUP_TARGET="${OPENCODE_POPUP_TARGET:-primary}"
focus_delay=2
popup_layout_version=8
kitty_name_max=18
opencode_name_max=22

truncate_name() {
  local value="$1"
  local max_chars="$2"

  if ((${#value} <= max_chars)); then
    printf '%s' "$value"
  else
    printf '%s...' "${value:0:max_chars-3}"
  fi
}

toggle_phone_mode() {
  local response=""
  local secret=""

  [[ -r "$bridge_secret_file" ]] || return 1
  secret="$(<"$bridge_secret_file")"
  [[ -n "$secret" ]] || return 1

  response="$(/usr/bin/curl --silent --show-error --fail --max-time 15 \
    --request POST \
    --header "Authorization: Bearer $secret" \
    --header "Content-Type: application/json" \
    --data '{}' \
    "$bridge_url/phone-mode/toggle")" || return 1

  if jq -e '.phoneMode == true' >/dev/null 2>&1 <<<"$response"; then
    /usr/bin/osascript -e 'display notification "YES" with title "Phone mode"'
  else
    /usr/bin/osascript -e 'display notification "NO" with title "Phone mode"'
  fi
}

publish_pinned_popup() {
  local windows="$1"
  local popup_drawing="$2"
  local anchors="$3"
  local visible=false
  local state_tmp="${popup_state_file}.$$"

  if [[ "$popup_drawing" == "on" && "$OPENCODE_POPUP_TARGET" != "active" && "$OPENCODE_POPUP_TARGET" != "off" ]]; then
    visible=true
  fi

  if ! jq -n -c \
    --arg target "$OPENCODE_POPUP_TARGET" \
    --arg selector "$selector" \
    --arg popup_open_file "$popup_open_file" \
    --arg focus_pending_file "$focus_pending_file" \
    --arg background "$POPUP_BACKGROUND_COLOR" \
    --arg border "$POPUP_BORDER_COLOR" \
    --arg label "$LABEL_COLOR" \
    --arg green "$GREEN" \
    --arg blue "$BLUE" \
    --arg grey "$GREY" \
    --argjson visible "$visible" \
    --argjson anchors "$anchors" \
    --argjson windows "$windows" '
      def row_label:
        if (.session_name // "") == "" then (.opencode_title // "OpenCode")
        else "\(.session_name) | \(.opencode_title // "OpenCode")"
        end;
      {
        target: $target,
        visible: $visible,
        selector: $selector,
        popup_open_file: $popup_open_file,
        focus_pending_file: $focus_pending_file,
        anchors: $anchors,
        colors: {
          background: $background,
          border: $border,
          label: $label,
          green: $green,
          blue: $blue,
          grey: $grey
        },
        rows: (
          if ($windows | length) == 0 then
            [{ id: null, status: "idle", icon: "-", label: "No OpenCode tabs" }]
          else
            $windows | map({
              id,
              status,
              icon: (if .status == "attention" then "!" elif .status == "running" then ">" else "-" end),
              label: row_label
            })
          end
        )
      }
    ' >"$state_tmp"; then
    rm -f "$state_tmp"
    return
  fi

  mv "$state_tmp" "$popup_state_file"
  if [[ -x "$hammerspoon_bin" ]]; then
    "$hammerspoon_bin" -c 'if opencodePopup then opencodePopup.refresh() end' >/dev/null 2>&1 &
  fi
}

refresh() {
  local windows="[]"
  local count=0
  local waiting=0
  local color="$GREY"
  local icon="$opencode_icon"
  local phone_mode="false"
  local id=""
  local status=""
  local session_name=""
  local opencode_title=""
  local session_label=""
  local window=""
  local row_icon=""
  local row_color="$GREY"
  local row_label_color="$LABEL_COLOR"
  local popup_drawing="off"
  local popup_mode=""
  local previous_icon=""
  local new_attention=0
  local focused="false"
  local deadline=0
  local now=0
  local pending_id=""
  local pending_deadline=0
  local pending_tmp=""
  local schedule_focus_check=0
  local render_state=""
  local render_hash=""
  local previous_hash=""
  local existing_rows=0
  local expected_rows=0
  local opencode_query="{}"
  local anchors="{}"
  local native_popup_drawing="off"
  local args=()

  if ! mkdir "$refresh_lock" 2>/dev/null; then
    if [[ "${SENDER:-}" == "opencode_focus_check" ]]; then
      (sleep 0.2 && SENDER=opencode_focus_check "$0") >/dev/null 2>&1 &
    else
      (sleep 0.2 && sketchybar --trigger opencode_update) >/dev/null 2>&1 &
    fi
    return 0
  fi
  trap 'rmdir "$refresh_lock" 2>/dev/null || true' EXIT

  windows="$($selector --json 2>/dev/null || printf '[]\n')"
  if ! jq -e 'type == "array"' >/dev/null 2>&1 <<<"$windows"; then
    windows="[]"
  fi

  count="$(jq 'length' <<<"$windows")"
  waiting="$(jq '[.[] | select(.waiting > 0)] | length' <<<"$windows")"
  phone_mode="$(/usr/bin/curl --silent --fail --max-time 1 "$bridge_url/health" 2>/dev/null | jq -r '.phoneMode == true' 2>/dev/null)"
  if [[ "$phone_mode" == "true" ]]; then
    icon="$phone_mode_icon"
  fi
  render_state="${popup_layout_version}:$(jq -c '[.[] | {id, status, session_name, opencode_title}]' <<<"$windows")"
  render_hash="$(printf '%s' "$render_state" | /sbin/md5 -q)"
  previous_hash="$(sketchybar --query opencode.template 2>/dev/null | jq -r '.label.value // empty')"
  opencode_query="$(sketchybar --query opencode 2>/dev/null || printf '{}\n')"
  existing_rows="$(jq '[.popup.items[]? | select(startswith("opencode.window."))] | length' <<<"$opencode_query")"
  existing_rows="${existing_rows:-0}"
  anchors="$(jq -c '.bounding_rects // {}' <<<"$opencode_query")"
  expected_rows="$count"
  if ((expected_rows == 0)); then
    expected_rows=1
  fi
  if [[ -f "$popup_open_file" ]]; then
    popup_mode="$(<"$popup_open_file")"
    [[ -n "$popup_mode" ]] || popup_mode="manual"
    popup_drawing="on"
  fi

  now="$(date +%s)"
  if [[ -f "$focus_pending_file" ]]; then
    pending_tmp="${focus_pending_file}.$$"
    : >"$pending_tmp"
    while IFS=$'\t' read -r pending_id pending_deadline; do
      [[ "$pending_id" =~ ^[0-9]+$ && "$pending_deadline" =~ ^[0-9]+$ ]] || continue
      window="$(jq -c --argjson id "$pending_id" '.[] | select(.id == $id and .waiting > 0)' <<<"$windows")"
      [[ -n "$window" ]] || continue

      if ((now < pending_deadline)); then
        printf '%s\t%s\n' "$pending_id" "$pending_deadline" >>"$pending_tmp"
      elif [[ "$(jq -r '.focused // false' <<<"$window")" != "true" ]]; then
        new_attention=1
      fi
    done <"$focus_pending_file"

    if [[ -s "$pending_tmp" ]]; then
      mv "$pending_tmp" "$focus_pending_file"
    else
      rm -f "$pending_tmp" "$focus_pending_file"
    fi
  fi

  while IFS=$'\t' read -r id focused; do
    [[ -n "$id" ]] || continue
    previous_icon="$(sketchybar --query "opencode.window.${id}" 2>/dev/null | jq -r '.icon.value // empty')"
    if [[ "$previous_icon" != "!" ]]; then
      if [[ "$focused" == "true" ]]; then
        deadline=$((now + focus_delay))
        printf '%s\t%s\n' "$id" "$deadline" >>"$focus_pending_file"
        schedule_focus_check=1
      else
        new_attention=1
      fi
    fi
  done < <(jq -r '.[] | select(.waiting > 0) | [.id, (.focused // false)] | @tsv' <<<"$windows")

  if ((schedule_focus_check > 0)); then
    (sleep "$focus_delay" && SENDER=opencode_focus_check "$0") >/dev/null 2>&1 &
  fi

  if ((new_attention > 0)); then
    if [[ "$popup_mode" != "manual" ]]; then
      printf 'auto\n' >"$popup_open_file"
      popup_mode="auto"
    fi
    popup_drawing="on"
  fi

  if ((waiting == 0)) && [[ "$popup_mode" == "auto" ]]; then
    rm -f "$popup_open_file"
    popup_mode=""
    popup_drawing="off"
  fi

  if ((waiting > 0)); then
    color="$RED"
  elif ((count > 0)); then
    color="$BLUE"
  fi
  if [[ "$phone_mode" == "true" ]] && ((waiting == 0)); then
    color="$GREEN"
  fi

  if [[ "$OPENCODE_POPUP_TARGET" == "active" ]]; then
    native_popup_drawing="$popup_drawing"
  fi
  publish_pinned_popup "$windows" "$popup_drawing" "$anchors"

  if [[ "$render_hash" == "$previous_hash" ]] && ((existing_rows == expected_rows)); then
    sketchybar --set opencode \
      label="$count" \
      icon="$icon" \
      icon.color="$color" \
      popup.drawing="$native_popup_drawing" >/dev/null
    rmdir "$refresh_lock" 2>/dev/null || true
    trap - EXIT
    return 0
  fi

  args+=(--set opencode label="$count" icon="$icon" icon.color="$color")
  args+=(--set opencode.template label="$render_hash")
  args+=(--remove '/opencode\.window\..*/')

  while IFS= read -r window; do
    id="$(jq -r '.id' <<<"$window")"
    [[ -n "$id" ]] || continue
    status="$(jq -r '.status' <<<"$window")"
    session_name="$(jq -r '.session_name' <<<"$window")"
    opencode_title="$(jq -r '.opencode_title' <<<"$window")"

    session_name="$(truncate_name "$session_name" "$kitty_name_max")"
    opencode_title="$(truncate_name "$opencode_title" "$opencode_name_max")"
    if [[ -n "$session_name" ]]; then
      session_label="${session_name} | ${opencode_title}"
    else
      session_label="$opencode_title"
    fi

    case "$status" in
    attention)
      row_icon="!"
      row_color="$GREEN"
      row_label_color="$GREEN"
      ;;
    running)
      row_icon=">"
      row_color="$BLUE"
      row_label_color="$LABEL_COLOR"
      ;;
    *)
      row_icon="-"
      row_color="$GREY"
      row_label_color="$LABEL_COLOR"
      ;;
    esac

    args+=(
      --clone "opencode.window.${id}" opencode.template
      --set "opencode.window.${id}"
      position=popup.opencode
      drawing=on
      icon="$row_icon"
      icon.color="$row_color"
      label="$session_label"
      label.color="$row_label_color"
      click_script="rm -f $popup_open_file $focus_pending_file; sketchybar --set opencode popup.drawing=off; $selector --focus $id"
    )
  done < <(jq -c '.[]' <<<"$windows")

  if ((count == 0)); then
    args+=(
      --clone opencode.window.empty opencode.template
      --set opencode.window.empty
      position=popup.opencode
      drawing=on
      icon="-"
      icon.color="$GREY"
      label="No OpenCode tabs"
    )
  fi

  args+=(--set opencode popup.drawing="$native_popup_drawing")

  sketchybar "${args[@]}" >/dev/null
  rmdir "$refresh_lock" 2>/dev/null || true
  trap - EXIT
}

case "${SENDER:-routine}" in
mouse.clicked)
  if [[ "${BUTTON:-left}" == "right" ]]; then
    toggle_phone_mode && refresh
  else
    rm -f "$focus_pending_file"
    printf 'manual\n' >"$popup_open_file"
    refresh
  fi
  ;;
system_woke)
  sleep 2
  refresh
  ;;
*)
  refresh
  ;;
esac
