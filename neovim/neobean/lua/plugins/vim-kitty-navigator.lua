return {
  {
    "knubie/vim-kitty-navigator",
    build = "cp ./*.py ~/.config/kitty/",
    init = function()
      vim.g.kitty_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-h>", "<cmd>KittyNavigateLeft<cr>", mode = { "n", "v", "i" }, desc = "KittyNavigateLeft" },
      { "<C-j>", "<cmd>KittyNavigateDown<cr>", mode = { "n", "v", "i" }, desc = "KittyNavigateDown" },
      { "<C-k>", "<cmd>KittyNavigateUp<cr>", mode = { "n", "v", "i" }, desc = "KittyNavigateUp" },
      { "<C-l>", "<cmd>KittyNavigateRight<cr>", mode = { "n", "v", "i" }, desc = "KittyNavigateRight" },
    },
  },
}
