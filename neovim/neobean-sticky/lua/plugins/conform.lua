-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
--
-- https://github.com/stevearc/conform.nvim

return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      -- I was having issues formatting .templ files, all the lines were aligned
      -- to the left.
      -- When I ran :ConformInfo I noticed that 2 formatters showed up:
      -- "LSP: html, templ"
      -- But none showed as `ready` This fixed that issue and now templ files
      -- are formatted correctly and :ConformInfo shows:
      -- "LSP: html, templ"
      -- "templ ready (templ) /Users/linkarzu/.local/share/neobean/mason/bin/templ"
      templ = { "templ" },
      -- php = { nil },
    },
  },
}
