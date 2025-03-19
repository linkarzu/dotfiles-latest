-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope.lua
--
-- https://github.com/nvim-telescope/telescope.nvim

return {
  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
    opts = function()
      return {
        defaults = {
          -- Prevents cycle cycling looping through results when reach the end
          -- The default value is "cycle"
          scroll_strategy = "limit",
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
              ["<esc>"] = require("telescope.actions").close,
              -- I probably should use ctrl+key but since I use these already in
              -- lazygit they'll stay like this for now
              ["J"] = require("telescope.actions").preview_scrolling_down,
              ["K"] = require("telescope.actions").preview_scrolling_up,
              ["H"] = require("telescope.actions").preview_scrolling_left,
              ["L"] = require("telescope.actions").preview_scrolling_right,
            },
            -- When in insert mode, I want to quit telescope when I press escape
            -- instead of going to normal mode, to go to normal mode I can press
            -- my regular `kj`
            -- https://www.reddit.com/r/neovim/comments/1ghzlx4/comment/lv3jg0n/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
            i = {
              ["<esc>"] = require("telescope.actions").close,
              -- I probably should use ctrl+key but since I use these already in
              -- lazygit they'll stay like this for now
              ["J"] = require("telescope.actions").preview_scrolling_down,
              ["K"] = require("telescope.actions").preview_scrolling_up,
              ["H"] = require("telescope.actions").preview_scrolling_left,
              ["L"] = require("telescope.actions").preview_scrolling_right,
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
      -- { "<leader>fF", "<cmd>Telescope frecency theme=ivy<cr>", desc = "Find Files" },

      -- {
      --   "<leader>ff",
      --   "<cmd>Telescope frecency workspace=CWD path_display={'shorten'} theme=ivy<cr>",
      --   desc = "Find Files (Root Dir)",
      -- },
      -- {
      --   "<leader>ff",
      --   "<cmd>Telescope frecency workspace=CWD theme=ivy<cr>",
      --   desc = "Find Files (Root Dir)",
      -- },
      --

      {
        "<leader>fF",
        function()
          -- Get the directory of the currently active buffer
          local cwd = require("telescope.utils").buffer_dir()
          -- Use Telescope's find_files with a specific cwd
          require("telescope.builtin").find_files(require("telescope.themes").get_ivy({
            cwd = cwd,
            prompt_title = "Files in " .. cwd,
          }))
        end,
        desc = "Find Files (Buffer Dir)",
      },

      {
        "<leader>ff",
        function()
          local cwd = vim.fn.getcwd()
          require("telescope").extensions.frecency.frecency(require("telescope.themes").get_ivy({
            workspace = "CWD",
            cwd = cwd,
            prompt_title = "FRECENCY " .. cwd,
          }))
        end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<leader><Space>",
        function()
          local cwd = vim.fn.getcwd()
          require("telescope").extensions.frecency.frecency(require("telescope.themes").get_ivy({
            workspace = "CWD",
            cwd = cwd,
            prompt_title = "FRECENCY " .. cwd,
          }))
        end,
        desc = "Find Files (Root Dir) [Space]",
      },

      -- { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (cwd)" },
      {
        "<leader>sG",
        function()
          local cwd = require("telescope.utils").buffer_dir()
          require("telescope.builtin").live_grep(require("telescope.themes").get_ivy({
            cwd = cwd,
            prompt_title = "GREP " .. cwd,
          }))
        end,
        desc = "[P]Grep (buffer dir)",
      },

      -- I want to grep with fzf-lua, so disabling/disable this keymap for telescope
      -- { "<leader>sg", LazyVim.pick("live_grep", { root = false, theme = "ivy" }), desc = "Grep (Root Dir)" },
      -- {
      --   "<leader>sg",
      --   function()
      --     local cwd = vim.fn.getcwd()
      --     require("telescope.builtin").live_grep(require("telescope.themes").get_ivy({
      --       -- gets current working directory
      --       cwd = cwd,
      --       prompt_title = "GREP " .. cwd,
      --     }))
      --   end,
      --   desc = "[P]Grep (Root Dir)",
      -- },

      -- { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
      {
        "<leader>gs",
        function()
          require("telescope.builtin").git_status(require("telescope.themes").get_ivy({
            layout_config = {
              -- Set preview width, 0.7 sets it to 70% of the window width
              preview_width = 0.7,
              -- height = 0.2,
            },
            initial_mode = "normal", -- Start in normal mode
          }))
        end,
        desc = "Git Status (ivy theme with custom preview size)",
      },

      {
        "<leader><BS>",
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

      -- fzf-lua takes over this keymap, since I disaled fzf-lua, this keymap is
      -- gone, so I need to add it here for it to work
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
    },
  },
}
