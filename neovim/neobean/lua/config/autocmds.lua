-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/autocmds.lua

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- config/autocmds.lua

-- Require the colors.lua module and access the colors directly without
-- additional file reads
-- local colors = require("config.colors")

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- -- This is for dadbod-ui auto completion
-- -- https://github.com/kristijanhusak/vim-dadbod-completion/issues/53#issuecomment-1705335855
-- local cmp = require("cmp")
-- local autocomplete_group = vim.api.nvim_create_augroup("vimrc_autocompletion", { clear = true })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "sql", "mysql", "plsql" },
--   callback = function()
--     cmp.setup.buffer({
--       sources = {
--         { name = "vim-dadbod-completion" },
--         { name = "buffer" },
--         { name = "luasnip" },
--       },
--     })
--   end,
--   group = autocomplete_group,
-- })

-- close some filetypes with <esc>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "grug-far",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
    "dbout",
    "gitsigns-blame",
    "Lazy",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "<esc>", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- -- This is used to switch between light and dark background colors when the
-- -- focus is lost or gained, for example when I switch from neovim to a tmux
-- -- pane on the right, or between 2 neovim splits
-- vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost", "WinEnter", "WinLeave" }, {
--   callback = function(ev)
--     local active_bg = colors.linkarzu_color10 -- darker background
--     local inactive_bg = colors.linkarzu_color07 -- brighter background
--     if ev.event == "FocusGained" or ev.event == "WinEnter" then
--       -- Active window - darker background
--       vim.cmd("hi Normal guibg=" .. active_bg)
--       vim.cmd("hi NormalFloat guibg=" .. active_bg)
--       -- vim.cmd("hi NormalNC guibg=" .. active_bg)
--       -- vim.cmd("hi NormalFloatNC guibg=" .. active_bg)
--       vim.cmd("hi TreesitterContext guibg=" .. active_bg)
--       vim.cmd("hi TreesitterContextLineNumber guibg=" .. active_bg)
--     else
--       -- Inactive window - brighter background
--       vim.cmd("hi Normal guibg=" .. inactive_bg)
--       vim.cmd("hi NormalNC guibg=" .. inactive_bg)
--       vim.cmd("hi NormalFloat guibg=" .. inactive_bg)
--       vim.cmd("hi NormalFloatNC guibg=" .. inactive_bg)
--       vim.cmd("hi TreesitterContext guibg=" .. inactive_bg)
--       vim.cmd("hi TreesitterContextLineNumber guibg=" .. inactive_bg)
--     end
--   end,
-- })

