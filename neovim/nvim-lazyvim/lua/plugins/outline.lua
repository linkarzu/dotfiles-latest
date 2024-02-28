-- https://github.com/hedyhli/outline.nvim
--
-- There are also some related plugins like `aerial.nvim` found below
-- https://github.com/hedyhli/outline.nvim?tab=readme-ov-file#related-plugins
--
return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = { -- Example mapping to toggle outline
    { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  opts = {
    symbol_folding = {
      -- Unfold entire symbol tree by default
      autofold_depth = false,
    },
  },
}
