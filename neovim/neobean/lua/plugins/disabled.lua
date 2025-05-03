-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/disabled.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/disabled.lua

-- is_neovide is set to "true" if running inside neovide because vim.g.neovide is set to true
-- Otherwise, default to "false"
local is_neovide = vim.g.neovide or false

return {
  -- -- If your search ends with an 'a' you enter insert mode and start modifying shit in the file, it sucks
  -- -- I'm giving flash a 2nd chance, I use my j and k too much
  -- { "folke/flash.nvim", enabled = false },

  -- This is the plugin that shows tabs, I don't need it as I use BufExplorer and snipe
  -- I enable the plugin only if the is_neovide variable is set to true
  { "akinsho/bufferline.nvim", enabled = is_neovide },
  { "Rics-Dev/project-explorer.nvim", enabled = is_neovide },

  -- NOTE: Disable neovide plugins in the plugin itself, see:
  -- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/smear-cursor.lua
  --
  -- -- -- Disable '3rd/image.nvim' if running Neovide, or you will get the error:
  -- -- -- Failed to run `config` for image.nvim
  -- -- -- .../lazy/image.nvim/lua/image/utils/term.lua:34: Failed to get terminal size
  -- {
  --   "3rd/image.nvim",
  --   cond = function()
  --     return not (vim.g.neovide == true)
  --   end,
  -- },
}
