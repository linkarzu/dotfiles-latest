-- Filename: ~/github/dotfiles-latest/neovim/neobean-sticky/lua/config/options.lua
-- ~/github/dotfiles-latest/neovim/neobean-sticky/lua/config/options.lua

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Specify leader key, this is the default in lazyvim
vim.g.mapleader = " "

vim.opt.laststatus = 2
vim.opt.statusline = "%m"

-- Disable the gutter
vim.opt.signcolumn = "no"

-- Disable line numbers
vim.opt.number = false
vim.opt.relativenumber = false

-- I find the animations a bit laggy
vim.g.snacks_animate = false

-- Auto update plugins at startup
-- Tried to add this vimenter autocmd in the autocmds.lua file but it was never
-- triggered, this is because if I understand correctly Lazy.nvim delays the
-- loading of autocmds.lua until after VeryLazy or even after VimEnter
-- The fix is to add the autocmd to a file that’s loaded before VimEnter,
-- such as options.lua
-- https://github.com/LazyVim/LazyVim/issues/2592#issuecomment-2015093693
-- Only upate if there are updates
-- https://github.com/folke/lazy.nvim/issues/702#issuecomment-1903484213
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("autoupdate"),
  callback = function()
    if require("lazy.status").has_updates then
      require("lazy").update({ show = false })
    end
  end,
})

local colors = require("config.colors")
vim.cmd(string.format([[highlight WinBar1 guifg=%s]], colors["linkarzu_color03"]))
-- -- Set the winbar to display "skitty-notes" with the specified color
-- vim.opt.winbar = "%#WinBar1#   skitty-notes%*"
-- Set the winbar to display the current file name on the left and "linkarzu" aligned to the right
vim.opt.winbar = "%#WinBar1# %t%*%=%#WinBar1# linkarzu %*"

-- -- I tried these 2 with prettier prosewrap in "preserve" mode, and I'm not sure
-- -- what they do, I think lines are wrapped, but existing ones are not, so if I
-- -- have files with really long lines, they will remain the same, also LF
-- -- characters were introduced at the end of each line, not sure, didn't test
-- -- enough
-- --
-- -- Wrap lines at convenient points, this comes enabled by default in lazyvim
vim.opt.linebreak = false

-- -- Disable line wrap, set to false by default in lazyvim
vim.opt.wrap = false

-- -- This is my old way of updating the winbar but it stopped working, it
-- -- wasn't showing the entire path, it was being truncated in some dirs
-- vim.opt.winbar = "%#WinBar1#%m %f%*%=%#WinBar2#" .. vim.fn.systemlist("hostname")[1]

-- If set to 0 it shows all the symbols in a file, like bulletpoints and
-- codeblock languages, obsidian.nvim works better with 1 or 2
-- Set it to 2 if using kitty or codeblocks will look weird
vim.opt.conceallevel = 0

-- Enable autochdir to automatically change the working directory to the current file's directory
-- If you go inside a subdir, neotree will open that dir as the root
-- vim.opt.autochdir = true

-- Keeps my cursor in the middle whenever possible
-- This didn't work as expected, but the `stay-centered.lua` plugin did the trick
-- vim.opt.scrolloff = 999

-- When text reaches this limit, it automatically wraps to the next line.
-- This WILL NOT auto wrap existing lines, or if you paste a long line into a
-- file it will not wrap it as well
-- https://www.reddit.com/r/neovim/comments/1av26kw/i_tried_to_figure_it_out_but_i_give_up_how_do_i/
vim.opt.textwidth = 33

-- Above option applies the setting to ALL file types, if you want to apply it
-- to specific files only
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   -- pattern = {"python", "javascript", "html"},
--   callback = function()
--     vim.opt_local.textwidth = 80
--   end,
-- })

-- Shows colorcolumn that helps me with markdown guidelines.
-- This is the vertical bar that shows the 80 character limit
-- This applies to ALL file types
-- vim.opt.colorcolumn = "80"

-- -- To apply it to markdown files only
-- vim.api.nvim_create_autocmd("BufWinEnter", {
--   pattern = { "*.md" },
--   callback = function()
--     vim.opt.colorcolumn = "80"
--     vim.opt.textwidth = 80
--   end,
-- })

-- I added `localoptions` to save the language spell settings, otherwise, the
-- language of my markdown documents was not remembered if I set it to spanish
-- or to both en,es
-- See the help for `sessionoptions`
-- `localoptions`: options and mappings local to a window or buffer
-- (not global values for local options)
--
-- The plugin that saves the session information is
-- https://github.com/folke/persistence.nvim and comes enabled in the
-- lazyvim.org distro lamw25wmal
--
-- These sessionoptions come from the lazyvim distro, I just added localoptions
-- https://www.lazyvim.org/configuration/general
vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
  "localoptions",
}

-- Most of my files have 2 languages, spanish and english, so even if I set the
-- language to spanish, I always add some words in English to my documents, so
-- it's annoying to be adding those to the spanish dictionary
-- vim.opt.spelllang = { "en,es" }

-- I mainly type in english, if I set it to both above, files in English get a
-- bit confused and recognize words in spanish, just for spanish files I need to
-- set it to both
vim.opt.spelllang = { "en" }

-- -- My cursor was working fine, not  sure why it stopped working in wezterm, so
-- -- the config below fixed it
-- --
-- -- NOTE: I think the issues with my cursor started happening when I moved to wezterm
-- -- and started using the "wezterm" terminfo file, when in wezterm, I switched to
-- -- the "xterm-kitty" terminfo file, and the cursor is working great without
-- -- the configuration below. Leaving the config here as reference in case it
-- -- needs to be tested with another terminal emulator in the future
-- --
-- vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
