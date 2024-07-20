-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope.lua
--
-- https://github.com/nvim-telescope/telescope.nvim

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- I swapped ff and fF because I normally use ff
      -- fF is NOT working properly as it only finds sibling files of current file, but I don't care
      -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#find-sibling-files-of-current-file
      -- I figured I needed to use 'telescope.builtin' on the telescope github page
      -- {
      --   "<leader>fF",
      --   function()
      --     require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
      --   end,
      --   desc = "Find Files (cwd)",
      -- },
      -- {
      --   "<leader>ff",
      --   function()
      --     require("telescope.builtin").find_files({})
      --   end,
      --   desc = "Find Files (root dir)",
      -- },

      -- I tried disabling this keymap, but I couldn't
      -- So fuck it, I'm adding the keymap that I need here, which is to
      -- alternate between the last 2 files
      --
      -- I also tried overwriting this keymap in keymaps.lua but it was always
      -- overriden by this telescope.lua file
      -- http://www.lazyvim.org/extras/editor/telescope#telescopenvim
      { "<leader>fF", LazyVim.pick("auto"), desc = "Find Files (cwd)" },
      { "<leader>ff", LazyVim.pick("auto", { root = false }), desc = "Find Files (Root Dir)" },
      { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (cwd)" },
      { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (Root Dir)" },
      {
        "<leader><space>",
        "<cmd>e #<cr>",
        desc = "Alternate buffer",
      },
      {
        "<leader>tl",
        "<cmd>TodoTelescope keywords=TODO<cr>",
        desc = "[P]TODO list (Telescope)",
      },
      {
        "<leader>ta",
        "<cmd>TodoTelescope keywords=PERF,HACK,TODO,NOTE,FIX<cr>",
        desc = "[P]TODO list ALL (Telescope)",
      },
    },
  },
}
