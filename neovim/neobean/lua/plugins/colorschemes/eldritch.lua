-- https://github.com/eldritch-theme/eldritch.nvim
--
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/colorschemes/eldritch.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/colorschemes/eldritch.lua

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
      -- highlights.CursorLine = { bg = "#3f404f" }
      highlights.CursorLine = { bg = "#000000" }

      -- highlights.Comment = { fg = "#a5afc2", italic = true }

      -- I do the line below to change the color of bold text
      highlights["@markup.strong"] = { fg = "#f265b5", bold = true }

      -- Change the spell underline color
      --
      -- Every time you change an undercurl setting here, make sure to kill the tmux
      -- session or you won't see the changes
      --
      -- For this to work in kitty, you need to add some configs to your
      -- tmux.conf file, go to that file and look for "Undercurl support"
      --
      -- You could also set these to bold or italic if you wanted, example:
      -- highlights.SpellBad = { sp = "#37f499", undercurl = true, bold = true, italic = true }
      --
      highlights.SpellBad = { sp = "#f16c75", undercurl = true, bold = true, italic = true }
      highlights.SpellCap = { sp = "#f1fc79", undercurl = true, bold = true, italic = true }
      highlights.SpellLocal = { sp = "#ebfafa", undercurl = true, bold = true, italic = true }
      highlights.SpellRare = { sp = "#a48cf2", undercurl = true, bold = true, italic = true }

      -- highlights.SpellBad = { sp = "#f16c75", undercurl = true }
      -- highlights.SpellCap = { sp = "#f16c75", undercurl = true }
      -- highlights.SpellLocal = { sp = "#f16c75", undercurl = true }
      -- highlights.SpellRare = { sp = "#f16c75", undercurl = true }

      -- My headings are this color, so this is not a good idea
      -- highlights.SpellBad = { sp = "#f16c75", undercurl = true, fg = "#37f499" }
      -- highlights.SpellCap = { sp = "#f16c75", undercurl = true, fg = "#37f499" }
      -- highlights.SpellLocal = { sp = "#f16c75", undercurl = true, fg = "#37f499" }
      -- highlights.SpellRare = { sp = "#f16c75", undercurl = true, fg = "#37f499" }

      -- These colors are used by mini-files.lua to show git changes
      highlights.MiniDiffSignAdd = { fg = "#f1fc79", bold = true }
      highlights.MiniDiffSignChange = { fg = "#37f499", bold = true }

      -- highlights.Normal = { bg = "#09090d", fg = "#ebfafa" }

      -- Code blocks for the render-markdown plugin
      highlights.RenderMarkdownCode = { bg = "#1c242f" }

      -------------------------------------------------------------------------
      --       Comment this entire section to use the default #212337        --
      -------------------------------------------------------------------------

      -- This is the plugin that shows you where you are at the top
      highlights.TreesitterContext = { sp = "#0D1116" }
      highlights.MiniFilesNormal = { sp = "#0D1116" }
      highlights.MiniFilesBorder = { sp = "#0D1116" }
      highlights.MiniFilesTitle = { sp = "#0D1116" }
      highlights.MiniFilesTitleFocused = { sp = "#0D1116" }

      highlights.NormalFloat = { bg = "#0D1116" }
      highlights.FloatBorder = { bg = "#0D1116" }
      highlights.FloatTitle = { bg = "#0D1116" }
      highlights.NotifyBackground = { bg = "#0D1116" }
      highlights.NeoTreeNormalNC = { bg = "#0D1116" }
      highlights.NeoTreeNormal = { bg = "#0D1116" }
      highlights.NvimTreeWinSeparator = { fg = "#0D1116", bg = "#0D1116" }
      highlights.NvimTreeNormalNC = { bg = "#0D1116" }
      highlights.NvimTreeNormal = { bg = "#0D1116" }
      highlights.TroubleNormal = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorder = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitle = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorderFilter = { bg = "#0D1116" }
      highlights.NoiceCmdlineIconFilter = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitleFilter = { bg = "#0D1116" }
      highlights.NoiceCmdlineIcon = { bg = "#0D1116" }
      highlights.NoiceCmdlineIconCmdline = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorderCmdline = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitleCmdline = { bg = "#0D1116" }
      highlights.NoiceCmdlineIconSearch = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorderSearch = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitleSearch = { bg = "#0D1116" }
      highlights.NoiceCmdlineIconLua = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorderLua = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitleLua = { bg = "#0D1116" }
      highlights.NoiceCmdlineIconHelp = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorderHelp = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitleHelp = { bg = "#0D1116" }
      highlights.NoiceCmdlineIconInput = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorderInput = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitleInput = { bg = "#0D1116" }
      highlights.NoiceCmdlineIconCalculator = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupBorderCalculator = { bg = "#0D1116" }
      highlights.NoiceCmdlinePopupTitleCalculator = { bg = "#0D1116" }
      highlights.NoiceCompletionItemKindDefault = { bg = "#0D1116" }
      -- this is the noice popup menu
      highlights.NoiceMini = { bg = "#0D1116" }
      -- This sets the color of the winbar at the top
      highlights.StatusLine = { bg = "#0D1116" }
      -------------------------------------------------------------------------
    end,
    -- Overriding colors globally
    -- These colors can be found in the palette.lua file
    -- https://github.com/eldritch-theme/eldritch.nvim/blob/master/lua/eldritch/palette.lua
    on_colors = function(colors)
      -- This is in case you want to change the background color (where you type
      -- text in neovim)
      colors.bg = "#0D1116"
      colors.comment = "#a5afc2"
    end,
  },
}
