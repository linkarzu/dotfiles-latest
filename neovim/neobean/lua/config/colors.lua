-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua

local function load_colors()
  local colors = {}
  local home = os.getenv("HOME")
  local file = io.open(home .. "/github/dotfiles-latest/colorscheme/active/colors.sh", "r")

  if not file then
    error("Could not open colors.sh")
  end

  for line in file:lines() do
    local name, value = line:match("^(%S+)=%s*(.+)")
    if name and value then
      colors[name] = value:gsub('"', "") -- Remove quotes
    end
  end

  file:close()
  return colors
end

return {
  load_colors = load_colors,
}
