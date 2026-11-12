#!/bin/bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/obs/zoominator/zoominator-toggle.sh

# Toggles the OBS Zoominator zoom (Forager hold-W + V, through skhd). Builds the
# Swift helper into ~/.cache on first use or after it changes, then runs it.
# Why a helper is needed at all: see zoominator_toggle.swift.

source_file="$(dirname "${BASH_SOURCE[0]}")/zoominator_toggle.swift"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zoominator"
bin="$cache_dir/zoominator-toggle"

mkdir -p "$cache_dir"
if [[ ! -x "$bin" || "$source_file" -nt "$bin" ]]; then
  swiftc -O -o "$bin.$$" "$source_file" &&
    mv -f "$bin.$$" "$bin"
fi

"$bin"
