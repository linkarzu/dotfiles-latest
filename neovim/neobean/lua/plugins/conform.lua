-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
--
-- https://github.com/stevearc/conform.nvim

-- Auto-format when focus is lost or I leave the buffer
-- Useful if on skitty-notes or a regular buffer and switch somewhere else the
-- formatting doesn't stay all messed up
-- I found this autocmd example in the readme
-- https://github.com/stevearc/conform.nvim/blob/master/README.md#setup
-- "FocusLost" used when switching from skitty-notes
-- "BufLeave" is used when switching between 2 buffers
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  callback = function(args)
    local buf = args.buf or vim.api.nvim_get_current_buf()
    -- Only format if the current mode is normal mode
    -- Only format if autoformat is enabled for the current buffer (if
    -- autoformat disabled globally the buffers inherits it, see :LazyFormatInfo)
    if LazyVim.format.enabled(buf) and vim.fn.mode() == "n" then
      -- Add a small delay to the formatting so it doesn’t interfere with
      -- CopilotChat’s or grug-far buffer initialization, this helps me to not
      -- get errors when using the "BufLeave" event above, if not using
      -- "BufLeave" the delay is not needed
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
          require("conform").format({ bufnr = buf })
        end
      end, 100)
    end
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
