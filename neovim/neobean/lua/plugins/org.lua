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
  },
}
