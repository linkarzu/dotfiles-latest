#!/usr/bin/env bash
set -euo pipefail

nvim_cmd() {
  NVIM_APPNAME=neobean nvim -- "$@"
}

cd "$HOME/github/dotfiles-private/scripts/macos/mac/variable-replacer"

python3 variable_replacer.py
