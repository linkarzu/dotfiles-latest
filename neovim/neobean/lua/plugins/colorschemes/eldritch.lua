-- https://github.com/eldritch-theme/eldritch.nvim
--
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/colorschemes/eldritch.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/colorschemes/eldritch.lua

local colors_from_file = require("config.colors").load_colors()

return {
  "eldritch-theme/eldritch.nvim",
  lazy = true,
  name = "eldritch",
  opts = {
    -- This function is found in the documentation
    on_highlights = function(highlights)
      -- nvim-spectre highlight colors
      highlights.DiffChange = { bg = colors_from_file["linkarzu_color02"], fg = "black" }
      highlights.DiffDelete = { bg = colors_from_file["linkarzu_color01"], fg = "black" }

      -- horizontal line that goes across where cursor is
      highlights.CursorLine = { bg = colors_from_file["linkarzu_color13"] }

      -- highlights.Comment = { fg = colors_from_file["linkarzu_color09"], italic = true }

      -- I do the line below to change the color of bold text
      highlights["@markup.strong"] = { fg = colors_from_file["linkarzu_color04"], bold = true }

      -- Change the spell underline color
      highlights.SpellBad = { sp = colors_from_file["linkarzu_color11"], undercurl = true, bold = true, italic = true }
      highlights.SpellCap = { sp = colors_from_file["linkarzu_color12"], undercurl = true, bold = true, italic = true }
      highlights.SpellLocal =
        { sp = colors_from_file["linkarzu_color12"], undercurl = true, bold = true, italic = true }
      highlights.SpellRare = { sp = colors_from_file["linkarzu_color04"], undercurl = true, bold = true, italic = true }

      highlights.MiniDiffSignAdd = { fg = colors_from_file["linkarzu_color05"], bold = true }
      highlights.MiniDiffSignChange = { fg = colors_from_file["linkarzu_color02"], bold = true }

      -- Codeblocks for the render-markdown plugin
      highlights.RenderMarkdownCode = { bg = colors_from_file["linkarzu_color07"] }

      -- This is the plugin that shows you where you are at the top
      highlights.TreesitterContext = { sp = colors_from_file["linkarzu_color10"] }
      highlights.MiniFilesNormal = { sp = colors_from_file["linkarzu_color10"] }
      highlights.MiniFilesBorder = { sp = colors_from_file["linkarzu_color10"] }
      highlights.MiniFilesTitle = { sp = colors_from_file["linkarzu_color10"] }
      highlights.MiniFilesTitleFocused = { sp = colors_from_file["linkarzu_color10"] }

      highlights.NormalFloat = { bg = colors_from_file["linkarzu_color10"] }
      highlights.FloatBorder = { bg = colors_from_file["linkarzu_color10"] }
      highlights.FloatTitle = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NotifyBackground = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NeoTreeNormalNC = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NeoTreeNormal = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NvimTreeWinSeparator =
        { fg = colors_from_file["linkarzu_color10"], bg = colors_from_file["linkarzu_color10"] }
      highlights.NvimTreeNormalNC = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NvimTreeNormal = { bg = colors_from_file["linkarzu_color10"] }
      highlights.TroubleNormal = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorder = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitle = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorderFilter = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIconFilter = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitleFilter = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIcon = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIconCmdline = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorderCmdline = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitleCmdline = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIconSearch = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorderSearch = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitleSearch = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIconLua = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorderLua = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitleLua = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIconHelp = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorderHelp = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitleHelp = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIconInput = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorderInput = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitleInput = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlineIconCalculator = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupBorderCalculator = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCmdlinePopupTitleCalculator = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceCompletionItemKindDefault = { bg = colors_from_file["linkarzu_color10"] }
      highlights.NoiceMini = { bg = colors_from_file["linkarzu_color10"] }
      highlights.StatusLine = { bg = colors_from_file["linkarzu_color10"] }
      highlights.Folded = { bg = colors_from_file["linkarzu_color10"] }

      highlights.DiagnosticInfo = { fg = colors_from_file["linkarzu_color03"] }
      highlights.DiagnosticHint = { fg = colors_from_file["linkarzu_color02"] }
      highlights.DiagnosticWarn = { fg = colors_from_file["linkarzu_color08"] }
      highlights.DiagnosticOk = { fg = colors_from_file["linkarzu_color04"] }
      highlights.DiagnosticError = { fg = colors_from_file["linkarzu_color05"] }
      highlights.RenderMarkdownQuote = { fg = colors_from_file["linkarzu_color12"] }
    end,
    -- Overriding colors globally
    on_colors = function(global_colors)
      global_colors.bg = colors_from_file["linkarzu_color10"]
      global_colors.comment = colors_from_file["linkarzu_color09"]
      global_colors.yellow = colors_from_file["linkarzu_color05"] -- default #f1fc79
      global_colors.pink = colors_from_file["linkarzu_color01"] -- default #f265b5
      global_colors.red = colors_from_file["linkarzu_color08"] -- default #f16c75
      global_colors.orange = colors_from_file["linkarzu_color06"] -- default #f7c67f
      global_colors.purple = colors_from_file["linkarzu_color04"] -- default #a48cf2
    end,
  },
}
