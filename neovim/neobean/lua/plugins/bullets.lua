-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/bullets.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/bullets.lua
--
-- This plugin automatically adds bulletpoints on the next line respecting
-- indentation
-- In markdown or a text file start a bulleted list using - or *. Press return
-- to go to the next line, a new list item will be created.
--
-- When in insert mode, you can increase indentation with ctrl+t and decrease it
-- with ctrl+d
--
-- By default its enabled on filetypes 'markdown', 'text', 'gitcommit', 'scratch'
-- https://github.com/bullets-vim/bullets.vim

return {
  "bullets-vim/bullets.vim",
  -- NOTE: enable the plugin only for specific filetypes, if you don't do this,
  -- and you use the new snacks picker by folke, you won't be able to select a
  -- file with <CR> when in insert mode, only in normal mode
  -- https://github.com/folke/snacks.nvim/issues/812
  --
  -- This didn't work, added vim.g.bullets_enable_in_empty_buffers = 0 to
  -- ~/github/dotfiles-latest/neovim/neobean/init.lua
  -- ft = { "markdown", "text", "gitcommit", "scratch" },
  config = function()
    -- Disable deleting the last empty bullet when pressing <cr> or 'o'
    -- default = 1
    -- 2 works similar ot Obsidian https://github.com/bullets-vim/bullets.vim/pull/163
    vim.g.bullets_delete_last_bullet_if_empty = 2

    -- (Optional) Add other configurations here
    -- For example, enabling/disabling mappings
    -- vim.g.bullets_set_mappings = 1
  end,
}
