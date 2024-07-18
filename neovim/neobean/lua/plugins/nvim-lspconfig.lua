-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lspconfig.lua
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lspconfig.lua
--
-- https://github.com/neovim/nvim-lspconfig
--
-- This disables inlay hints
-- When programming in Go, these made my experience feel like shit, because were
-- very intrusive and I never got used to them.
--
-- Folke has a keymap to toggle inaly hints with <leader>uh

return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
  },
}
