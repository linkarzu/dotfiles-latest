-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/vim-tmux-navigator.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/vim-tmux-navigator.lua

-- https://github.com/christoomey/vim-tmux-navigator
--
-- This plugin allows me to switch between neovim and tmux panes using
-- ctrl+vim-motions, for it to work with tmux panes, you also need to install
-- the same plugin in tmux

return {
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      -- Switch to other tmux panes not only when in normal mode, but also
      -- insert and visual mode
      { "<C-h>", '<cmd>TmuxNavigateLeft("n")<cr>', mode = { "n", "v", "i" }, desc = "TmuxNavigateLeft" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "v", "i" }, desc = "TmuxNavigateDown" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "v", "i" }, desc = "TmuxNavigateUp" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "v", "i" }, desc = "TmuxNavigateRight" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", mode = { "n", "v", "i" }, desc = "TmuxNavigatePrevious" },
    },
  },
}
