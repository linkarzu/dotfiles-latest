-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua

-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua
local M = {}

-- Add cache at module level
local colors_cache = nil

local function load_colors()
  -- Return cached results if available
  if colors_cache then
    return colors_cache
  end

  local colors = {}
  local home = os.getenv("HOME")
  local active_folder = home .. "/github/dotfiles-latest/colorscheme/active"
  local active_file = active_folder .. "/active-colorscheme.sh"

  local file = io.open(active_file, "r")
  if not file then
    error("Could not open the active colorscheme file: " .. active_file)
  end

  for line in file:lines() do
    if not line:match("^%s*#") and not line:match("^%s*$") then
      local name, value = line:match("^(%S+)=%s*(.+)")
      if name and value then
        colors[name] = value:gsub('"', "")
      end
    end
  end

  file:close()

  -- Cache the results
  colors_cache = colors
  return colors_cache
end

M.load_colors = load_colors
return M
