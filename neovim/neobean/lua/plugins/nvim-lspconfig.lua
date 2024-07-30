-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lspconfig.lua
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lspconfig.lua
--
-- https://github.com/neovim/nvim-lspconfig

local lsp = "intelephense"

return {
  "neovim/nvim-lspconfig",
  opts = {

    -- This disables inlay hints
    -- When programming in Go, these made my experience feel like shit, because were
    -- very intrusive and I never got used to them.
    --
    -- Folke has a keymap to toggle inaly hints with <leader>uh
    inlay_hints = { enabled = false },

    servers = {
      -- phpactor = {
      --   enabled = lsp == "phpactor",
      -- },
      intelephense = {
        enabled = lsp == "intelephense",
      },
      [lsp] = {
        enabled = true,
      },
    },
  },
}
