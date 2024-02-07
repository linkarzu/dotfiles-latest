-- https://github.com/nvim-telescope/telescope.nvim
-- http://www.lazyvim.org/plugins/editor#telescopenvim-optional

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- I swapped ff and fF because I normally use ff
      -- fF is NOT working properly as it only finds sibling files of current file, but I don't care
      -- You can do <spacebar><spacebar> to find files in the root dir
      -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#find-sibling-files-of-current-file
      -- I figured I needed to use 'telescope.builtin' on the telescope github page
      {
        "<leader>fF",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Find Files (cwd)",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({})
        end,
        desc = "Find Files (root dir)",
      },
    },
  },
}
