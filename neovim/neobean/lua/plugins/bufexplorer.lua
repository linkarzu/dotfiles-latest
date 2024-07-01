-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/bufexplorer.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/bufexplorer.lua
--
-- https://github.com/jlanzarotta/bufexplorer

return {
  {
    "jlanzarotta/bufexplorer",
    -- To load the plugin at startup, I set lazy to false
    lazy = false,
    -- Here you can configure other options for the plugin found in the customization section
    -- https://github.com/jlanzarotta/bufexplorer/blob/20f0440948653b5482d555a35a432135ba46a26d/doc/bufexplorer.txt#L132
    -- When I open bufexplorer I want to see relative paths, not absolute ones
    config = function()
      vim.g.bufExplorerShowRelativePath = 1
    end,
    -- In case you want to add keymaps, I probably won't use this one, but
    -- leaving it there
    keys = {
      {
        "<leader>bb",
        "<cmd>BufExplorer<cr>",
        desc = "Open bufexplorer",
      },
      -- {
      --   "<S-h>",
      --   "<cmd>BufExplorer<cr>",
      --   mode = "n",
      --   desc = "Open bufexplorer",
      -- },
      -- {
      --   "<S-l>",
      --   "<cmd>BufExplorer<cr>",
      --   mode = "n",
      --   desc = "Open bufexplorer",
      -- },
    },
  },
}
