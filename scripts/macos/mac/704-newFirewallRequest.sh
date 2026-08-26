#!/usr/bin/env bash

set -euo pipefail

work_env_file="$HOME/github/dotfiles-private/work/work-env.sh"
if [[ ! -f "$work_env_file" ]]; then
  printf 'Missing work environment file: %s\n' "$work_env_file" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$work_env_file"

downloads_dir="${FIREWALL_DOWNLOADS_DIR:-$HOME/Documents/work-downloads}"
projects_root="${FIREWALL_PROJECTS_ROOT:-${WORK_FIREWALL_PROJECTS_ROOT:?Missing WORK_FIREWALL_PROJECTS_ROOT}}"
request_date="${FIREWALL_REQUEST_DATE:-$(date +%y%m%d)}"
fzf_colors_file="$HOME/github/dotfiles-latest/colorscheme/active/active-fzf-colors.sh"
kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
kitty_socket_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh"
qat_launcher="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/555-skhdQatTask.sh"
session_launcher="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/550-skhdSession.sh"
work_session_file="${FIREWALL_KITTY_SESSION_FILE:-${WORK_KITTY_SESSION_FILE:?Missing WORK_KITTY_SESSION_FILE}}"
work_session_name="work"
daily_note_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh"
daily_notes_root="${FIREWALL_DAILY_NOTES_ROOT:-${WORK_DAILY_NOTE_DIR:?Missing WORK_DAILY_NOTE_DIR}}"
ticket_url_base="${FIREWALL_TICKET_URL_BASE:-${WORK_FIREWALL_TICKET_URL_BASE:?Missing WORK_FIREWALL_TICKET_URL_BASE}}"
ticket_prefix="${FIREWALL_TICKET_PREFIX:-${WORK_FIREWALL_TICKET_PREFIX:?Missing WORK_FIREWALL_TICKET_PREFIX}}"

