return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      -- I swapped these 2
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
    opts = {
      filesystem = {
        -- Had to disable this option, because when I open neotree it was
        -- jumping around to random dirs when I opened a dir
        follow_current_file = { enabled = false },
      },
    },
  },
}
