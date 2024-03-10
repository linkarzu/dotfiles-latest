-- https://github.com/nvim-treesitter/nvim-treesitter
-- SQL wasn't sohwing in my codeblocks when working with .md files, that's
-- how I found out it was missing from treesitter

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "sql",
        "go",
      },
    },
  },
}
