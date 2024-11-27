-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snacks.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snacks.lua

-- Folke pointed me to the snacks docs
-- https://github.com/LazyVim/LazyVim/discussions/4251#discussioncomment-11198069
-- Here's the lazygit snak docs
-- https://github.com/folke/snacks.nvim/blob/main/docs/lazygit.md

return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        theme = {
          selectedLineBgColor = { bg = "CursorLine" },
        },
      },
      notifier = {
        enabled = true,
        top_down = false, -- place notifications from top to bottom
      },
      dashboard = {
        preset = {
          keys = {
            -- { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            -- { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            -- {
            --   icon = " ",
            --   key = "c",
            --   desc = "Config",
            --   action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            -- },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            -- { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "<esc>", desc = "Quit", action = ":qa" },
          },
          header = [[
███╗   ██╗███████╗ ██████╗ ██████╗ ███████╗ █████╗ ███╗   ██╗
████╗  ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝██╔══██╗████╗  ██║
██╔██╗ ██║█████╗  ██║   ██║██████╔╝█████╗  ███████║██╔██╗ ██║
██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██╔══╝  ██╔══██║██║╚██╗██║
██║ ╚████║███████╗╚██████╔╝██████╔╝███████╗██║  ██║██║ ╚████║
╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝

[Linkarzu.com]
        ]],
        },
      },
    },
  },
}
