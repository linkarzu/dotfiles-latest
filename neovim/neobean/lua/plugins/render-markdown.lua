-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/render-markdown.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/render-markdown.lua

-- https://github.com/MeanderingProgrammer/markdown.nvim
--
-- When I hover over markdown headings, this plugins goes away, so I need to
-- edit the default highlights
-- I tried adding this as an autocommand, in the options.lua
-- file, also in the markdownl.lua file, but the highlights kept being overriden
-- so the inly way is the only way I was able to make it work was loading it
-- after the config.lazy in the init.lua file lamw25wmal

-- Require the colors.lua module and access the colors directly without
-- additional file reads
local colors = require("config.colors")

return {
  "MeanderingProgrammer/render-markdown.nvim",
  enabled = true,
  -- Moved highlight creation out of opts as suggested by plugin maintainer
  -- There was no issue, but it was creating unnecessary noise when ran
  -- :checkhealth render-markdown
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/138#issuecomment-2295422741
  init = function()
    -- Define color variables
    local color1_bg = colors["linkarzu_color18"]
    local color2_bg = colors["linkarzu_color19"]
    local color3_bg = colors["linkarzu_color20"]
    local color4_bg = colors["linkarzu_color21"]
    local color5_bg = colors["linkarzu_color22"]
    local color6_bg = colors["linkarzu_color23"]
    local color_fg = colors["linkarzu_color26"]
    -- local color_sign = "#ebfafa"

    -- Heading colors (when not hovered over), extends through the entire line
    vim.cmd(string.format([[highlight Headline1Bg guifg=%s guibg=%s]], color_fg, color1_bg))
    vim.cmd(string.format([[highlight Headline2Bg guifg=%s guibg=%s]], color_fg, color2_bg))
    vim.cmd(string.format([[highlight Headline3Bg guifg=%s guibg=%s]], color_fg, color3_bg))
    vim.cmd(string.format([[highlight Headline4Bg guifg=%s guibg=%s]], color_fg, color4_bg))
    vim.cmd(string.format([[highlight Headline5Bg guifg=%s guibg=%s]], color_fg, color5_bg))
    vim.cmd(string.format([[highlight Headline6Bg guifg=%s guibg=%s]], color_fg, color6_bg))

    -- Highlight for the heading and sign icons (symbol on the left)
    -- I have the sign disabled for now, so this makes no effect
    vim.cmd(string.format([[highlight Headline1Fg cterm=bold gui=bold guifg=%s]], color1_bg))
    vim.cmd(string.format([[highlight Headline2Fg cterm=bold gui=bold guifg=%s]], color2_bg))
    vim.cmd(string.format([[highlight Headline3Fg cterm=bold gui=bold guifg=%s]], color3_bg))
    vim.cmd(string.format([[highlight Headline4Fg cterm=bold gui=bold guifg=%s]], color4_bg))
    vim.cmd(string.format([[highlight Headline5Fg cterm=bold gui=bold guifg=%s]], color5_bg))
    vim.cmd(string.format([[highlight Headline6Fg cterm=bold gui=bold guifg=%s]], color6_bg))
  end,
  opts = {
    bullet = {
      -- Turn on / off list bullet rendering
      enabled = true,
    },
    checkbox = {
      -- Turn on / off checkbox state rendering
      enabled = true,
      -- Determines how icons fill the available space:
      --  inline:  underlying text is concealed resulting in a left aligned icon
      --  overlay: result is left padded with spaces to hide any additional text
      position = "inline",
      unchecked = {
        -- Replaces '[ ]' of 'task_list_marker_unchecked'
        icon = "   󰄱 ",
        -- Highlight for the unchecked icon
        highlight = "RenderMarkdownUnchecked",
        -- Highlight for item associated with unchecked checkbox
        scope_highlight = nil,
      },
      checked = {
        -- Replaces '[x]' of 'task_list_marker_checked'
        icon = "   󰱒 ",
        -- Highlight for the checked icon
        highlight = "RenderMarkdownChecked",
        -- Highlight for item associated with checked checkbox
        scope_highlight = nil,
      },
    },
    html = {
      -- Turn on / off all HTML rendering
      enabled = true,
      comment = {
        -- Turn on / off HTML comment concealing
        conceal = false,
      },
    },
    heading = {
      sign = false,
      icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      backgrounds = {
        "Headline1Bg",
        "Headline2Bg",
        "Headline3Bg",
        "Headline4Bg",
        "Headline5Bg",
        "Headline6Bg",
      },
      foregrounds = {
        "Headline1Fg",
        "Headline2Fg",
        "Headline3Fg",
        "Headline4Fg",
        "Headline5Fg",
        "Headline6Fg",
      },
    },
  },
}
