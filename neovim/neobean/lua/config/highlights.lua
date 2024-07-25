-- Custom highlight settings for markdown headers
local color1_bg = "#f265b5"
local color2_bg = "#37f499"
local color3_bg = "#04d1f9"
local color4_bg = "#a48cf2"
local color5_bg = "#f1fc79"
local color6_bg = "#f7c67f"
vim.cmd(string.format([[highlight @markup.heading.1.markdown cterm=bold gui=bold guifg=%s]], color1_bg))
vim.cmd(string.format([[highlight @markup.heading.2.markdown cterm=bold gui=bold guifg=%s]], color2_bg))
vim.cmd(string.format([[highlight @markup.heading.3.markdown cterm=bold gui=bold guifg=%s]], color3_bg))
vim.cmd(string.format([[highlight @markup.heading.4.markdown cterm=bold gui=bold guifg=%s]], color4_bg))
vim.cmd(string.format([[highlight @markup.heading.5.markdown cterm=bold gui=bold guifg=%s]], color5_bg))
vim.cmd(string.format([[highlight @markup.heading.6.markdown cterm=bold gui=bold guifg=%s]], color6_bg))
