#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/kitty/scripts/kitty-zoxide-session.sh
# Select a zoxide entry and switch to an existing kitty session,
# or create it if it doesn't exist.
#
# Also supports SSH host entries from ~/.ssh/config (and Include files).
# SSH entries are shown with a "ssh-" prefix to make them easy to filter
# and are treated as SSH targets (not zoxide directories).

set -euo pipefail

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"
work_env_file="$HOME/github/dotfiles-private/work/work-env.sh"
colorscheme_file="$HOME/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh"

if [[ -f "$work_env_file" ]]; then
  # shellcheck disable=SC1090
  source "$work_env_file"
fi

if [[ -f "$colorscheme_file" ]]; then
  # shellcheck disable=SC1090
  source "$colorscheme_file"
fi

require_cmd() {
  local cmd="$1"
  local install_hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd is not installed or not in PATH."
    echo "$install_hint"
    exit 1
  fi
}

require_cmd fzf "Install (brew): brew install fzf"
require_cmd jq "Install (brew): brew install jq"
require_cmd zoxide "Install (brew): brew install zoxide"

if [[ ! -x "$kitty_bin" ]]; then
  echo "kitty binary not found at: $kitty_bin"
  exit 1
fi

sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1 || true)"
if [[ -z "${sock:-}" ]]; then
  echo "No kitty sockets found in /tmp (kitty not running, or remote control not available)."
  exit 1
fi

normalize_path() {
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$p"
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$p" <<'PY'
import os
import sys
print(os.path.realpath(sys.argv[1]))
PY
    return 0
  fi

  if command -v python >/dev/null 2>&1; then
    python - "$p" <<'PY'
import os
import sys
print(os.path.realpath(sys.argv[1]))
PY
    return 0
  fi

  printf "%s" "$p"
}

work_main_dir="${WORK_MAIN_DIR:-}"
if [[ -n "${work_main_dir:-}" ]]; then
  work_main_dir="$(normalize_path "$work_main_dir")"
fi

