-- https://github.com/catppuccin/nvim

return {
  "catppuccin/nvim",
  lazy = true,
  name = "catppuccin",
  opts = {
    integrations = {
      aerial = true,
      alpha = true,
      cmp = true,
      dashboard = true,
      flash = true,
      gitsigns = true,
      headlines = true,
      illuminate = true,
      indent_blankline = { enabled = true },
      leap = true,
      lsp_trouble = true,
      mason = true,
      markdown = true,
      mini = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      navic = { enabled = true, custom_bg = "lualine" },
      neotest = true,
      -- Can disable the theme for neotree so its the same color as the right panel
      neotree = true,
      noice = true,
      notify = true,
      semantic_tokens = true,
      telescope = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
    },
    -- custom_highlights = function(colors)
    --   return {
    --     CursorLine = { bg = "#24283b" },
    --     Visual = { bg = "#ff2800" },
    --     Search = { bg = "#569CD6", fg = "#1E1E1E" }, -- Adjusts the search highlight color
    --     IncSearch = { bg = "#C586C0", fg = "#1E1E1E" }, -- Adjusts the incremental search / replacement preview color
    --     MatchParen = { bg = "#FFD700", fg = "#000000" }, -- Example customization
    --     Highlight = { bg = "#32CD32", fg = "#000000" }, -- Hypothetical usage
    --     QuickFixLine = { bg = "#ADD8E6", fg = "#000000" }, -- For quickfix line highlight
    --     SpectreHeaderxxx = { fg = "#FF79C6", bg = "#282A36" }, -- Pink foreground on a dark background
    --     SpectreBodyxxx = { fg = "#8BE9FD", bg = "#44475A" }, -- Cyan foreground on a medium-dark background
    --     SpectreFilexxx = { fg = "#50FA7B", bg = "#6272A4" }, -- Green foreground on a medium background
    --     SpectreDirxxx = { fg = "#FFB86C", bg = "#373844" }, -- Orange foreground on a slightly lighter dark background
    --     SpectreSearchxxx = { fg = "#BD93F9", bg = "#21222C" }, -- Purple foreground on a dark background
    --     SpectreBorderxxx = { fg = "#F1FA8C", bg = "#282A36" }, -- Yellow foreground on a dark background
    --     SpectreReplacexxx = { fg = "#FF5555", bg = "#44475A" }, -- Red foreground on a medium-dark background
    --     SpectreReplacexxxxxx = { fg = "#FF5555", bg = "#44475A" }, -- Red foreground on a medium-dark background
    --
    --     Comment = { fg = colors.flamingo },
    --     TabLineSel = { bg = colors.pink },
    --     CmpBorder = { fg = colors.surface2 },
    --     Pmenu = { bg = colors.none },
    --   }
    -- end,
  },
}
