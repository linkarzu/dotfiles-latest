-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/copilotchat.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/copilotchat.lua

-- https://github.com/CopilotC-Nvim/CopilotChat.nvim

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  enabled = vim.g.neovim_mode ~= "skitty", -- Disable for skitty mode
  opts = function(_, opts)
    -- Initialize options
    opts = opts or {}

    -- I set this global variable in options.lua file
    -- The copilotchat model is configured there, so if you need to change it go
    -- to that file
    opts.model = _G.COPILOT_MODEL

    -- Format username
    local user = (vim.env.USER or "User"):gsub("^%l", string.upper)
    opts.question_header = string.format(" %s (%s) ", user, opts.model)

    -- Configure mappings
    opts.mappings = {
      close = {
        normal = "<Esc>",
        insert = "<Esc>",
      },
      -- I hated this keymap with all my heart, when trying to navigate between
      -- neovim splits I reset the chat by mistake if I was in insert mode
      reset = {
        normal = "",
        insert = "",
      },
    }

    -- opts.prompts = {
    --   Lazy = {
    --     prompt = "Specify a custom prompt here",
    --   },
    -- }

    return opts
  end,
  keys = {
    {
      -- Toggle copilotchat, the default is <leader>aa
      "<M-o>",
      function()
        return require("CopilotChat").toggle()
      end,
      desc = "[P]Toggle (CopilotChat)",
      mode = { "n", "i", "v" },
    },
  },
}
