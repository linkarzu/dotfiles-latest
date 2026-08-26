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

if ! command -v fzf >/dev/null 2>&1; then
  printf 'fzf is not installed or not in PATH.\n' >&2
  exit 127
fi
if [[ ! -d "$downloads_dir" ]]; then
  printf 'Downloads directory does not exist: %s\n' "$downloads_dir" >&2
  exit 1
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

shopt -s nullglob
workbooks=("$downloads_dir"/*.xlsx)
shopt -u nullglob

if [[ ${#workbooks[@]} -eq 0 ]]; then
  printf 'No .xlsx files found in: %s\n' "$downloads_dir" >&2
  exit 1
fi

newest_workbook=""
newest_created=-1
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
  exit 0
fi

project_names=()
for project_dir in "$projects_root"/*/; do
  [[ -d "$project_dir" ]] || continue
  project_dir="${project_dir%/}"
  project_names+=("${project_dir##*/}")
done

if [[ ${#project_names[@]} -eq 0 ]]; then
  printf 'No project directories found in: %s\n' "$projects_root" >&2
  exit 1
fi

if ! selected_project="$(printf '%s\n' "${project_names[@]}" | fzf "${fzf_args[@]}" \
  --header='Choose the project for this firewall request' \
  --prompt='Project > ')"; then
  printf 'Firewall request cancelled.\n'
  exit 0
fi

project_path="$projects_root/$selected_project"
suffix=0
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
    exit 1
  fi
  ((suffix += 1))
done

destination_file="$destination_dir/$workbook_name"
if ! cp "$newest_workbook" "$destination_file"; then
  rmdir "$destination_dir" 2>/dev/null || true
  printf 'Could not copy workbook to: %s\n' "$destination_file" >&2
  exit 1
fi

printf '\nFirewall request created.\n'
printf 'Source:      %s\n' "$newest_workbook"
printf 'Destination: %s\n' "$destination_file"

if [[ "${FIREWALL_NO_PAUSE:-0}" != 1 ]]; then
  printf '\nPress enter to close. ' >&2
  IFS= read -r _ </dev/tty
fi
