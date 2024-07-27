-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/options.lua

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- This add the bar that shows the file path on the top right
-- vim.opt.winbar = "%=%m %f"
--
-- Modified version of the bar, shows pathname on right, hostname left
-- vim.opt.winbar = "%=" .. vim.fn.systemlist("hostname")[1] .. "            %m %f"
--
-- This shows pathname on the left and hostname on the right
-- vim.opt.winbar = "%m %f%=" .. vim.fn.systemlist("hostname")[1]
--
-- Using different colors, defining the colors in this file
vim.cmd([[highlight WinBar1 guifg=#04d1f9]])
vim.cmd([[highlight WinBar2 guifg=#37f499]])
vim.opt.winbar = "%#WinBar1#%m %f%*%=%#WinBar2#" .. vim.fn.systemlist("hostname")[1]

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
vim.opt.textwidth = 80

-- Above option applies the setting to ALL file types, if you want to apply it
-- to specific files only
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   -- pattern = {"python", "javascript", "html"},
--   callback = function()
--     vim.opt_local.textwidth = 80
--   end,
-- })

-- Shows colorcolumn that helps me with markdown guidelines. This applies to ALL
-- file types
vim.opt.colorcolumn = "80"

-- -- To apply it to markdown files only
-- vim.api.nvim_create_autocmd("BufWinEnter", {
--   pattern = { "*.md" },
--   callback = function()
--     vim.opt.colorcolumn = "80"
--     vim.opt.textwidth = 80
--   end,
-- })

-- I added `localoptions` to save the language settings
-- See the help for `sessionoptions`
-- `localoptions`: options and mappings local to a window or buffer
-- (not global values for local options)
--
-- The plugin that saves the session information is
-- https://github.com/folke/persistence.nvim and comes enabled in the
-- lazyvim.org distro lamw25wmal
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
vim.opt.spelllang = { "en,es" }

-- ############################################################################
--                             Neovide section
-- ############################################################################

-- The copy and paste sections were found on:
-- https://neovide.dev/faq.html#how-can-i-use-cmd-ccmd-v-to-copy-and-paste
if vim.g.neovide then
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

  -- Specify the font used by Neovide
  vim.o.guifont = "MesloLGM_Nerd_Font:h14"
  -- This is limited by the refresh rate of your physical hardware, but can be
  -- lowered to increase battery life
  -- This setting is only effective when not using vsync,
  -- for example by passing --no-vsync on the commandline.
  vim.g.neovide_refresh_rate = 60
  -- This is how fast the cursor animation "moves", default 0.06
  vim.g.neovide_cursor_animation_length = 0.04
  -- Default 0.7
  vim.g.neovide_cursor_trail_size = 0.7

  -- produce particles behind the cursor, if want to disable them, set it to ""
  -- vim.g.neovide_cursor_vfx_mode = "railgun"
  -- vim.g.neovide_cursor_vfx_mode = "torpedo"
  -- vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_vfx_mode = "sonicboom"
  -- vim.g.neovide_cursor_vfx_mode = "ripple"
  -- vim.g.neovide_cursor_vfx_mode = "wireframe"
  -- vim.g.neovide_cursor_vfx_mode = "wireframe"
end

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- ############################################################################
--                           End of Neovide section
-- ############################################################################
