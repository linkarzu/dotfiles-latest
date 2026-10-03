-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.pumblend = 5
vim.opt.winblend = 5
vim.g.lazyvim_ts_lsp = "tsgo"

-- Use one rustup toolchain for rust-analyzer, cargo, rustc, clippy and rustfmt.
-- Homebrew's Rust binaries may otherwise take precedence over rustup's analyzer.
local cargo_bin = vim.fn.expand("~/.cargo/bin")
if vim.fn.executable(cargo_bin .. "/rustup") == 1 and not vim.env.PATH:find("^" .. vim.pesc(cargo_bin) .. ":") then
  vim.env.PATH = cargo_bin .. ":" .. vim.env.PATH
end

if vim.g.neovide then
  vim.g.neovide_opacity = 0.85
  vim.g.neovide_normal_opacity = 0.85
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
end
