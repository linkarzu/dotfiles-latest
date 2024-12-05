-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- This disables or enables the plugin
    -- I'm switching over to mini.files (mini-files.lua) because neotree had
    -- some issues for me, when renaming files or directories sometimes they
    -- didn't update so had to be using oil.nvim
    enabled = true,
    keys = {
      -- I'm using these 2 keyamps already with mini.files, so avoiding conflict
      { "<leader>e", false },
      { "<leader>E", false },
      -- -- I swapped these 2
      -- { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      -- { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      -- New mapping for spacebar+r to reveal in NeoTree
      -- New mapping for spacebar+r to reveal in NeoTree with toggle functionality

      -- -- When I press <leader>r I want to show the current file in neo-tree,
      -- -- But if neo-tree is open it, close it, to work like a toggle
      {
        "<leader>r",
        function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          -- Function to check if NeoTree is open in any window
          local function is_neo_tree_open()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "neo-tree" then
                return true
              end
            end
            return false
          end
          -- Check if the current file exists
          if vim.fn.filereadable(buf_name) == 1 or vim.fn.isdirectory(vim.fn.fnamemodify(buf_name, ":p:h")) == 1 then
            if is_neo_tree_open() then
              -- Close NeoTree if it's open
              vim.cmd("Neotree close")
            else
              -- Open NeoTree and reveal the current file
              vim.cmd("Neotree reveal")
            end
          else
            -- If the file doesn't exist, execute the logic for <leader>R
            require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
          end
        end,
        desc = "[P]Toggle current file in NeoTree or open cwd if file doesn't exist",
      },
      {
        "<leader>R",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },

      -- {
      --   "<leader>r",
      --   function()
      --     vim.cmd("Neotree reveal")
      --   end,
      --   desc = "Reveal current file in NeoTree",
      -- },
    },
    opts = {
      filesystem = {
        -- Had to disable this option, because when I open neotree it was
        -- jumping around to random dirs when I opened a dir
        follow_current_file = { enabled = false },

        -- ###################################################################
        --                     custom delete command
        -- ###################################################################
        -- Adding custom commands for delete and delete_visual
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/202#issuecomment-1428278234
        commands = {
          -- over write default 'delete' command to 'trash'.
          delete = function(state)
            if vim.fn.executable("trash") == 0 then
              vim.api.nvim_echo({
                { "- Trash utility not installed. Make sure to install it first\n", nil },
                { "- In macOS run `brew install trash`\n", nil },
                { "- Or delete the `custom delete command` section in neo-tree", nil },
              }, false, {})
              return
            end
            local inputs = require("neo-tree.ui.inputs")
            local path = state.tree:get_node().path
            local msg = "Are you sure you want to trash " .. path
            inputs.confirm(msg, function(confirmed)
              if not confirmed then
                return
              end

              vim.fn.system({ "trash", vim.fn.fnameescape(path) })
              require("neo-tree.sources.manager").refresh(state.name)
            end)
          end,
          -- Overwrite default 'delete_visual' command to 'trash' x n.
          delete_visual = function(state, selected_nodes)
            if vim.fn.executable("trash") == 0 then
              vim.api.nvim_echo({
                { "- Trash utility not installed. Make sure to install it first\n", nil },
                { "- In macOS run `brew install trash`\n", nil },
                { "- Or delete the `custom delete command` section in neo-tree", nil },
              }, false, {})
              return
            end
            local inputs = require("neo-tree.ui.inputs")

            -- Function to get the count of items in a table
            local function GetTableLen(tbl)
              local len = 0
              for _ in pairs(tbl) do
                len = len + 1
              end
              return len
            end

            local count = GetTableLen(selected_nodes)
            local msg = "Are you sure you want to trash " .. count .. " files?"
            inputs.confirm(msg, function(confirmed)
              if not confirmed then
                return
              end
              for _, node in ipairs(selected_nodes) do
                vim.fn.system({ "trash", vim.fn.fnameescape(node.path) })
              end
              require("neo-tree.sources.manager").refresh(state.name)
            end)
          end,
        },
        -- ###################################################################
      },
    },
  },
}
