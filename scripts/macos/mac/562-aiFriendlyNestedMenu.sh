#!/usr/bin/env bash

set -euo pipefail

# Five-level nested fzf example for the live API bridge.
#
# This script intentionally uses only normal fzf menus. When selected from the
# main tasks QAT, it inherits the fzf `--listen` socket configured by
# 240-systemTask.sh. Humans see the unchanged fzf interface while an AI reads
# the unknown live options and controls selection through fzf-ai.sh.
#
# The authoritative AI instructions are beside the cmd + alt + F3 binding in:
#   ~/github/dotfiles-latest/skhd/skhdrc

fzf_colors_file="$HOME/github/dotfiles-latest/colorscheme/active/active-fzf-colors.sh"

pick_menu() {
  local selection_type="$1"
  local header="$2"
  local prompt="$3"
  local fzf_args=()
  shift 3

  if [[ "$selection_type" == "multi" ]]; then
    header="$header | Tab marks multiple choices"
  fi

  fzf_args=(
    --height=100%
    --reverse
    --header="$header"
    --prompt="$prompt > "
  )
  if [[ "$selection_type" == "multi" ]]; then
    fzf_args+=(--multi)
  else
    fzf_args+=(--no-multi)
  fi
  if [[ -n "${linkarzu_fzf_colors:-}" ]]; then
    fzf_args+=(--color="$linkarzu_fzf_colors")
  fi

  printf '%s\n' "$@" | fzf "${fzf_args[@]}"
}

format_multi_selection() {
  local selections="$1"
  local item=""
  local formatted=""

  while IFS= read -r item; do
    [[ -n "$item" ]] || continue
    if [[ -n "$formatted" ]]; then
      formatted+=", "
    fi
    formatted+="$item"
  done <<<"$selections"

  printf '%s\n' "$formatted"
}

run_traversal() {
  local mission=""
  local destination=""
  local crew=""
  local crew_display=""
  local transport=""
  local report=""
  local destinations=()
  local transports=()
  local crew_roles=("Navigator" "Engineer" "Scientist" "Medic")
  local report_formats=("Concise summary" "Detailed checklist" "JSON record")

  if ! mission="$(pick_menu single \
    'level=1/5 | Choose a mission' \
    'Mission' \
    'Survey' 'Build' 'Repair')"; then
    printf 'Menu cancelled at level 1.\n'
    return 0
  fi

  case "$mission" in
  Survey)
    destinations=("Moon" "Mars" "Europa")
    ;;
  Build)
    destinations=("Orbital station" "Lunar base" "Deep-space relay")
    ;;
  Repair)
    destinations=("Space telescope" "Weather satellite" "Planetary rover")
    ;;
  esac

  if ! destination="$(pick_menu single \
    "level=2/5 | Mission: $mission | Choose a destination" \
    'Destination' \
    "${destinations[@]}")"; then
    printf 'Menu cancelled at level 2.\n'
    return 0
  fi

  if ! crew="$(pick_menu multi \
    "level=3/5 | $mission > $destination | Choose one or more crew roles" \
    'Crew roles' \
    "${crew_roles[@]}")"; then
    printf 'Menu cancelled at level 3.\n'
    return 0
  fi
  crew_display="$(format_multi_selection "$crew")"

  case "$mission" in
  Survey)
    transports=("Research shuttle" "Long-range probe" "Survey lander")
    ;;
  Build)
    transports=("Cargo ship" "Construction tug" "Heavy lander")
    ;;
  Repair)
    transports=("Service shuttle" "Robotic pod" "Recovery craft")
    ;;
  esac

  if ! transport="$(pick_menu single \
    "level=4/5 | $mission > $destination | Crew: $crew_display" \
    'Transport' \
    "${transports[@]}")"; then
    printf 'Menu cancelled at level 4.\n'
    return 0
  fi

  if ! report="$(pick_menu single \
    "level=5/5 | $mission > $destination > $transport" \
    'Report format' \
    "${report_formats[@]}")"; then
    printf 'Menu cancelled at level 5.\n'
    return 0
  fi

  printf '\nFZF_API_FLOW_SUCCESS\n'
  printf 'level_1_mission=%s\n' "$mission"
  printf 'level_2_destination=%s\n' "$destination"
  printf 'level_3_crew=%s\n' "$crew_display"
  printf 'level_4_transport=%s\n' "$transport"
  printf 'level_5_report=%s\n' "$report"
}

if ! command -v fzf >/dev/null 2>&1; then
  printf 'fzf is not installed or not in PATH.\n' >&2
  exit 127
fi
if [[ -f "$fzf_colors_file" ]]; then
  # shellcheck disable=SC1090
  source "$fzf_colors_file"
fi

run_traversal
printf '\nPress enter to close. ' >&2
IFS= read -r _ </dev/tty