hex="${linkarzu_color03#\#}"
r=$((16#${hex:0:2}))
g=$((16#${hex:2:2}))
b=$((16#${hex:4:2}))
base_color="\033[38;2;${r};${g};${b}m"
reset_color="\033[0m"

fzf_colors="bg:${linkarzu_color10},fg:${linkarzu_color14}"
fzf_colors+=",hl:${linkarzu_color03},hl+:${linkarzu_color03}"
fzf_colors+=",info:${linkarzu_color09},header:${linkarzu_color09}"
fzf_colors+=",prompt:${linkarzu_color02}"
fzf_colors+=",pointer:${linkarzu_color11}"
fzf_colors+=",marker:${linkarzu_color12}"
fzf_colors+=",spinner:${linkarzu_color13}"
fzf_colors+=",fg+:${linkarzu_color14}"
fzf_colors+=",bg+:${linkarzu_color13}"
fzf_colors+=",gutter:${linkarzu_color10}"

hash_path() {
  local p="$1"
  if command -v shasum >/dev/null 2>&1; then
    printf "%s" "$p" | shasum -a 256 | awk '{print $1}'
    return 0
  fi

  if command -v md5 >/dev/null 2>&1; then
    printf "%s" "$p" | md5
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$p" <<'PY'
import hashlib
import sys
print(hashlib.sha256(sys.argv[1].encode("utf-8")).hexdigest())
PY
    return 0
  fi

  if command -v python >/dev/null 2>&1; then
    python - "$p" <<'PY'
import hashlib
import sys
print(hashlib.sha256(sys.argv[1].encode("utf-8")).hexdigest())
PY
    return 0
  fi

  printf "%s" "$p"
}

session_exists() {
  local name="$1"
  "$kitty_bin" @ --to "unix:${sock}" ls 2>/dev/null | jq -e --arg name "$name" '
    any(.[]?.tabs[]?.windows[]?; .session_name == $name)
  ' >/dev/null
}

bump_zoxide_score() {
  local path="$1"
  zoxide add -- "$path" >/dev/null 2>&1 || true
}

find_session_by_path() {
  local target="$1"
  local name=""
  local pwd=""
  local real=""

  while IFS=$'\t' read -r name pwd; do
    [[ -z "$name" || -z "$pwd" ]] && continue
    [[ ! -d "$pwd" ]] && continue
    real="$(normalize_path "$pwd")"
    if [[ "$real" == "$target" ]]; then
      printf "%s" "$name"
      return 0
    fi
  done < <(
    "$kitty_bin" @ --to "unix:${sock}" ls 2>/dev/null | jq -r '
      .[]?.tabs[]?.windows[]?
      | select(.session_name != null and .session_name != "")
      | [(.session_name|tostring), (.env.PWD // .cwd // "")]
      | @tsv
    '
  )

  return 1
}

print_menu_lines() {
  local query="${1:-}"
  zoxide query -l 2>/dev/null | awk -v OFS='\t' -v work_dir="${work_main_dir}" -v color="${base_color}" -v reset="${reset_color}" '{
    path=$0
    if (work_dir != "" && (path == work_dir || index(path, work_dir "/") == 1)) next
    n=split(path, parts, "/")
    base=parts[n]
    if (base == "") base=path
    printf "%s\t%s%s%s  %s\n", path, color, base, reset, path
  }'

  # SSH entries are not zoxide paths: they are parsed from ~/.ssh/config
  # (including Include files) and displayed with a ssh- prefix.
  print_ssh_menu_lines
}

collect_ssh_config_files() {
  local root_config="$HOME/.ssh/config"
  local file=""
  local line=""
  local includes=""
  local pattern=""
  local match=""
  local queue=()
  local files=()
  local processed="|"
  local old_nullglob=""
  local debug_log="/tmp/kitty-zoxide-ssh-debug.log"

  if [[ ! -f "$root_config" ]]; then
    printf '%s\n' "collect_ssh_config_files: missing $root_config" >>"$debug_log"
    return 0
  fi

  queue+=("$root_config")
  printf '%s\n' "collect_ssh_config_files: start $root_config" >>"$debug_log"

  old_nullglob="$(shopt -p nullglob || true)"
  shopt -s nullglob

  while ((${#queue[@]})); do
    file="${queue[0]}"
    queue=("${queue[@]:1}")

    case "$processed" in
    *"|${file}|"*)
      continue
      ;;
    esac

    processed+="${file}|"
    if [[ ! -f "$file" ]]; then
      printf '%s\n' "collect_ssh_config_files: skip missing $file" >>"$debug_log"
      continue
    fi

    files+=("$file")
    printf '%s\n' "collect_ssh_config_files: add $file" >>"$debug_log"

    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%#*}"
      if [[ "$line" =~ ^[[:space:]]*Include[[:space:]]+(.+) ]]; then
        includes="${BASH_REMATCH[1]}"
        for pattern in $includes; do
          pattern="${pattern/#~/$HOME}"
          for match in $pattern; do
            if [[ -f "$match" ]]; then
              queue+=("$match")
              printf '%s\n' "collect_ssh_config_files: include $match" >>"$debug_log"
            fi
          done
        done
      fi
    done <"$file"
  done

  eval "$old_nullglob"

  printf "%s\n" "${files[@]}"
}

print_ssh_menu_lines() {
  local config_files=()
  local host=""
  local label=""
  local debug_log="/tmp/kitty-zoxide-ssh-debug.log"

  printf '%s\n' "print_ssh_menu_lines: start" >>"$debug_log"

  while IFS= read -r host; do
    config_files+=("$host")
  done < <(collect_ssh_config_files)

  if ((${#config_files[@]} == 0)); then
    printf '%s\n' "print_ssh_menu_lines: no config files" >>"$debug_log"
    return 0
  fi

  printf '%s\n' "print_ssh_menu_lines: files ${config_files[*]}" >>"$debug_log"

  # Extract only concrete host names (no wildcards or negations).
  while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    label="ssh-${host}"
    printf "%s\t%b%s%b\n" "ssh:${host}" "${base_color}" "$label" "${reset_color}"
    printf '%s\n' "print_ssh_menu_lines: host $host" >>"$debug_log"
  done < <(
    awk '
      {
        sub(/[ \t]*#.*/, "")
        if (tolower($1) == "host") {
          for (i = 2; i <= NF; i++) {
            h = $i
            if (h ~ /^[!]/) continue
            if (h ~ /[\\*?]/) continue
            print h
          }
        }
      }
    ' "${config_files[@]}" | sort -u
  )
}

if [[ "${1:-}" == "--reload" ]]; then
  print_menu_lines "${2:-}"
  exit 0
fi

focus_or_launch_dir() {
  local selected_path="$1"
  local selected_real=""
  local base=""
  local safe_base=""
  local hash=""
  local short_name=""
  local session_name=""
  local existing_session=""
  local session_dir="/tmp/kitty-zoxide-sessions"
  local session_file=""

  if [[ ! -d "$selected_path" ]]; then
    echo "Directory not found: $selected_path"
    exit 1
  fi

  selected_real="$(normalize_path "$selected_path")"

  existing_session="$(find_session_by_path "$selected_real" || true)"
  if [[ -n "$existing_session" ]]; then
    bump_zoxide_score "$selected_real"
    "$kitty_bin" @ --to "unix:${sock}" action goto_session "$existing_session"
    return 0
  fi

  base="$(basename "$selected_path")"
  safe_base="$(printf "%s" "$base" | tr -cs 'A-Za-z0-9._-' '_')"
  hash="$(hash_path "$selected_real")"
  hash="${hash:0:4}"
  short_name="z-${safe_base}"
  session_name="$short_name"
  if session_exists "$short_name"; then
    session_name="${short_name}-${hash}"
  fi

  mkdir -p "$session_dir"
  session_file="${session_dir}/${session_name}.kitty-session"

  cat >"$session_file" <<EOF
layout tall
cd ${selected_real}
launch --title "${base}"
focus
focus_os_window
EOF

  "$kitty_bin" @ --to "unix:${sock}" action goto_session "$session_file"
  bump_zoxide_score "$selected_real"
}

focus_or_launch_ssh() {
  local host="$1"
  local safe_host=""
  local session_dir="/tmp/kitty-zoxide-sessions"
  local session_file=""

  safe_host="$(printf "%s" "$host" | tr -cs 'A-Za-z0-9._-' '_')"

  mkdir -p "$session_dir"
  session_file="${session_dir}/ssh-${safe_host}.kitty-session"

  # SSH sessions intentionally skip zoxide path logic and just run ssh <host>.
  cat >"$session_file" <<EOF
layout tall
launch --title "ssh-${host}" ssh ${host}
focus
focus_os_window
EOF

  "$kitty_bin" @ --to "unix:${sock}" action goto_session "$session_file"
}

set +e
printf '\033[2J\033[H'
fzf_out="$(
  fzf --ansi --height=20 --reverse \
    --header="Type to filter, enter open, esc quit" \
    --prompt="Create New Kitty Session (zoxide + ssh) > " \
    --no-multi \
    --with-nth=2.. \
    --no-sort \
    --tiebreak=index \
    --expect=enter,esc \
    --bind 'enter:accept' \
    --bind 'esc:abort' \
    --bind "start:reload:${script_path} --reload \"{q}\"" \
    --bind "change:reload:${script_path} --reload \"{q}\"" \
    ${fzf_colors:+--color="$fzf_colors"}
)"
fzf_rc=$?
set -e

if [[ $fzf_rc -ne 0 && -z "${fzf_out:-}" ]]; then
  exit 0
fi

key="$(printf "%s\n" "$fzf_out" | head -n1)"
if [[ "$key" == "esc" ]]; then
  exit 0
fi

sel="$(printf "%s\n" "$fzf_out" | sed -n '2p' || true)"
selected_path=""
if [[ -n "${sel:-}" ]]; then
  selected_path="$(printf "%s" "$sel" | awk -F'\t' '{print $1}')"
fi

if [[ -z "${selected_path:-}" ]]; then
  exit 0
fi

if [[ "$selected_path" == ssh:* ]]; then
  focus_or_launch_ssh "${selected_path#ssh:}"
else
  focus_or_launch_dir "$selected_path"
fi
