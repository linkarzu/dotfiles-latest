#!/usr/bin/env bash

set -euo pipefail

font_size="${1:?Usage: 553-applyRecordingUi.sh FONT_SIZE TEXT_WIDTH}"
text_width="${2:?Usage: 553-applyRecordingUi.sh FONT_SIZE TEXT_WIDTH}"
dotfiles_dir="${DOTFILES_DIR:-$HOME/github/dotfiles-latest}"
kitty_bin="${KITTY_BIN:-/Applications/kitty.app/Contents/MacOS/kitty}"
kitty_conf="$dotfiles_dir/kitty/kitty.conf"
neovim_options="$dotfiles_dir/neovim/neobean/lua/config/options.lua"
virt_column_conf="$dotfiles_dir/neovim/neobean/lua/plugins/virt-column.lua"
prettier_conf="$dotfiles_dir/.prettierrc.yaml"
website_prettier_conf="${WEBSITE_PRETTIER_CONF:-/System/Volumes/Data/mnt/github_nfs/linkarzu.github.io/.prettierrc.yaml}"
nvim_server_dir="${NVIM_SERVER_DIR:-${TMPDIR%/}/nvim.${USER}}"
kitty_socket_dir="${KITTY_SOCKET_DIR:-/tmp}"
live_update_timeout="${LIVE_UPDATE_TIMEOUT_SECONDS:-5}"

if [[ ! "$font_size" =~ ^[0-9]+([.][0-9]+)?$ || ! "$text_width" =~ ^[0-9]+$ ]]; then
  echo "Font size and text width must be numeric." >&2
  exit 1
fi

run_bounded() {
  python3 - "$live_update_timeout" "$@" <<'PY'
import subprocess
import sys

try:
    completed = subprocess.run(
        sys.argv[2:],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        timeout=float(sys.argv[1]),
        check=False,
    )
except subprocess.TimeoutExpired:
    raise SystemExit(124)
raise SystemExit(completed.returncode)
PY
}

apply_persistent_config() {
  sed -i '' "s/^font_size .*/font_size $font_size/" "$kitty_conf" &&
    sed -i '' -E "/^else$/,/^  vim.opt.wrap = true$/ s/^([[:space:]]*vim\.opt\.textwidth = )[0-9]+/\\1${text_width}/" "$neovim_options" &&
    sed -i '' -E "s/^([[:space:]]*virtcolumn = \x22)[0-9]+(\x22,)/\\1${text_width}\\2/" "$virt_column_conf" &&
    sed -i '' -E "/^  - files: \"\\*\\.md\"$/,/^  - files:/ s/^([[:space:]]*printWidth: )[0-9]+/\\1${text_width}/" "$prettier_conf" &&
    sed -i '' -E "/^  - files: \"\\*\\.md\"$/,/^  - files:/ s/^([[:space:]]*printWidth: )[0-9]+/\\1${text_width}/" "$website_prettier_conf" &&
    sed -i '' -E "/^else$/,/^[[:space:]]*vim\.opt\.colorcolumn = \x22[0-9]+\x22$/ s/^([[:space:]]*vim\.opt\.colorcolumn = \x22)[0-9]+(\x22)/\1${text_width}\2/" "$neovim_options" &&
    grep -Eq "^font_size ${font_size}([.]0)?$" "$kitty_conf" &&
    grep -Eq "^[[:space:]]*vim[.]opt[.]textwidth = ${text_width}$" "$neovim_options" &&
    grep -Eq "^[[:space:]]*vim[.]opt[.]colorcolumn = \"${text_width}\"$" "$neovim_options" &&
    grep -Eq "^[[:space:]]*virtcolumn = \"${text_width}\"," "$virt_column_conf" &&
    grep -Eq "^[[:space:]]*printWidth: ${text_width}$" "$prettier_conf" &&
    grep -Eq "^[[:space:]]*printWidth: ${text_width}$" "$website_prettier_conf"
}

printf 'phase=recording-ui step=persistent-config status=start expected=font-%s-width-%s-files-verified\n' \
  "$font_size" "$text_width"
if ! apply_persistent_config; then
  printf 'phase=recording-ui step=persistent-config status=failure observed=file-update-or-verification-failed\n' >&2
  exit 1
fi
printf 'phase=recording-ui step=persistent-config status=success observed=font-%s-width-%s-files-verified\n' \
  "$font_size" "$text_width"

updated_sockets=0
for sock in "$kitty_socket_dir"/kitty-*; do
  [[ -S "$sock" ]] || continue
  if run_bounded "$kitty_bin" @ --to "unix:${sock}" set-font-size --all "$font_size"; then
    updated_sockets=$((updated_sockets + 1))
  fi
done

if [[ "$updated_sockets" -eq 0 ]]; then
  echo "No running kitty socket accepted the font-size update." >&2
  exit 1
fi

updated_nvim=0
nvim_socket_count=0
nvim_timeout_count=0
remote_expr="luaeval(\"(function(width) vim.opt_global.textwidth = width; vim.opt_global.colorcolumn = tostring(width); for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do pcall(vim.api.nvim_set_option_value, 'textwidth', width, { buf = bufnr }) end; for _, winid in ipairs(vim.api.nvim_list_wins()) do pcall(vim.api.nvim_set_option_value, 'colorcolumn', tostring(width), { win = winid }) end; pcall(function() require('virt-column').update({ virtcolumn = tostring(width) }) end); vim.cmd('redraw!'); return true end)(_A)\", ${text_width})"
for server in "$nvim_server_dir"/*/*; do
  [[ -S "$server" ]] || continue
  nvim_socket_count=$((nvim_socket_count + 1))
  if run_bounded nvim --server "$server" --remote-expr "$remote_expr"; then
    updated_nvim=$((updated_nvim + 1))
  else
    result=$?
    if [[ "$result" -eq 124 ]]; then
      nvim_timeout_count=$((nvim_timeout_count + 1))
    fi
  fi
done

if [[ "$nvim_timeout_count" -gt 0 ]]; then
  printf 'phase=recording-ui step=neovim-live-update status=timeout observed=server-unresponsive sockets=%s timeout_seconds=%s\n' \
    "$nvim_socket_count" "$live_update_timeout" >&2
  exit 1
fi
if [[ "$updated_nvim" -eq 0 ]] && pgrep -x nvim >/dev/null 2>&1; then
  printf 'phase=recording-ui step=neovim-live-update status=failure observed=running-neovim-unreachable sockets=%s\n' \
    "$nvim_socket_count" >&2
  exit 1
fi
if [[ "$updated_nvim" -eq 0 ]]; then
  printf 'phase=recording-ui step=neovim-live-update status=skipped observed=no-running-neovim persistent_config=verified\n'
else
  printf 'phase=recording-ui step=neovim-live-update status=success observed=running-instances-updated count=%s\n' \
    "$updated_nvim"
fi

printf 'Updated %s kitty socket(s) and %s running Neovim instance(s) in place.\n' \
  "$updated_sockets" "$updated_nvim"
