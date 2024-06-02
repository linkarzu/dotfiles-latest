-- https://github.com/eldritch-theme/eldritch.nvim

return {
  "eldritch-theme/eldritch.nvim",
  lazy = true,
  name = "eldritch",
  opts = {
    -- This function is found in the documentation
    on_highlights = function(highlights)
      -- nvim-spectre highlight colors
      highlights.DiffChange = { bg = "#37f499", fg = "black" }
      highlights.DiffDelete = { bg = "#f265b5", fg = "black" }
      -- horizontal line that goes across where cursor is
      highlights.CursorLine = { bg = "#3f404f" }
      highlights.Comment = { fg = "#a5afc2" }
    end,
  },
}
