#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/kitty/scripts/kitty-zoxide-session.sh
# Select a zoxide entry and switch to an existing kitty session,
# or create it if it doesn't exist.

set -euo pipefail

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"
work_env_file="$HOME/github/dotfiles-private/work/work-env.sh"

if [[ -f "$work_env_file" ]]; then
  # shellcheck disable=SC1090
  source "$work_env_file"
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

print_menu_lines() {
  local query="${1:-}"
  zoxide query -l 2>/dev/null | awk -v OFS='\t' -v work_dir="${work_main_dir}" '{
    path=$0
    if (work_dir != "" && (path == work_dir || index(path, work_dir "/") == 1)) next
    n=split(path, parts, "/")
    base=parts[n]
    if (base == "") base=path
    printf "%s\t%s  %s\n", path, base, path
  }'
}

if [[ "${1:-}" == "--reload" ]]; then
  print_menu_lines "${2:-}"
  exit 0
fi

focus_or_launch() {
  local selected_path="$1"
  local selected_real=""
  local base=""
  local safe_base=""
  local hash=""
  local session_dir="/tmp/kitty-zoxide-sessions"
  local session_file=""

  if [[ ! -d "$selected_path" ]]; then
    echo "Directory not found: $selected_path"
    exit 1
  fi

  selected_real="$(normalize_path "$selected_path")"

  base="$(basename "$selected_path")"
  safe_base="$(printf "%s" "$base" | tr -cs 'A-Za-z0-9._-' '_')"
  hash="$(hash_path "$selected_real")"
  hash="${hash:0:8}"

  mkdir -p "$session_dir"
  session_file="${session_dir}/zoxide__${safe_base}__${hash}.kitty-session"

  cat >"$session_file" <<EOF
layout tall
cd ${selected_real}
launch --title "${base}"
focus
focus_os_window
EOF

  "$kitty_bin" @ --to "unix:${sock}" action goto_session "$session_file"
}

set +e
fzf_out="$(
  fzf --ansi --height=10 --reverse \
    --header="Type to filter, enter open, esc quit" \
    --prompt="Zoxide > " \
    --no-multi \
    --with-nth=2.. \
    --expect=enter,esc \
    --bind 'enter:accept' \
    --bind 'esc:abort' \
    --no-clear \
    --bind "start:reload:${script_path} --reload \"{q}\"" \
    --bind "change:reload:${script_path} --reload \"{q}\""
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

focus_or_launch "$selected_path"
