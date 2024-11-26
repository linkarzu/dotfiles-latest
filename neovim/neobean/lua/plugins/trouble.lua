-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/trouble.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/trouble.lua

return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      lsp = {
        win = { position = "right" },
      },
    },
    keys = {
      -- If I close the incorrect pane, I can bring it up with ctrl+o
      ["<esc>"] = "close",
    },
  },
}
