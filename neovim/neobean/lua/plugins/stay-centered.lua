-- https://github.com/arnamak/stay-centered.nvim
return {
  {
    "arnamak/stay-centered.nvim",
    opts = function()
      require("stay-centered").setup({
        -- Add any configurations here, like skip_filetypes if needed
        -- skip_filetypes = {"lua", "typescript"},
      })
    end,
  },
}
