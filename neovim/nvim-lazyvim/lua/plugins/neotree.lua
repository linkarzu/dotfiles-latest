return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      -- I swapped these 2
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
    },
  },
}
