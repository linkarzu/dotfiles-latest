-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/disabled.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/disabled.lua

-- return {
--   -- If your search ends with an 'a' you enter insert mode and start modifying shit in the file, it sucks
--   { "folke/flash.nvim", enabled = false },
--   -- This is the plugin that shows tabs, I don't need it as I use BufExplorer and snipe
--   { "akinsho/bufferline.nvim", enabled = false },
-- }

-- is_neovide is set to "true" if running inside neovide because vim.g.neovide is set to true
-- Otherwise, default to "false"
local is_neovide = vim.g.neovide or false

return {
  -- If your search ends with an 'a' you enter insert mode and start modifying shit in the file, it sucks
  { "folke/flash.nvim", enabled = false },
  -- This is the plugin that shows tabs, I don't need it as I use BufExplorer and snipe
  -- I enable the plugin only if the is_neovide variable is set to true
  { "akinsho/bufferline.nvim", enabled = is_neovide },
  { "Rics-Dev/project-explorer.nvim", enabled = is_neovide },
}
