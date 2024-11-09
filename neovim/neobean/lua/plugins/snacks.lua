-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snacks.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snacks.lua

-- Folke pointed me to the snacks docs
-- https://github.com/LazyVim/LazyVim/discussions/4251#discussioncomment-11198069
-- Here's the lazygit snak docs
-- https://github.com/folke/snacks.nvim/blob/main/docs/lazygit.md

return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        theme = {
          selectedLineBgColor = { bg = "CursorLine" },
        },
      },
      notifier = {
        enabled = false,
      },
    },
  },
}
