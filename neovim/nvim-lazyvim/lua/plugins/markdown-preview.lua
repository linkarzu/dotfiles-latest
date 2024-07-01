-- Filename: ~/github/dotfiles-latest/neovim/nvim-lazyvim/lua/plugins/markdown-preview.lua
-- ~/github/dotfiles-latest/neovim/nvim-lazyvim/lua/plugins/markdown-preview.lua
--
-- Link to github repo
-- https://github.com/iamcco/markdown-preview.nvim

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    {
      "<leader>mp",
      ft = "markdown",
      "<cmd>MarkdownPreviewToggle<cr>",
      desc = "Markdown Preview",
    },
  },
}
