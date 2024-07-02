-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
--
-- I think I grabbed the config from this plugin using Folke's lazyvim.org and
-- just made some changes on the top
-- http://www.lazyvim.org/plugins/ui#lualinenvim

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local fg_color = "#212337" -- Foreground color for the text

    local icons = LazyVim.config.icons
    opts.sections.lualine_c = {
      -- LazyVim.lualine.root_dir(),
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      -- { LazyVim.lualine.pretty_path() },
    }

    opts.sections.lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    }

    -- Disable lualine_z section which shows the time
    -- http://www.lazyvim.org/plugins/ui#lualinenvim
    opts.sections.lualine_z = {}

    -- Function to determine file permissions and appropriate background color
    local function get_permissions_color()
      local file = vim.fn.expand("%:p")
      if file == "" or file == nil then
        return "No File", "#0099ff" -- Default blue for no or non-existing file
      else
        local permissions = vim.fn.getfperm(file)
        -- Check only the first three characters for 'rwx' to determine owner permissions
        local owner_permissions = permissions:sub(1, 3)
        -- green for owner 'rwx', blue otherwise
        return permissions, owner_permissions == "rwx" and "#37f499" or "#04d1f9"
      end
    end

    -- Decide background color based on hostname's last character
    -- These colors match my starship profile
    local function decide_color()
      local hostname = vim.fn.systemlist("hostname")[1]
      local last_char = hostname:sub(-1)
      local bg_color = "#a48cf2" -- Default pink

      if last_char == "1" then
        bg_color = "#37f499"
      elseif last_char == "2" then
        bg_color = "#f16c75"
      elseif last_char == "3" then
        bg_color = "#f7c67f"
      end

      return bg_color
    end

    -- Hostname component with dynamically decided background color
    local bg_color = decide_color()

    -- Insert hostname component into lualine_x
    table.insert(opts.sections.lualine_x, 1, {
      "hostname",
      color = { fg = fg_color, bg = bg_color, gui = "bold" },
      separator = { left = "█", right = "" },
      -- separator = { left = "", right = "" },
      -- separator = { left = "", right = "" },
      -- separator = { left = "", right = "" },
      -- separator = { left = "", right = "" },
      padding = 0,
    })

    -- File permissions component with dynamic background color
    -- Insert file permissions component into lualine_x
    table.insert(opts.sections.lualine_x, 1, {
      function()
        if vim.bo.filetype ~= "markdown" then
          local permissions, _ = get_permissions_color() -- Ignore bg_color here if unused
          return permissions
        else
          return ""
        end
      end,
      color = function()
        if vim.bo.filetype ~= "markdown" then
          local _, permissions_bg_color = get_permissions_color() -- Use bg_color for dynamic coloring
          return { fg = fg_color, bg = permissions_bg_color, gui = "bold" }
        else
          return { fg = fg_color, bg = bg_color, gui = "bold" } -- Default color when markdown
        end
      end,
      separator = { left = "█", right = "█ " },
      padding = 0,
    })

    -- Function to check spelling status and determine background color
    local function spell_status()
      if vim.wo.spell then
        return "Spell: On"
      else
        return "Spell: Off"
      end
    end

    -- Function to determine the background color based on spelling status
    local function spell_bg_color()
      if vim.wo.spell then
        return "#37f499" -- Green for spell on
      else
        return "#f16c75" -- Red for spell off
      end
    end

    -- Insert spelling status component into lualine_x
    table.insert(opts.sections.lualine_x, 1, {
      spell_status,
      color = function()
        return { fg = fg_color, bg = spell_bg_color(), gui = "bold" }
      end,
      separator = { left = "", right = "█ " },
      padding = 0,
    })
  end,
}