-- -- -- This debounce prevents to see the color switch when switching betweeen 2
-- -- -- buffers. Remember that you'll see the color switch when switching between
-- -- -- tmux sessions, I haven't figured out how to add a delay there
-- local function update_background(event_type)
--   local active_bg = colors.linkarzu_color10 -- darker background
--   local inactive_bg = colors.linkarzu_color07 -- brighter background
--   if event_type == "FocusGained" or event_type == "WinEnter" then
--     -- Active window - darker background
--     vim.cmd("hi Normal guibg=" .. active_bg)
--     -- Commented so that when focus another pane inactive background changes
--     -- vim.cmd("hi NormalNC guibg=" .. active_bg)
--     vim.cmd("hi NormalFloat guibg=" .. active_bg)
--     vim.cmd("hi NormalFloatNC guibg=" .. active_bg)
--     vim.cmd("hi TreesitterContext guibg=" .. active_bg)
--     vim.cmd("hi TreesitterContextLineNumber guibg=" .. active_bg)
--     -- vim.cmd("hi MiniFilesTitleFocused guibg=" .. active_bg)
--     vim.cmd("hi MiniDiffSignChange guibg=" .. active_bg)
--     vim.cmd("hi MiniDiffSignAdd guibg=" .. active_bg)
--     vim.cmd("hi MiniDiffSignDelete guibg=" .. active_bg)
--     vim.cmd("hi NonText guibg=" .. active_bg)
--     vim.cmd("hi WinBar guibg=" .. active_bg)
--     -- These 2 statusline colors replace the lualine color when lualine is not
--     -- enabled
--     vim.cmd("hi StatusLine guibg=" .. active_bg)
--     vim.cmd("hi StatusLineNC guibg=" .. active_bg)
--     vim.cmd("hi CursorLine guibg=" .. colors.linkarzu_color13)
--     -- This is the background of the folded lines
--     vim.cmd("hi Folded guibg=" .. active_bg)
--   else
--     -- Inactive window - brighter background
--     vim.cmd("hi Normal guibg=" .. inactive_bg)
--     vim.cmd("hi NormalNC guibg=" .. inactive_bg)
--     vim.cmd("hi NormalFloat guibg=" .. inactive_bg)
--     vim.cmd("hi NormalFloatNC guibg=" .. inactive_bg)
--     vim.cmd("hi TreesitterContext guibg=" .. inactive_bg)
--     vim.cmd("hi TreesitterContextLineNumber guibg=" .. inactive_bg)
--     -- vim.cmd("hi MiniFilesTitle guibg=" .. inactive_bg)
--     vim.cmd("hi MiniDiffSignChange guibg=" .. inactive_bg)
--     vim.cmd("hi MiniDiffSignAdd guibg=" .. inactive_bg)
--     vim.cmd("hi MiniDiffSignDelete guibg=" .. inactive_bg)
--     vim.cmd("hi NonText guibg=" .. inactive_bg)
--     vim.cmd("hi WinBar guibg=" .. inactive_bg)
--     -- These 2 statusline colors replace the lualine color when lualine is not
--     -- enabled
--     vim.cmd("hi StatusLine guibg=" .. inactive_bg)
--     vim.cmd("hi StatusLineNC guibg=" .. inactive_bg)
--     -- I don't want to see the cursorline when window is unfocused
--     vim.cmd("hi CursorLine guibg=" .. inactive_bg)
--     -- This is the background of the folded lines
--     vim.cmd("hi Folded guibg=" .. inactive_bg)
--   end
-- end
-- -- Debounce function for Focus events
-- local debounce_timer = nil
-- local function debounced_update_background(ev)
--   local event_type = ev.event -- Capture the event type
--   -- Cancel any existing timer
--   if debounce_timer then
--     vim.fn.timer_stop(debounce_timer)
--     debounce_timer = nil
--   end
--   -- Start a new timer
--   debounce_timer = vim.fn.timer_start(50, function()
--     vim.schedule(function()
--       update_background(event_type)
--       debounce_timer = nil
--     end)
--   end)
-- end
-- -- Immediate function for Win events
-- local function immediate_update_background(ev)
--   update_background(ev.event)
-- end
-- -- Create autocmd for WinEnter and WinLeave with immediate update
-- vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
--   callback = immediate_update_background,
-- })
-- -- Create autocmd for FocusGained and FocusLost with debounce
-- vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost" }, {
--   callback = debounced_update_background,
-- })

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    -- -- By default wrap is set to true regardless of what I chose in my options.lua file,
    -- -- This sets wrapping for my skitty-notes and I don't want to have
    -- -- wrapping there, I wanto to decide this in the options.lua file
    -- vim.opt_local.wrap = false
    vim.opt_local.spell = true
  end,
})

-- When I open markdown files I want to fold the markdown headings
-- Originally I thought about using it only for skitty-notes, but I think I want
-- it in all markdown files
--
-- if vim.g.neovim_mode == "skitty" then
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.md",
  callback = function()
    -- Avoid running zk multiple times for the same buffer
    if vim.b.zk_executed then
      return
    end
    vim.b.zk_executed = true -- Mark as executed
    -- Use `vim.defer_fn` to add a slight delay before executing `zk`
    vim.defer_fn(function()
      vim.cmd("normal zk")
      vim.cmd("silent write")
      vim.notify("Folded keymaps", vim.log.levels.INFO)
    end, 100) -- Delay in milliseconds (100ms should be enough)
  end,
})
-- end
