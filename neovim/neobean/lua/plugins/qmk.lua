-- https://github.com/codethread/qmk.nvim

return {
  "codethread/qmk.nvim",
  ft = "keymap",
  enabled = true,
  event = "VeryLazy",
  -- Commentikng the default layout, moving this config to the autocmds file to
  -- have multiple keyboards configured
  -- ~/github/dotfiles-latest/neovim/neobean/lua/config/autocmds.lua
  -- opts = {
  --   name = "LAYOUT_glove80",
  --   variant = "zmk",
  --   layout = {
  --     "x x x x x _ _ _ _ _ _ _ _ _ x x x x x",
  --     "x x x x x x _ _ _ _ _ _ _ x x x x x x",
  --     "x x x x x x _ _ _ _ _ _ _ x x x x x x",
  --     "x x x x x x _ _ _ _ _ _ _ x x x x x x",
  --     "x x x x x x x x x _ x x x x x x x x x",
  --     "x x x x x _ x x x _ x x x _ x x x x x",
  --   },
  -- },
}
