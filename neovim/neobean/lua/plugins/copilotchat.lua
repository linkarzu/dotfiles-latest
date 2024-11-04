return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = function(_, opts)
    -- Get default opts if not provided
    opts = opts or {}

    -- Function to get the computer model
    local function get_computer_model()
      local handle = io.popen("sysctl -n hw.model")
      if handle then
        local result = handle:read("*a")
        handle:close()
        if result then
          return result:match("^%s*(.-)%s*$") -- Trim any whitespace
        end
      end
      return nil
    end

    -- Get the computer model
    local computer_model = get_computer_model()

    -- Set the model based on the computer model
    local model
    if computer_model == "MacBookPro18,2" then
      model = "gpt-4o"
    else
      model = "claude-3.5-sonnet"
    end
    opts.model = model

    -- Get username with first letter capitalized
    local user = vim.env.USER or "User"
    user = user:sub(1, 1):upper() .. user:sub(2)

    -- Modify question header to include model
    opts.question_header = string.format("  %s (%s) ", user, model)

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
