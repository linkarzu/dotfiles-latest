#!/usr/bin/env bash

set -euo pipefail

font_size="${1:?Usage: 553-applyRecordingUi.sh FONT_SIZE TEXT_WIDTH}"
text_width="${2:?Usage: 553-applyRecordingUi.sh FONT_SIZE TEXT_WIDTH}"
dotfiles_dir="$HOME/github/dotfiles-latest"
kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
kitty_conf="$dotfiles_dir/kitty/kitty.conf"
neovim_options="$dotfiles_dir/neovim/neobean/lua/config/options.lua"
virt_column_conf="$dotfiles_dir/neovim/neobean/lua/plugins/virt-column.lua"
prettier_conf="$dotfiles_dir/.prettierrc.yaml"
website_prettier_conf="/System/Volumes/Data/mnt/github_nfs/linkarzu.github.io/.prettierrc.yaml"
nvim_server_dir="${TMPDIR%/}/nvim.${USER}"

if [[ ! "$font_size" =~ ^[0-9]+([.][0-9]+)?$ || ! "$text_width" =~ ^[0-9]+$ ]]; then
  echo "Font size and text width must be numeric." >&2
  exit 1
fi

sed -i '' "s/^font_size .*/font_size $font_size/" "$kitty_conf"
sed -i '' -E "/^else$/,/^  vim.opt.wrap = true$/ s/^([[:space:]]*vim\.opt\.textwidth = )[0-9]+/\\1${text_width}/" "$neovim_options"
sed -i '' -E "s/^([[:space:]]*virtcolumn = \")[0-9]+(\",)/\\1${text_width}\\2/" "$virt_column_conf"
sed -i '' -E "/^  - files: \"\\*\\.md\"$/,/^  - files:/ s/^([[:space:]]*printWidth: )[0-9]+/\\1${text_width}/" "$prettier_conf"
sed -i '' -E "/^  - files: \"\\*\\.md\"$/,/^  - files:/ s/^([[:space:]]*printWidth: )[0-9]+/\\1${text_width}/" "$website_prettier_conf"

sed -i '' -E "/^else$/,/^[[:space:]]*vim\.opt\.colorcolumn = \x22[0-9]+\x22$/ s/^([[:space:]]*vim\.opt\.colorcolumn = \x22)[0-9]+(\x22)/\1${text_width}\2/" "$neovim_options"

grep -Eq "^font_size ${font_size}([.]0)?$" "$kitty_conf"
grep -Eq "^[[:space:]]*vim[.]opt[.]textwidth = ${text_width}$" "$neovim_options"
grep -Eq "^[[:space:]]*vim[.]opt[.]colorcolumn = \"${text_width}\"$" "$neovim_options"
grep -Eq "^[[:space:]]*virtcolumn = \"${text_width}\"," "$virt_column_conf"
grep -Eq "^[[:space:]]*printWidth: ${text_width}$" "$prettier_conf"
grep -Eq "^[[:space:]]*printWidth: ${text_width}$" "$website_prettier_conf"

updated_sockets=0
for sock in /tmp/kitty-*; do
  [[ -S "$sock" ]] || continue
  if "$kitty_bin" @ --to "unix:${sock}" set-font-size --all "$font_size" >/dev/null 2>&1; then
    updated_sockets=$((updated_sockets + 1))
  fi
done

if [[ "$updated_sockets" -eq 0 ]]; then
  echo "No running kitty socket accepted the font-size update." >&2
  exit 1
fi

updated_nvim=0
remote_expr="luaeval(\"(function(width) vim.opt_global.textwidth = width; vim.opt_global.colorcolumn = tostring(width); for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do pcall(vim.api.nvim_set_option_value, 'textwidth', width, { buf = bufnr }) end; for _, winid in ipairs(vim.api.nvim_list_wins()) do pcall(vim.api.nvim_set_option_value, 'colorcolumn', tostring(width), { win = winid }) end; pcall(function() require('virt-column').update({ virtcolumn = tostring(width) }) end); vim.cmd('redraw!'); return true end)(_A)\", ${text_width})"
for server in "$nvim_server_dir"/*/*; do
  [[ -S "$server" ]] || continue
  if nvim --server "$server" --remote-expr "$remote_expr" >/dev/null 2>&1; then
    updated_nvim=$((updated_nvim + 1))
  fi
done

if [[ "$updated_nvim" -eq 0 ]]; then
  echo "No running Neovim server accepted the recording UI update." >&2
  exit 1
fi

printf 'Updated %s kitty socket(s) and %s running Neovim instance(s) in place.\n' \
  "$updated_sockets" "$updated_nvim"
