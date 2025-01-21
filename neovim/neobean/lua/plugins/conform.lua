-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
--
-- https://github.com/stevearc/conform.nvim

-- Auto-format when focus is lost or I leave the buffer
-- Useful if on skitty-notes or a regular buffer and I am on a
-- I found this autocmd example in the readme
-- https://github.com/stevearc/conform.nvim/blob/master/README.md#setup
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "QuitPre", "VimSuspend" }, {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

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
