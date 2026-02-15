#!/usr/bin/env bash
set -euo pipefail

nvim_cmd() {
  NVIM_APPNAME=neobean nvim "$@"
}

base_dir="$HOME/github/dotfiles-private/scripts/macos/mac/subnet-finder"
input_file="$base_dir/01-enter-ips.txt"
validator_file="$base_dir/02-run-validator.sh"
finder_file="$base_dir/03-run-finder.sh"
matches_file="$base_dir/matches.txt"

nvim_cmd "$input_file"

"$validator_file"
SHOW_IPS=0 bash "$finder_file"

nvim_cmd "$matches_file"
