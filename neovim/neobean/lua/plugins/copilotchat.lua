return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = function(_, opts)
    -- Get default opts if not provided
    opts = opts or {}

    -- Set the model
    local model = "claude-3.5-sonnet"
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
