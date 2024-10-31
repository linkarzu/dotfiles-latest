-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/colorizer-nvim.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/colorizer-nvim.lua

-- https://github.com/norcalli/nvim-colorizer.lua
-- This plugin allows me to see the colors of hex code inside files

return {
  "norcalli/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup()
  end,
}
