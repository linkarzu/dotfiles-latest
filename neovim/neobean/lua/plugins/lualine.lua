-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
--
-- I think I grabbed the config from this plugin using Folke's lazyvim.org and
-- just made some changes on the top
-- http://www.lazyvim.org/plugins/ui#lualinenvim

-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/lualine.lua
-- Description: Optimized Lualine configuration for Neovim.

-- Other separator symbols:
-- █
--   
--   
--   
--   
--   

-- Require the colors.lua module and access the colors directly without
-- additional file reads
local colors = require("config.colors")
local icons = LazyVim.config.icons

-- Cache system
local cache = {
  branch = "",
  branch_color = nil,
  commit_hash = "",
  file_permissions = { perms = "", color = colors["linkarzu_color03"] },
}

-- Set up autocmds for cache updates
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
  callback = function()
    -- Update git branch
    cache.branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
    cache.branch_color = (cache.branch == "live") and { fg = colors["linkarzu_color11"], gui = "bold" } or nil
    -- Update commit hash only for dotfiles-latest repo
    local git_dir = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):gsub("\n", "")
    if git_dir ~= "" then
      local repo_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      if repo_root:match("dotfiles%-latest$") then
        cache.commit_hash = vim.fn.system("git rev-parse --short=7 HEAD"):gsub("\n", "")
      else
        cache.commit_hash = ""
      end
    else
      cache.commit_hash = ""
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  callback = function()
    if vim.bo.filetype ~= "sh" then
      cache.file_permissions = { perms = "", color = colors["linkarzu_color03"] }
      return
    end
    local file_path = vim.fn.expand("%:p")
    local permissions = file_path and vim.fn.getfperm(file_path) or "No File"
    local owner_permissions = permissions:sub(1, 3)
    cache.file_permissions = {
      perms = permissions,
      color = (owner_permissions == "rwx") and colors["linkarzu_color02"] or colors["linkarzu_color03"],
    }
  end,
})

-- -- Cached hostname and its background color
-- local hostname = vim.fn.hostname()
-- local last_char = hostname:sub(-1)
-- local hostname_bg_color = ({
--   ["1"] = colors["linkarzu_color02"],
--   ["2"] = colors["linkarzu_color08"],
--   ["3"] = colors["linkarzu_color06"],
-- })[last_char] or colors["linkarzu_color04"]

-- Cached language mappings
local lang_map = {
  en = "EN",
  es = "ES",
}

local function get_venv_name()
  local venv = os.getenv("VIRTUAL_ENV")
  return venv and venv:match("([^/]+)$") or ""
end

local function get_spell_bg_color()
  return vim.wo.spell and colors["linkarzu_color02"] or colors["linkarzu_color08"]
end

local function should_show_permissions()
  return vim.bo.filetype == "sh" and vim.fn.expand("%:p") ~= ""
end

local function should_show_spell_status()
  return vim.bo.filetype == "markdown" and vim.wo.spell
end

local function get_spell_status()
  return (lang_map[vim.bo.spelllang] or vim.bo.spelllang)
end

local function get_file_permissions()
  if vim.bo.filetype ~= "sh" then
    return "", colors["linkarzu_color03"]
  end
  local file_path = vim.fn.expand("%:p")
  local permissions = file_path and vim.fn.getfperm(file_path) or "No File"
  local owner_permissions = permissions:sub(1, 3)
  return permissions, (owner_permissions == "rwx") and colors["linkarzu_color02"] or colors["linkarzu_color03"]
end

-- local function has_additional_components()
--   return should_show_permissions() or should_show_spell_status()
-- end
--
-- local function create_hostname_component(condition)
--   return {
--     function()
--       return vim.fn.hostname()
--     end,
--     color = { fg = hostname_bg_color, bg = colors["linkarzu_color17"], gui = "bold" },
--     separator = { right = "" },
--     padding = 1,
--     cond = condition,
--   }
-- end

local function create_separator(condition)
  return {
    cond = condition,
    function()
      return ""
    end,
    color = { fg = colors["linkarzu_color14"], bg = colors["linkarzu_color17"] },
    separator = { left = "", right = "" },
    padding = 0,
  }
end

-- Define opts function and pass cached values
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  enabled = true,
  -- enabled = vim.g.neovim_mode ~= "skitty", -- Disable lualine for skitty mode
  opts = function(_, opts)
    if vim.g.neovim_mode == "skitty" then
      -- For skitty mode, only keep section_x and disable all others
      opts.sections = {
        lualine_a = {
          function()
            return "skitty-notes"
          end, -- Ensures it's displayed properly
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_y = {},
        lualine_z = {},
      }
    else
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
          function()
            -- Return branch name and commit hash if available
            return cache.branch .. (cache.commit_hash ~= "" and " " .. cache.commit_hash or "")
          end,
          color = function()
            -- Use the cached branch color directly
            return cache.branch_color
          end,
          separator = { right = "" },
        },
        -- {
        --   "branch",
        --   color = function()
        --     -- Use the cached branch color directly
        --     return cache.branch_color
        --   end,
        --   separator = { right = "" },
        -- },
        {
          get_venv_name,
          color = { fg = colors["linkarzu_color10"], bg = colors["linkarzu_color02"], gui = "bold" },
          separator = { right = "" },
        },
      }

      -- SPELLING left separator
      table.insert(opts.sections.lualine_x, 1, create_separator(should_show_spell_status))

      -- SPELLING component
      table.insert(opts.sections.lualine_x, 2, {
        get_spell_status, -- Display spell status text
        cond = should_show_spell_status,
        color = function()
          return { fg = get_spell_bg_color(), bg = colors["linkarzu_color17"], gui = "bold" }
        end,
        separator = { left = "", right = "" },
        padding = 1,
      })

      -- PERMISSIONS left separator
      table.insert(opts.sections.lualine_x, 3, create_separator(should_show_permissions))

      -- PERMISSIONS component
      table.insert(opts.sections.lualine_x, 4, {
        get_file_permissions, -- Display permissions text
        cond = should_show_permissions,
        color = function()
          local _, bg_color = get_file_permissions()
          return { fg = bg_color, bg = colors["linkarzu_color17"], gui = "bold" }
        end,
        separator = { left = "", right = "" },
        padding = 1,
      })

      -- HOSTNAME right separator
      table.insert(opts.sections.lualine_x, 5, create_separator()) -- For hostname, no condition needed

      -- -- HOSTNAME components
      -- local hostname_with_others = create_hostname_component(has_additional_components)
      -- local hostname_simple = create_hostname_component(function()
      --   return not has_additional_components()
      -- end)
      -- table.insert(opts.sections.lualine_x, 6, hostname_with_others)
      -- table.insert(opts.sections.lualine_x, 7, hostname_simple)

      -- -- HOSTNAME left separator
      -- table.insert(opts.sections.lualine_x, 8, {
      --   function()
      --     return ""
      --   end,
      --   color = { fg = colors["linkarzu_color14"], bg = colors["linkarzu_color17"] },
      --   separator = { left = "", right = "" },
      --   padding = 0,
      -- })

      -- The default value for this is:
      -- opts.extensions = { "neo-tree", "lazy", "fzf" }
      -- Removing neo-tree from here, makes lualine NOT change when I switch to
      -- neo-tree, and that's what I want, when in neo-tree I want to see the
      -- branch I'm on, otherwise the default behaviour shows you the :pwd
      opts.extensions = { "lazy", "fzf" }
    end
  end,
}
