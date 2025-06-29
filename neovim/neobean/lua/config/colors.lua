-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua

-- load the colors once when the module is required and then expose the colors
-- directly. This avoids the need to call load_colors() in every file

-- Function to load colors from the external file
local function load_colors()
  local colors = {}
  
  -- Get the directory of this current file and look for active-colorscheme.sh relative to it
  local current_file = debug.getinfo(1, 'S').source:sub(2) -- Remove the '@' prefix
  local current_dir = current_file:match("(.*/)")
  local active_file = current_dir .. "active-colorscheme.sh"

  local file = io.open(active_file, "r")
  if not file then
    -- Fallback to original hardcoded path for existing setups
    active_file = os.getenv("HOME") .. "/github/dotfiles-latest/neovim/neobean/lua/config/active-colorscheme.sh"
    file = io.open(active_file, "r")
    if not file then
      error("Could not find active colorscheme file at:\n" .. 
            current_dir .. "active-colorscheme.sh\nor\n" .. active_file)
    end
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

-- Load colors when the module is required
local colors = load_colors()

-- Check if the 'vim' global exists (i.e., if running in Neovim)
if _G.vim then
  for name, hex in pairs(colors) do
    vim.api.nvim_set_hl(0, name, { fg = hex })
  end
end

-- Return the colors table for external usage (like wezterm)
return colors
