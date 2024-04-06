-- https://github.com/catppuccin/nvim

return {
  "catppuccin/nvim",
  lazy = true,
  name = "catppuccin",
  opts = {
    integrations = {
      -- Can disable the theme for neotree so its the same color as the right panel
      neotree = true,
    },
    custom_highlights = function(colors)
      return {

        -- Chages the color on a little line on the left side of the currently
        -- selected tab
        TabLineSel = { bg = "#32D1FD" },

        -- Change the text color of the currently selected buffer
        BufferLineBufferSelected = { fg = "#32D1FD" },

        -- nvim spectre highlight colors
        DiffChange = { bg = "#a6e3a1", fg = "black" },
        DiffDelete = { bg = "#f38ba8", fg = "black" },

        -- visual mode highlighted text color
        Visual = { bg = "#7ec9d8", fg = "white" },

        -- horizontal line that goes across where cursor is
        CursorLine = { bg = "#3f404f" },
        -- CursorLine = { bg = "#ff2800" },

        -- Color of repeated words
        illuminatedWordText = { bg = "#5886b0" },
        -- Default value
        -- illuminatedWordText = { bg = "#6a6b7a" },
        -- IlluminatedWordText = { bg = "#a6e3a1", fg = "#5c4696" },
        -- IlluminatedWordRead = { bg = "#a6e3a1", fg = "#5c4696" },
        -- IlluminatedWordWrite = { bg = "#a6e3a1", fg = "#5c4696" },
        -- IlluminatedWordText = { bg = "#f38ba8", fg = "#a6e3a1" },
        -- IlluminatedWordRead = { bg = "#f38ba8", fg = "#a6e3a1" },
        -- IlluminatedWordWrite = { bg = "#f38ba8", fg = "#a6e3a1" },

        -- -- I moved these colors to the lukas-reineke/headlines.nvim plugin
        -- -- Heading colors I use in my markdown files
        -- Headline1 = { bg = "#295715", fg = "white" },
        -- Headline2 = { bg = "#8d8200", fg = "white" },
        -- Headline3 = { bg = "#a56106", fg = "white" },
        -- Headline4 = { bg = "#7e0000", fg = "white" },
        -- Headline5 = { bg = "#1e0b7b", fg = "white" },
        -- darker codeblock for my markdown files
        -- CodeBlock = { bg = "#09090d" },

        -- I haven't tested all of the ones below, so test at your own will
        --     Search = { bg = "#569CD6", fg = "#1E1E1E" },
        --     IncSearch = { bg = "#C586C0", fg = "#1E1E1E" },
        --     MatchParen = { bg = "#FFD700", fg = "#000000" },
        --     Highlight = { bg = "#32CD32", fg = "#000000" },
        --     QuickFixLine = { bg = "#ADD8E6", fg = "#000000" },
        Comment = { fg = colors.flamingo },
        --     TabLineSel = { bg = colors.pink },
        --     CmpBorder = { fg = colors.surface2 },
        --     Pmenu = { bg = colors.none },
      }
    end,
  },
}
