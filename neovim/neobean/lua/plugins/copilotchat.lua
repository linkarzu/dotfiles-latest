-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/copilotchat.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/copilotchat.lua

-- https://github.com/CopilotC-Nvim/CopilotChat.nvim

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = function(_, opts)
    -- Cache system values
    local cached_model = nil
    local cached_computer_model = nil

    ---Get the computer model (cached)
    ---@return string|nil
    local function get_computer_model()
      if cached_computer_model then
        return cached_computer_model
      end

      local ok, handle = pcall(io.popen, "sysctl -n hw.model")
      if not ok or not handle then
        return nil
      end

      local result = handle:read("*a")
      handle:close()

      if result then
        cached_computer_model = result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
        return cached_computer_model
      end
      return nil
    end

    -- Initialize options
    opts = opts or {}

    -- Determine model based on computer type (cached)
    local function get_model()
      if cached_model then
        return cached_model
      end

      local computer_model = get_computer_model()
      cached_model = computer_model == "MacBookPro18,2" and "gpt-4o" or "claude-3.5-sonnet"
      return cached_model
    end

    -- Set model and format username
    opts.model = get_model()
    local user = (vim.env.USER or "User"):gsub("^%l", string.upper)
    opts.question_header = string.format("  %s (%s) ", user, opts.model)

    -- Configure mappings
    opts.mappings = {
      close = {
        normal = "<Esc>",
        insert = "<Esc>",
      },
    }

    return opts
  end,
}
