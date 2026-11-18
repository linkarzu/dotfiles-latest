-- https://github.com/xheisenbugx/org.nvim
--
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/org.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/org.lua
--
-- Emacs Org mode rebuilt for Neovim in pure Lua (outlines, TODOs, agenda,
-- capture, clocking, tables, babel, export)
-- Run `:checkhealth org` after installing, and press `g?` in an org buffer
-- to see the available keymaps

return {
  "xheisenbugx/org.nvim",
  main = "org",
  -- startup cost is small, heavy modules load on first use
  lazy = false,
  opts = {
    org_directory = "~/github/org-notes",
    agenda_files = { "~/github/org-notes/**/*.org" },
    default_notes_file = "~/github/org-notes/refile.org",
    babel = {
      -- <C-c><C-c> asks "Evaluate this lua code block on your system?"
      -- before every block. My Lua lesson files are mine and I run dozens of
      -- blocks on stream, so those run without asking; every other org file
      -- still asks
      confirm_evaluate = function()
        local lessons = vim.fn.expand("~/github/notes/010-newNotes/lua-lessons/")
        return not vim.startswith(vim.api.nvim_buf_get_name(0), lessons)
      end,
    },
  },
}
