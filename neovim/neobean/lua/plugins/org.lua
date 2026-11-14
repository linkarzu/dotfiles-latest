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
  config = function(_, opts)
    require("org").setup(opts)

    -- TEMPORARY fix for Lua :session blocks, remove when upstream fixes it:
    -- https://github.com/xheisenbugx/org.nvim/issues/348
    -- Each Lua block runs with its own print() that collects that block's
    -- output, and a function keeps the print() of the block it was written
    -- in. So say_hi() written in one block and called in a later block
    -- printed into the old block, and its "hi" never showed up.
    -- This gives every block one shared print() that sends the output to the
    -- block running now, or to Neovim's own print() outside of blocks
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "org",
      once = true,
      callback = function()
        local langs = require("org.babel.langs")
        local run_lua = langs.run_lua
        -- the print() of the block running now
        local current
        local shared = function(...)
          return (current or print)(...)
        end
        langs.run_lua = function(...)
          local load = _G.load
          -- run_lua loads the block with its env, that's where print() is
          _G.load = function(code, name, mode, env)
            local own = type(env) == "table" and rawget(env, "print")
            if own and own ~= shared then
              current = own
              rawset(env, "print", shared)
            end
            return load(code, name, mode, env)
          end
          local ok, res = pcall(run_lua, ...)
          _G.load, current = load, nil
          if not ok then
            error(res, 0)
          end
          return res
        end
      end,
    })
  end,
}
