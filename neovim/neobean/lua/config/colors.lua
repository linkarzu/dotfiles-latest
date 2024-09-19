-- ~/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua

local function load_colors()
  local colors = {}
  local home = os.getenv("HOME")
  local active_folder = home .. "/github/dotfiles-latest/colorscheme/active"

  -- Open the active folder and get the first file
  local file_name
  for file in io.popen('ls "' .. active_folder .. '"'):lines() do
    file_name = file
    break
  end

  if not file_name then
    error("No colors file found in " .. active_folder)
  end

  local file_path = active_folder .. "/" .. file_name
  local file = io.open(file_path, "r")
  if not file then
    error("Could not open the colors file: " .. file_path)
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
