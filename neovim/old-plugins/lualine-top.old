-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
--
-- I think I grabbed the config from this plugin using Folke's lazyvim.org and
-- just made some changes on the top
-- http://www.lazyvim.org/plugins/ui#lualinenvim

-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
-- Description: Optimized Lualine configuration for Neovim.

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local colors = require("config.colors").load_colors()
    local icons = LazyVim.config.icons

    local fg_color = colors["linkarzu_color07"]

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

    local function should_show_permissions()
      if vim.bo.filetype ~= "sh" then
        return false
      end
      local file_path = vim.fn.expand("%:p")
      return file_path and file_path ~= ""
    end

    local function get_spell_bg_color()
      return vim.wo.spell and colors["linkarzu_color02"] or colors["linkarzu_color08"]
    end

    local function should_show_spell_status()
      return vim.bo.filetype == "markdown" and vim.wo.spell
    end

    local function get_spell_status()
      local lang_map = {
        en = "English",
        es = "Spanish",
      }
      local lang = vim.bo.spelllang
      lang = lang_map[lang] or lang
      return "Spell: " .. lang
    end

    local function has_additional_components()
      return should_show_permissions() or should_show_spell_status()
    end

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

    local function get_branch_color()
      local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
      if branch == "live" then
        return { fg = colors["linkarzu_color11"], gui = "bold" }
      else
        return nil
      end
    end

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
    }

    opts.sections.lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    }

    opts.sections.lualine_z = {}

    opts.sections.lualine_b = {
      {
        "branch",
        color = get_branch_color,
      },
    }

    table.insert(opts.sections.lualine_x, 1, {
      get_file_permissions,
      cond = should_show_permissions,
      color = function()
        local _, bg_color = get_file_permissions()
        return { fg = fg_color, bg = bg_color, gui = "bold" }
      end,
      separator = { left = "█", right = " " },
      padding = 0,
    })

    table.insert(opts.sections.lualine_x, 1, {
      get_spell_status,
      cond = should_show_spell_status,
      color = function()
        return { fg = fg_color, bg = get_spell_bg_color(), gui = "bold" }
      end,
      separator = { left = "█", right = " " },
      padding = 0,
    })

    local hostname_with_others = create_hostname_component("█ ", has_additional_components)
    local hostname_simple = create_hostname_component("", function()
      return not has_additional_components()
    end)

    table.insert(opts.sections.lualine_x, 1, hostname_with_others)
    table.insert(opts.sections.lualine_x, 1, hostname_simple)

    local function should_disable_lualine()
      local filetype = vim.bo.filetype
      local buftype = vim.bo.buftype
      return filetype == "neo-tree" or buftype == "terminal" or buftype == "nofile"
    end

    if should_disable_lualine() then
      opts.winbar = nil
      opts.tabline = nil
    else
      opts.winbar = {
        lualine_a = {},
        lualine_b = opts.sections.lualine_b,
        lualine_c = opts.sections.lualine_c,
        lualine_x = opts.sections.lualine_x,
        lualine_y = opts.sections.lualine_y,
        lualine_z = opts.sections.lualine_z,
      }

      opts.sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      }
    end

    opts.tabline = nil
  end,
}
