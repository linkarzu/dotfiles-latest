-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/options.lua

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set:
--
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
--
-- Add any additional options here

-- This add the bar that shows the file path on the top right
-- vim.opt.winbar = "%=%m %f"

-- Modified version of the bar, shows pathname on right, hostname left
-- vim.opt.winbar = "%=" .. vim.fn.systemlist("hostname")[1] .. "            %m %f"

-- This shows pathname on the left and hostname on the right
-- vim.opt.winbar = "%m %f%=" .. vim.fn.systemlist("hostname")[1]

-- Specify leader the default in lazyvim is " "
vim.g.mapleader = " "
-- In case you want to switch the leader key to backspace
-- vim.g.mapleader = vim.api.nvim_replace_termcodes("<BS>", false, false, true)

-- It turns out, I didn't want which key to show up immediately, I delayed which
-- key to only show after 1.5 seconds, so I added a delay in wht which-key
-- plugin configuration file
--
-- if I need to quickly search for a key, I press <M-k>
--
-- Old note: There's a delay everytime I press the leader key and that which-key
-- is shown I want it to be immediate lamw25wmal
--
-- timeout = true means Neovim will wait for potential mapping completions
-- timeoutlen = 1000 gives you 1 second to complete a key mapping sequence
-- Note: This is just the maximum wait time - if you type the complete mapping
-- faster (e.g., <leader>ff in 200ms), it executes immediately without waiting
-- for the full 1000ms. LazyVim defaults to 300ms, but I will test the more
-- relaxed default of 1000ms here.
vim.opt.timeout = true
-- Default neovim is 1,000 but lazyvim sets it to 300
vim.opt.timeoutlen = 1000

-- I find the animations a bit laggy
vim.g.snacks_animate = false

-- Conditional settings based on mode
if vim.g.neovim_mode == "skitty" then
  vim.opt.laststatus = 2
  vim.opt.statusline = "%m"

  -- Line numbers
  vim.opt.number = false
  vim.opt.relativenumber = false

  -- Disable the gutter
  vim.opt.signcolumn = "no"

  -- Text width and wrapping
  vim.opt.textwidth = 28

  -- -- I tried these 2 with prettier prosewrap in "preserve" mode, and I'm not sure
  -- -- what they do, I think lines are wrapped, but existing ones are not, so if I
  -- -- have files with really long lines, they will remain the same, also LF
  -- -- characters were introduced at the end of each line, not sure, didn't test
  -- -- enough
  -- --
  -- -- Wrap lines at convenient points, this comes enabled by default in lazyvim
  vim.opt.linebreak = false

  -- Set to false by default in lazyvim
  -- If this is "false", when I'm typing around the 28/33 character, I see the screen
  -- scrolling to the right, and I don't want that, setting it to true seems to
  -- fix that
  -- Problem if set to true is that markdown links don't wrap, so they span
  -- across multiple lines
  vim.opt.wrap = false

  -- No colorcolumn in skitty
  vim.opt.colorcolumn = ""

  local colors = require("config.colors")
  vim.cmd(string.format([[highlight WinBar1 guifg=%s]], colors["linkarzu_color03"]))
  -- -- Set the winbar to display "skitty-notes" with the specified color
  -- vim.opt.winbar = "%#WinBar1#   skitty-notes%*"
  -- Set the winbar to display the current file name on the left and "linkarzu" aligned to the right
  vim.opt.winbar = "%#WinBar1# %t%*%=%#WinBar1# linkarzu %*"
else
  -- I never used relative line numbers, so fuck that
  -- Edit a few days after, I'll give them a try again, so re-enabled them
  vim.opt.relativenumber = true

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

  -- -- Disable line wrap, set to false by default in lazyvim
  vim.opt.wrap = true

  -- Shows colorcolumn that helps me with markdown guidelines.
  -- This is the vertical bar that shows the 80 character limit
  -- This applies to ALL file types
  vim.opt.colorcolumn = "80"

  -- -- To apply it to markdown files only
  -- vim.api.nvim_create_autocmd("BufWinEnter", {
  --   pattern = { "*.md" },
  --   callback = function()
  --     vim.opt.colorcolumn = "80"
  --     vim.opt.textwidth = 80
  --   end,
  -- })

  -- Winbar
  -- Require the colors.lua module and access the colors directly without
  -- additional file reads
  local colors = require("config.colors")
  vim.cmd(string.format([[highlight WinBar1 guifg=%s]], colors["linkarzu_color03"]))
  vim.cmd(string.format([[highlight WinBar2 guifg=%s]], colors["linkarzu_color02"]))
  vim.cmd(string.format([[highlight WinBar3 guifg=%s gui=bold]], colors["linkarzu_color24"]))
  -- Function to get the full path and replace the home directory with ~
  local function get_winbar_path()
    local full_path = vim.fn.expand("%:p:h")
    return full_path:gsub(vim.fn.expand("$HOME"), "~")
  end
  -- Function to get the number of open buffers using the :ls command
  local function get_buffer_count()
    local buffers = vim.fn.execute("ls")
    local count = 0
    -- Match only lines that represent buffers, typically starting with a number followed by a space
    for line in string.gmatch(buffers, "[^\r\n]+") do
      if string.match(line, "^%s*%d+") then
        count = count + 1
      end
    end
    return count
  end
  -- Function to update the winbar
  local function update_winbar()
    local home_replaced = get_winbar_path()
    local buffer_count = get_buffer_count()
    vim.opt.winbar = "%#WinBar1#%m "
      .. "%#WinBar2#("
      .. buffer_count
      .. ") "
      -- this shows the filename on the left
      .. "%#WinBar3#"
      .. vim.fn.expand("%:t")
      -- This shows the file path on the right
      .. "%*%=%#WinBar1#"
      .. home_replaced
    -- I don't need the hostname as I have it in lualine
    -- .. vim.fn.systemlist("hostname")[1]
  end
  -- Autocmd to update the winbar on BufEnter and WinEnter events
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    callback = update_winbar,
  })
