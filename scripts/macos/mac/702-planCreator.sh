#!/usr/bin/env bash
set -euo pipefail

nvim_cmd() {
  NVIM_APPNAME=neobean nvim -- "$@"
}

cd "$HOME/github/dotfiles-private/scripts/macos/mac/plan-creator"

if [[ ! -f ".venv/bin/activate" ]]; then
  python3 -m venv ".venv"
fi

# shellcheck disable=SC1091
source ".venv/bin/activate"

python generate_plan.py --sortasc --ranges

nvim_cmd "$HOME/github/dotfiles-private/scripts/macos/mac/subnet-finder/matches.txt"
nvim_cmd "$HOME/github/dotfiles-private/scripts/macos/mac/plan-creator/generated-plan.md"
