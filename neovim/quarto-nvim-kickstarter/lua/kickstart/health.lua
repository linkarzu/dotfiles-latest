-- adapted from <https://github.com/nvim-lua/kickstart.nvim/>
--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local check_version = function()
  if not vim.version.cmp then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", tostring(vim.version())))
    return
  end

  if vim.version.cmp(vim.version(), { 0, 9, 4 }) >= 0 then
    vim.health.ok(string.format("Neovim version is: '%s'", tostring(vim.version())))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", tostring(vim.version())))
  end
end

local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

local check_image_dependencies = function()
  local backend = 'kitty'

  local shell
  if vim.fn.has 'nvim-0.10.0' == 1 then
    shell = function(command)
      local obj = vim.system(command, { text = true }):wait()
      if obj.code ~= 0 then
        return nil
      end
      return obj.stdout
    end
  else
    vim.health.warn 'nvim < 0.10'
    shell = function(command)
      command = table.concat(command, ' ')
      local handle = io.popen(command)
      if handle == nil then
        return nil
      end
      local result = handle:read '*a'
      handle:close()
      return result
    end
  end

  -- check if imagemagick is available
  if shell { 'convert', '-version' } == nil then
    vim.health.warn 'imagemagick is not available'
    return
  end

  if backend == 'kitty' then
    -- check if kitty is available
    local out = shell { 'kitty', '--version' }
    if out == nil then
      vim.health.warn 'kitty is not available'
      return
    end
    local kitty_version = out:match '(%d+%.%d+%.%d+)'
    if kitty_version == nil then
      vim.health.warn 'kitty version is not available'
      return
    end
    local v = vim.version.parse(kitty_version)
    local minimal = vim.version.parse '0.30.1'
    if v and vim.version.cmp(v, minimal) < 0 then
      vim.health.warn 'kitty version is too old'
      return
    end
  end
  local tmux = vim.fn.getenv 'TMUX'
  if tmux ~= vim.NIL then
    -- tmux uses number.number.(maybe letter)
    -- e.g. 3.3a
    -- but 3.3 comes before 3.3a
    -- so we replace a with 1
    local offset = 96
    local out = shell { 'tmux', '-V' }
    if out == nil then
      vim.health.warn 'tmux is not available'
      return
    end
    out = out:gsub('\n', '')
    local letter = out:match 'tmux %d+%.%d+([a-z])'
    local number
    if letter == nil then
      number = 0
    else
      number = string.byte(letter) - offset
    end
    local version = out:gsub('tmux (%d+%.%d+)([a-z])', '%1.' .. number)
    local v = vim.version.parse(version)
    local minimal = vim.version.parse '3.3.1'
    if v and vim.version.cmp(v, minimal) < 0 then
      vim.health.warn 'tmux version is too old'
      return
    end
  end

  -- check if magick luarock is available
  local ok, magick = pcall(require, 'magick')
  if not ok then
    vim.health.warn 'magick luarock is not available'
    return
  end

  vim.health.ok 'image.nvim dependencies are available'
  return true
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_image_dependencies()
  end,
}
