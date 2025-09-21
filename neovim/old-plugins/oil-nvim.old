-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/oil-nvim.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/oil-nvim.lua
--
-- https://github.com/stevearc/oil.nvim

-- Use `-` to open oil, that's the default command, see the mapping below

-- From outside neovim, you can SSH to hosts using
-- -- nvim oil-ssh://docker1/
-- This takes you to the root dir
-- -- nvim oil-ssh://docker1//

-- From inside neovim you can SSH to hosts using
-- -- First type `:` to enter command mode, then enter
-- -- e oil-ssh://docker1/

-- https://github.com/stevearc/oil.nvim
return {
  "stevearc/oil.nvim",
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
  },
}
