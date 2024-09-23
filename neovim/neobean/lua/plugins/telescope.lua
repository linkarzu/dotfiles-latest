-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope.lua
--
-- https://github.com/nvim-telescope/telescope.nvim

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      return {
        defaults = {
          -- I'm adding this `find_command` based on this reddit discussion
          -- https://www.reddit.com/r/neovim/comments/1egczrs/comment/lfsotjx/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
          -- However, it doesn't work, also tried without the setup function
          require("telescope").setup({
            pickers = {
              find_files = {
                find_command = { "rg", "--files", "--sortr=modified" },
              },
            },
          }),
          -- When I search for stuff in telescope, I want the path to be shown
          -- first, this helps in files that are very deep in the tree and I
          -- cannot see their name.
          -- Also notice the "reverse_directories" option which will show the
          -- closest dir right after the filename
          path_display = {
            filename_first = {
              reverse_directories = true,
            },
          },
          mappings = {
            n = {
              -- I'm used to closing buffers with "d" from bufexplorer
              ["d"] = require("telescope.actions").delete_buffer,
              -- I'm also used to quitting bufexplorer with q instead of escape
              ["q"] = require("telescope.actions").close,
            },
          },
        },
      }
    end,
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
      -- { "<leader>fF", LazyVim.pick("auto"), desc = "Find Files (cwd)" },
      --
      { "<leader>fF", "<cmd>Telescope frecency theme=ivy<cr>", desc = "Find Files" },
      -- {
      --   "<leader>ff",
      --   "<cmd>Telescope frecency workspace=CWD path_display={'shorten'} theme=ivy<cr>",
      --   desc = "Find Files (Root Dir)",
      -- },
      {
        "<leader>ff",
        "<cmd>Telescope frecency workspace=CWD theme=ivy<cr>",
        desc = "Find Files (Root Dir)",
      },

      -- { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (cwd)" },
      {
        "<leader>sG",
        function()
          require("telescope.builtin").live_grep(require("telescope.themes").get_ivy())
        end,
        desc = "Grep (cwd)",
      },

      -- { "<leader>sg", LazyVim.pick("live_grep", { root = false, theme = "ivy" }), desc = "Grep (Root Dir)" },
      {
        "<leader>sg",
        function()
          require("telescope.builtin").live_grep(require("telescope.themes").get_ivy({ root = false }))
        end,
        desc = "Grep (Root Dir)",
      },

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
