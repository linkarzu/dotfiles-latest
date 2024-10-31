-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua

local function load_colors()
  local colors = {}
  local home = os.getenv("HOME")
  local active_folder = home .. "/github/dotfiles-latest/colorscheme/active"
  local active_file = active_folder .. "/active-colorscheme.sh"

  -- Check if the active colorscheme file exists
  local file = io.open(active_file, "r")
  if not file then
    error("Could not open the active colorscheme file: " .. active_file)
  end

  -- Read and parse each line of the active colorscheme file
  for line in file:lines() do
    -- Skip comments and empty lines
    if not line:match("^%s*#") and not line:match("^%s*$") then
      local name, value = line:match("^(%S+)=%s*(.+)")
      if name and value then
        -- Remove surrounding quotes from the value
        colors[name] = value:gsub('"', "")
      end
    end
  end

  file:close()
  return colors
end

-- This return makes the load_colors function accessible from other files
return {
  load_colors = load_colors,
}