end

-- -- I tried these 2 with prettier prosewrap in "preserve" mode, and I'm not sure
-- -- what they do, I think lines are wrapped, but existing ones are not, so if I
-- -- have files with really long lines, they will remain the same, also LF
-- -- characters were introduced at the end of each line, not sure, didn't test
-- -- enough
-- --
-- -- Wrap lines at convenient points, this comes enabled by default in lazyvim
-- vim.opt.linebreak = true

-- -- This is my old way of updating the winbar but it stopped working, it
-- -- wasn't showing the entire path, it was being truncated in some dirs
-- vim.opt.winbar = "%#WinBar1#%m %f%*%=%#WinBar2#" .. vim.fn.systemlist("hostname")[1]

-- Enable autochdir to automatically change the working directory to the current file's directory
-- If you go inside a subdir, neotree will open that dir as the root
-- vim.opt.autochdir = true

-- Keeps my cursor in the middle whenever possible
-- This didn't work as expected, but the `stay-centered.lua` plugin did the trick
-- vim.opt.scrolloff = 999

-- If set to 0 it shows all the symbols in a file, like bulletpoints and
-- codeblock languages, obsidian.nvim works better with 1 or 2
-- Set it to 2 if using kitty or codeblocks will look weird
vim.opt.conceallevel = 0

-- Function to get the model of my mac, can be used by copilot-chat plugin
local function get_computer_model()
  local ok, handle = pcall(io.popen, "sysctl -n hw.model")
  if not ok or not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  if result then
    return result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
  end
  return nil
end
-- Store the computer model globally
_G.COMPUTER_MODEL = get_computer_model()
-- Compute the Copilot model based on the computer model
_G.COPILOT_MODEL = _G.COMPUTER_MODEL == "MacBookPro18,2" and "gpt-4o" or "claude-3.5-sonnet"
-- Optional: Create a command to show the computer model
vim.api.nvim_create_user_command("ShowComputerModel", function()
  local model = _G.COMPUTER_MODEL or "Unknown"
  print("Computer Model: " .. model)
end, {})

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

-- ############################################################################
--                             Neovide section
-- ############################################################################

-- NOTE: When in LazyGit if inside or outside neovim, if you want to edit files with
-- Neovide, you have to set the os.edit option in the
-- ~/github/dotfiles-latest/lazygit/config.yml file

-- NOTE: Also remember that there are settings in the file:
-- ~/github/dotfiles-latest/neovide/config.toml

-- NOTE: Text looks a bit bolder in Neovide, it doesn't bother me, but I think
-- there's no way to fix it, see:
-- https://github.com/neovide/neovide/issues/1231

-- The copy and paste sections were found on:
-- https://neovide.dev/faq.html#how-can-i-use-cmd-ccmd-v-to-copy-and-paste
if vim.g.neovide then
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

  -- This allows me to use cmd+v to paste stuff into neovide
  vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

  -- Specify the font used by Neovide
  -- vim.o.guifont = "MesloLGM_Nerd_Font:h14"
  vim.o.guifont = "JetBrainsMono Nerd Font:h15"
  -- This is limited by the refresh rate of your physical hardware, but can be
  -- lowered to increase battery life
  -- This setting is only effective when not using vsync,
  -- for example by passing --no-vsync on the commandline.
  --
  -- NOTE: vsync is configured in the neovide/config.toml file, I disabled it and set
  -- this to 120 even though my monitor is 75Hz, had a similar case in wezterm,
  -- see: https://github.com/wez/wezterm/issues/6334
  vim.g.neovide_refresh_rate = 120
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

  -- Really weird issue in which my winbar would be drawn multiple times as I
  -- scrolled down the file, this fixed it, found in:
  -- https://github.com/neovide/neovide/issues/1550
  vim.g.neovide_scroll_animation_length = 0

  -- This allows me to use the right "alt" key in macOS, because I have some
  -- neovim keymaps that use alt, like alt+t for the terminal
  -- https://youtu.be/33gQ9p-Zp0I
  vim.g.neovide_input_macos_option_key_is_meta = "only_right"
end

-- I also want the vim.g.neovim_mode cursor color to be changed
-- Neovide cursor color, remember to set these in your colorscheme, I have
-- mine set in ~/github/dotfiles-latest/neovim/neobean/lua/plugins/colorschemes/eldritch.lua
-- Otherwise, my cursor was white
vim.opt.guicursor = {
  "n-v-c-sm:block-Cursor", -- Use 'Cursor' highlight for normal, visual, and command modes
  "i-ci-ve:ver25-lCursor", -- Use 'lCursor' highlight for insert and visual-exclusive modes
  "r-cr:hor20-CursorIM", -- Use 'CursorIM' for replace mode
}

-- ############################################################################
--                           End of Neovide section
-- ############################################################################
