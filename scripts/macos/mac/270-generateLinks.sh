#!/usr/bin/env bash

NVIM_APPNAME=neobean nvim ~/github/dotfiles-private/scripts/macos/mac/obs/meeting/py/vars.env

python3 ~/github/dotfiles-private/scripts/macos/mac/obs/meeting/py/generate_links.py
