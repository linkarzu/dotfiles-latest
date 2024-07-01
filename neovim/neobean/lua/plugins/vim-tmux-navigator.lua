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
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
}
