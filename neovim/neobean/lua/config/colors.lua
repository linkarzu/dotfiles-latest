-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua

-- load the colors once when the module is required and then expose the colors
-- directly. This avoids the need to call load_colors() in every file

-- Create a table to hold the colors
local colors = {}

-- Function to load colors from the external file
local function load_colors()
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
end

-- Load colors when the module is required
load_colors()

-- Return the colors table directly
return colors