open_in_work_session() {
  local markdown_file="$1"
  local sock=""
  local window_id=""
  local vim_path=""
  local attempt=0

  if ! command -v jq >/dev/null 2>&1; then
    printf 'jq is not installed or not in PATH.\n' >&2
    return 127
  fi
  if [[ ! -x "$kitty_bin" || ! -x "$kitty_socket_script" || ! -x "$session_launcher" ]]; then
    printf 'A required Kitty helper is missing or not executable.\n' >&2
    return 1
  fi
  if [[ ! -f "$work_session_file" ]]; then
    printf 'Work session file does not exist: %s\n' "$work_session_file" >&2
    return 1
  fi

  sock="$("$kitty_socket_script")"
  "$session_launcher" "$work_session_file"

  for ((attempt = 0; attempt < 50; attempt++)); do
    window_id="$(
      "$kitty_bin" @ --to "unix:${sock}" ls 2>/dev/null |
        jq -r --arg session "$work_session_name" '
          [
            .[]?.tabs[]?.windows[]?
            | select(.session_name == $session)
            | select(any(.foreground_processes[]?; ((.cmdline[0] // "") | split("/")[-1]) == "nvim"))
          ][0].id // empty
        '
    )"
    [[ -n "$window_id" ]] && break
    sleep 0.1
  done

  if [[ -n "${FZF_AI_SOCKET:-}" ]]; then
    sleep 0.2
    "$qat_launcher"
  fi

  if [[ -z "$window_id" ]]; then
    printf 'Could not find Neovim in Kitty session: %s\n' "$work_session_name" >&2
    return 1
  fi

  vim_path="${markdown_file//\'/\'\'}"
  "$kitty_bin" @ --to "unix:${sock}" send-text --match "id:${window_id}" '\x1c\x0e'
  printf '%s' ":execute 'edit ' . fnameescape('$vim_path')" |
    "$kitty_bin" @ --to "unix:${sock}" send-text --match "id:${window_id}" --stdin
  "$kitty_bin" @ --to "unix:${sock}" send-key --match "id:${window_id}" enter
}

if [[ "${1:-}" == "--open-markdown" ]]; then
  if [[ $# -ne 2 || ! -f "$2" ]]; then
    printf 'Usage: %s --open-markdown EXISTING_FILE\n' "$0" >&2
    exit 2
  fi
  open_in_work_session "$2"
  exit
fi

if ! command -v fzf >/dev/null 2>&1; then
  printf 'fzf is not installed or not in PATH.\n' >&2
  exit 127
fi
if [[ ! -d "$projects_root" ]]; then
  printf 'Projects directory does not exist: %s\n' "$projects_root" >&2
  exit 1
fi
if [[ -f "$fzf_colors_file" ]]; then
  # shellcheck disable=SC1090
  source "$fzf_colors_file"
fi

fzf_args=(--height=100% --reverse --no-multi)
if [[ -n "${linkarzu_fzf_colors:-}" ]]; then
  fzf_args+=(--color="$linkarzu_fzf_colors")
fi

prompt_for_text() {
  local header="$1"
  local prompt="$2"
  local output=""

  if output="$(printf '' | fzf "${fzf_args[@]}" --disabled --print-query \
    --bind='enter:accept' --header="$header" --prompt="$prompt > ")"; then
    :
  elif [[ -z "$output" ]]; then
    return 1
  fi
  printf '%s\n' "$output"
}

start_request() {
  local newest_workbook=""
  local newest_created=-1
  local workbook=""
  local workbook_name=""
  local created=""
  local selected_project=""
  local project_dir=""
  local project_path=""
  local directory_name=""
  local destination_dir=""
  local destination_file=""
  local markdown_file=""
  local suffix=0
  local workbooks=()
  local project_names=()

  if [[ ! -d "$downloads_dir" ]]; then
    printf 'Downloads directory does not exist: %s\n' "$downloads_dir" >&2
    return 1
  fi

  shopt -s nullglob
  workbooks=("$downloads_dir"/*.xlsx)
  shopt -u nullglob
  if [[ ${#workbooks[@]} -eq 0 ]]; then
    printf 'No .xlsx files found in: %s\n' "$downloads_dir" >&2
    return 1
  fi

  for workbook in "${workbooks[@]}"; do
    created="$(stat -f '%B' "$workbook")"
    if ((created > newest_created)); then
      newest_created="$created"
      newest_workbook="$workbook"
    fi
  done

  workbook_name="${newest_workbook##*/}"
  if ! printf '%s\n' "$workbook_name" | fzf "${fzf_args[@]}" \
    --header='Newest added workbook | Enter confirms | Esc cancels' \
    --prompt='Use workbook > ' >/dev/null; then
    printf 'Firewall request cancelled.\n'
    return 0
  fi

  for project_dir in "$projects_root"/*/; do
    [[ -d "$project_dir" ]] || continue
    project_dir="${project_dir%/}"
    project_names+=("${project_dir##*/}")
  done
  if [[ ${#project_names[@]} -eq 0 ]]; then
    printf 'No project directories found in: %s\n' "$projects_root" >&2
    return 1
  fi

  if ! selected_project="$(printf '%s\n' "${project_names[@]}" | fzf "${fzf_args[@]}" \
    --header='Choose the project for this firewall request' \
    --prompt='Project > ')"; then
    printf 'Firewall request cancelled.\n'
    return 0
  fi

  project_path="$projects_root/$selected_project"
  while true; do
    directory_name="$request_date"
    if ((suffix > 0)); then
      directory_name+="-$suffix"
    fi
    destination_dir="$project_path/$directory_name"

    if mkdir "$destination_dir" 2>/dev/null; then
      break
    fi
    if [[ ! -e "$destination_dir" ]]; then
      printf 'Could not create directory: %s\n' "$destination_dir" >&2
      return 1
    fi
    ((suffix += 1))
  done

  destination_file="$destination_dir/$workbook_name"
  if ! cp "$newest_workbook" "$destination_file"; then
    rmdir "$destination_dir" 2>/dev/null || true
    printf 'Could not copy workbook to: %s\n' "$destination_file" >&2
    return 1
  fi

  markdown_file="$destination_dir/a.md"
  if ! touch "$markdown_file"; then
    rm -f "$destination_file"
    rmdir "$destination_dir" 2>/dev/null || true
    printf 'Could not create Markdown file: %s\n' "$markdown_file" >&2
    return 1
  fi

  printf '\nFirewall request created.\n'
  printf 'Source:      %s\n' "$newest_workbook"
  printf 'Destination: %s\n' "$destination_file"
  printf 'Markdown:    %s\n' "$markdown_file"

  if [[ "${FIREWALL_SKIP_OPEN:-0}" != 1 ]]; then
    open_in_work_session "$markdown_file"
  fi
}

finalize_request() {
  local project_dir=""
  local request_dir=""
  local request_name=""
  local pending_file=""
  local pending_label=""
  local selected_pending=""
  local raw_ticket=""
  local ticket=""
  local ticket_url=""
  local target_file=""
  local target_tmp=""
  local pending_backup=""
  local daily_note=""
  local daily_tmp=""
  local task=""
  local confirmation=""
  local has_workbook=false
  local pending_labels=()
  local request_workbooks=()

  for project_dir in "$projects_root"/*/; do
    [[ -d "$project_dir" ]] || continue
    for request_dir in "$project_dir"/*/; do
      [[ -d "$request_dir" && -f "${request_dir}a.md" ]] || continue
      request_name="${request_dir%/}"
      request_name="${request_name##*/}"
      [[ "$request_name" =~ ^[0-9]{6}(-[0-9]+)?$ ]] || continue

      shopt -s nullglob
      request_workbooks=("$request_dir"*.xlsx)
      shopt -u nullglob
      has_workbook=false
      [[ ${#request_workbooks[@]} -gt 0 ]] && has_workbook=true
      [[ "$has_workbook" == true ]] || continue

      project_dir="${project_dir%/}"
      pending_labels+=("${project_dir##*/}/$request_name")
    done
  done

  if [[ ${#pending_labels[@]} -eq 0 ]]; then
    printf 'No pending firewall requests were found.\n' >&2
    return 1
  fi

  if ! selected_pending="$(printf '%s\n' "${pending_labels[@]}" | fzf "${fzf_args[@]}" \
    --header='Choose the pending a.md to finalize' \
    --prompt='Pending request > ')"; then
    printf 'Firewall request finalization cancelled.\n'
    return 0
  fi
  pending_file="$projects_root/$selected_pending/a.md"

  while true; do
    if [[ -n "${FIREWALL_TICKET_NUMBER:-}" ]]; then
      raw_ticket="$FIREWALL_TICKET_NUMBER"
    elif ! raw_ticket="$(prompt_for_text \
      'Enter a ticket number, with or without its prefix' \
      'Ticket number')"; then
      printf 'Firewall request finalization cancelled.\n'
      return 0
    fi

    ticket="$(printf '%s' "$raw_ticket" | tr '[:lower:]' '[:upper:]')"
    ticket="${ticket#"${ticket_prefix}-"}"
    if [[ "$ticket" =~ ^[0-9]+$ ]]; then
      ticket="SCTASK$ticket"
    fi
    [[ "$ticket" =~ ^SCTASK[0-9]+$ ]] && break
    printf 'Invalid ticket number: %s\n' "$raw_ticket" >&2
    [[ -n "${FIREWALL_TICKET_NUMBER:-}" ]] && return 1
  done

  while true; do
    if [[ -n "${FIREWALL_TICKET_URL:-}" ]]; then
      ticket_url="$FIREWALL_TICKET_URL"
    elif ! ticket_url="$(prompt_for_text \
      'Paste the ServiceNow ticket URL' \
      'Ticket URL')"; then
      printf 'Firewall request finalization cancelled.\n'
      return 0
    fi

    [[ "$ticket_url" == "$ticket_url_base" || "$ticket_url" == "$ticket_url_base/"* ]] && break
    printf 'Invalid ServiceNow URL.\n' >&2
    [[ -n "${FIREWALL_TICKET_URL:-}" ]] && return 1
  done

  target_file="${pending_file%/*}/$ticket.md"
  if [[ -e "$target_file" ]]; then
    printf 'Ticket file already exists: %s\n' "$target_file" >&2
    return 1
  fi

  if [[ ! -x "$daily_note_script" ]]; then
    printf 'Daily note script is missing or not executable: %s\n' "$daily_note_script" >&2
    return 1
  fi
  daily_note="$daily_notes_root/$(date +%Y)/$(date +%m)-$(date +%b)/$(date +%Y-%m-%d-%A).md"

  confirmation="$ticket | $selected_pending | $ticket_url"
  if ! printf '%s\n' "$confirmation" | fzf "${fzf_args[@]}" \
    --header="Finalize request and update ${daily_note##*/}?" \
    --prompt='Enter confirms > ' >/dev/null; then
    printf 'Firewall request finalization cancelled.\n'
    return 0
  fi

  daily_note="$(
    DAILY_NOTE_MODE=work \
      DAILY_NOTE_CREATE_ONLY=1 \
      DAILY_NOTE_MAIN_NOTE_DIR="$daily_notes_root" \
      "$daily_note_script"
  )"
  if [[ ! -f "$daily_note" ]]; then
    printf 'Could not create daily note: %s\n' "$daily_note" >&2
    return 1
  fi

  task="- [ ] [[$ticket]]"
  target_tmp="${target_file}.tmp.$$"
  pending_backup="${pending_file}.backup.$$"
  daily_tmp="${daily_note}.firewall.$$"
  printf '%s\n' "$ticket_url" >"$target_tmp"

  if grep -Fq "[[$ticket]]" "$daily_note"; then
    cp "$daily_note" "$daily_tmp"
  elif ! awk -v task="$task" '
    BEGIN { inserted = 0 }
    $0 == "## WORK DAILY NOTE" && !inserted {
      print
      if ((getline next_line) > 0) {
        print ""
        print task
        print ""
        if (next_line != "") print next_line
      } else {
        print ""
        print task
      }
      inserted = 1
      next
    }
    { print }
    END { if (!inserted) exit 2 }
  ' "$daily_note" >"$daily_tmp"; then
    rm -f "$target_tmp" "$daily_tmp"
    printf 'Daily note is missing the WORK DAILY NOTE heading: %s\n' "$daily_note" >&2
    return 1
  fi

  if ! mv "$pending_file" "$pending_backup"; then
    rm -f "$target_tmp" "$daily_tmp"
    printf 'Could not prepare pending file for finalization.\n' >&2
    return 1
  fi
  if ! mv "$target_tmp" "$target_file"; then
    mv "$pending_backup" "$pending_file" 2>/dev/null || true
    rm -f "$daily_tmp"
    printf 'Could not create ticket file: %s\n' "$target_file" >&2
    return 1
  fi
  if ! mv "$daily_tmp" "$daily_note"; then
    rm -f "$target_file"
    mv "$pending_backup" "$pending_file" 2>/dev/null || true
    printf 'Could not update daily note: %s\n' "$daily_note" >&2
    return 1
  fi
  rm -f "$pending_backup"

  printf '\nFirewall request finalized.\n'
  printf 'Ticket:     %s\n' "$target_file"
  printf 'Daily note: %s\n' "$daily_note"

  if [[ "${FIREWALL_SKIP_OPEN:-0}" != 1 ]]; then
    open_in_work_session "$target_file"
  fi
}

action="${FIREWALL_ACTION:-}"
if [[ -z "$action" ]]; then
  if ! action="$(printf '%s\n' \
    'Start a new firewall request' \
    'Finalize a pending firewall request' |
    fzf "${fzf_args[@]}" --header='Choose a firewall request action' --prompt='Action > ')"; then
    printf 'Firewall request cancelled.\n'
    exit 0
  fi
fi

case "$action" in
start|'Start a new firewall request')
  start_request
  ;;
finalize|'Finalize a pending firewall request')
  finalize_request
  ;;
*)
  printf 'Unknown firewall action: %s\n' "$action" >&2
  exit 2
  ;;
esac
