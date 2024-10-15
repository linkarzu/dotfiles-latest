-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
--
-- I think I grabbed the config from this plugin using Folke's lazyvim.org and
-- just made some changes on the top
-- http://www.lazyvim.org/plugins/ui#lualinenvim

-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
-- Description: Optimized Lualine configuration for Neovim.

local colors = require("config.colors").load_colors()
local icons = LazyVim.config.icons

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- Foreground color for the text
    local fg_color = colors["linkarzu_color07"]

    -- Function to determine background color based on the last character of the hostname
    local function get_hostname_bg_color()
      local hostname = vim.fn.hostname()
      local last_char = hostname:sub(-1)
      local color_map = {
        ["1"] = colors["linkarzu_color02"],
        ["2"] = colors["linkarzu_color08"],
        ["3"] = colors["linkarzu_color06"],
      }
      return color_map[last_char] or colors["linkarzu_color04"]
    end

    -- Function to retrieve file permissions and determine background color
    local function get_file_permissions()
      if vim.bo.filetype ~= "sh" then
        return "", colors["linkarzu_color03"]
      end

      local file_path = vim.fn.expand("%:p")
      if not file_path or file_path == "" then
        return "No File", colors["linkarzu_color03"]
      end

      local permissions = vim.fn.getfperm(file_path)
      local owner_permissions = permissions:sub(1, 3)
      local bg_color = (owner_permissions == "rwx") and colors["linkarzu_color02"] or colors["linkarzu_color03"]

      return permissions, bg_color
    end

    -- Condition to check if the permissions component should be displayed
    local function should_show_permissions()
      if vim.bo.filetype ~= "sh" then
        return false
      end
      local file_path = vim.fn.expand("%:p")
      return file_path and file_path ~= ""
    end

    -- Function to determine background color based on spell checking status
    local function get_spell_bg_color()
      return vim.wo.spell and colors["linkarzu_color02"] or colors["linkarzu_color08"]
    end

    -- Condition to check if the spell status component should be displayed
    local function should_show_spell_status()
      return vim.bo.filetype == "markdown" and vim.wo.spell
    end

    -- Function to generate the spell status text
    local function get_spell_status()
      local lang_map = {
        en = "English",
        es = "Spanish",
        -- Add more language mappings as needed
      }
      local lang = vim.bo.spelllang
      lang = lang_map[lang] or lang -- Fallback to language code if not mapped
      return "Spell: " .. lang
    end

    -- Function to check if any additional components are active
    local function has_additional_components()
      return should_show_permissions() or should_show_spell_status()
    end

    -- Function to create a hostname component with a specified right separator
    local function create_hostname_component(separator_right, condition)
      return {
        function()
          return vim.fn.hostname()
        end,
        color = { fg = fg_color, bg = get_hostname_bg_color(), gui = "bold" },
        separator = { left = "", right = separator_right },
        padding = 0,
        cond = condition,
      }
    end

    -- Function to get branch name and determine color
    local function get_branch_color()
      local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
      if branch == "live" then
        return { fg = colors["linkarzu_color11"], gui = "bold" }
      else
        return nil -- Use default color
      end
    end

    -- Function to get the current Python virtual environment name
    local function get_venv_name()
      local venv = os.getenv("VIRTUAL_ENV")
      if venv then
        return venv:match("([^/]+)$")
      else
        return ""
      end
    end

    -- Configure lualine_c with diagnostics
    opts.sections.lualine_c = {
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      -- You can add more components here if needed
    }

    -- Configure lualine_y with progress and location
    opts.sections.lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    }

    -- Disable lualine_z section which shows the time
    opts.sections.lualine_z = {}

    -- Configure lualine_b with branch and color condition
    opts.sections.lualine_b = {
      {
        "branch",
        color = get_branch_color,
        separator = { right = "" },
      },
      {
        get_venv_name,
        color = { fg = colors["linkarzu_color10"], bg = colors["linkarzu_color02"], gui = "bold" },
        separator = { right = "" },
      },
    }

    -- Add permissions component to lualine_x if conditions are met
    table.insert(opts.sections.lualine_x, 1, {
      get_file_permissions, -- Display permissions text
      cond = should_show_permissions,
      color = function()
        local _, bg_color = get_file_permissions()
        return { fg = fg_color, bg = bg_color, gui = "bold" }
      end,
      separator = { left = "█", right = " " },
      padding = 0,
    })

    -- Add spell status component to lualine_x if conditions are met
    table.insert(opts.sections.lualine_x, 1, {
      get_spell_status, -- Display spell status text
      cond = should_show_spell_status,
      color = function()
        return { fg = fg_color, bg = get_spell_bg_color(), gui = "bold" }
      end,
      separator = { left = "█", right = " " },
      padding = 0,
    })

    -- Create and add hostname components based on the presence of additional components
    local hostname_with_others = create_hostname_component("█ ", has_additional_components)
    local hostname_simple = create_hostname_component("", function()
      return not has_additional_components()
    end)

    table.insert(opts.sections.lualine_x, 1, hostname_with_others)
    table.insert(opts.sections.lualine_x, 1, hostname_simple)
  end,
}
