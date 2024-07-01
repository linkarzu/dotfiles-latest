-- Filename: /home/krishna/github/dotfiles-latest/nvim-lazyvim/lua/plugins/noice.lua
-- I want to change the default notifications to be less obtrussive (if that's even a word)
-- https://github.com/folke/noice.nvim

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      messages = {
        -- NOTE: If you enable messages, then the cmdline is enabled automatically.
        -- This is a current Neovim limitation.
        enabled = true, -- enables the Noice messages UI
        view = "mini", -- default view for messages
        view_error = "mini", -- view for errors
        view_warn = "mini", -- view for warnings
        view_history = "mini", -- view for :messages
        view_search = "mini", -- view for search count messages. Set to `false` to disable
      },
      notify = {
        -- Noice can be used as `vim.notify` so you can route any notification like other messages
        -- Notification messages have their level and other properties set.
        -- event is always "notify" and kind can be any log level as a string
        -- The default routes will forward notifications to nvim-notify
        -- Benefit of using Noice for this is the routing and consistent history view
        enabled = true,
        view = "mini",
      },
      lsp = {
        message = {
          -- Messages shown by lsp servers
          enabled = true,
          view = "mini",
        },
      },
      views = {
        mini = {
          timeout = 7000, -- timeout in milliseconds
          align = "center",
          position = {
            -- Centers messages top to bottom
            row = "95%",
            -- Aligns messages to the far right
            col = "100%",
          },
        },
      },
    },
  },
}
