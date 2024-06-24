-- Filename: ~/github/dotfiles-latest/neovim/nvim-lazyvim/lua/plugins/telescope.lua
-- ~/github/dotfiles-latest/neovim/nvim-lazyvim/lua/plugins/telescope.lua

-- https://github.com/nvim-telescope/telescope.nvim
-- http://www.lazyvim.org/plugins/editor#telescopenvim-optional

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- I swapped ff and fF because I normally use ff
      -- fF is NOT working properly as it only finds sibling files of current file, but I don't care
      -- You can do <spacebar><spacebar> to find files in the root dir
      -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#find-sibling-files-of-current-file
      -- I figured I needed to use 'telescope.builtin' on the telescope github page
      {
        "<leader>fF",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Find Files (cwd)",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({})
        end,
        desc = "Find Files (root dir)",
      },
      -- I tried disabling this keymap, but I couldn't
      -- So fuck it, I'm adding the keymap that I need here, which is to
      -- alternate between the last 2 files
      --
      -- I also tried overwriting this keymap in keymaps.lua but it was always
      -- overriden by this telescope.lua file
      {
        "<leader><space>",
        "<cmd>e #<cr>",
        desc = "Switch to Other Buffer",
      },
      -- This is used to open the BufExplorer plugin
      {
        "<leader>bb",
        "<cmd>BufExplorer<cr>",
        desc = "Open bufexplorer",
      },
      {
        "<leader>tt",
        "<cmd>TodoTelescope keywords=TODO<cr>",
        desc = "TODO Telescope",
      },
    },
  },
}
