-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua

-- Keep one shared table so modules that capture it see updates after a live
-- colorscheme reload.

-- Function to load colors from the external file
local function load_colors()
  local colors = {}
  -- Get directory of this file
  local script_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
  local local_file = script_dir .. "active-colorscheme.sh"
  local fallback_file = os.getenv("HOME") .. "/github/dotfiles-latest/neovim/neobean/lua/config/active-colorscheme.sh"

  -- Pick first available file
  local active_file = vim.fn.filereadable(local_file) == 1 and local_file or fallback_file

  local file = io.open(active_file, "r")
  if not file then
    error("Could not open the active colorscheme file: " .. active_file)
  end

  for line in file:lines() do
    if not line:match("^%s*#") and not line:match("^%s*$") and not line:match("^wallpaper=") then
      local name, value = line:match("^(%S+)=%s*(.+)")
      if name and value then
        colors[name] = value:gsub('"', "")
      end
    end
  end

  file:close()
  return colors
end

local colors = rawget(_G, "linkarzu_colors") or {}
_G.linkarzu_colors = colors

local function apply_color_highlights()
  for name, hex in pairs(colors) do
    if type(hex) == "string" then
      vim.api.nvim_set_hl(0, name, { fg = hex })
    end
  end
end

local function refresh_colors()
  local loaded_colors = load_colors()

  for name, value in pairs(colors) do
    if type(value) ~= "function" then
      colors[name] = nil
    end
  end
  for name, hex in pairs(loaded_colors) do
    colors[name] = hex
  end

  apply_color_highlights()
end

refresh_colors()

function colors.reload()
  refresh_colors()

  local colorscheme = vim.g.colors_name
  if colorscheme and colorscheme ~= "" then
    vim.cmd.colorscheme(colorscheme)
  end

  apply_color_highlights()
  package.loaded["config.highlights"] = nil
  require("config.highlights")

  local has_lazy, lazy_loader = pcall(require, "lazy.core.loader")
  if has_lazy then
    lazy_loader.reload("lualine.nvim")
  end
  vim.cmd("redraw!")

  return "verified"
end

-- Return the colors table for external usage (like wezterm)
return colors
