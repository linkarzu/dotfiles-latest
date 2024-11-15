-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/autocmds.lua

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- config/autocmds.lua

local colors = require("config.colors").load_colors()

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- This is for dadbod-ui auto completion
-- https://github.com/kristijanhusak/vim-dadbod-completion/issues/53#issuecomment-1705335855
local cmp = require("cmp")
local autocomplete_group = vim.api.nvim_create_augroup("vimrc_autocompletion", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql" },
  callback = function()
    cmp.setup.buffer({
      sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" },
        { name = "luasnip" },
      },
    })
  end,
  group = autocomplete_group,
})

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

vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost", "WinEnter", "WinLeave", "BufEnter", "BufLeave" }, {
  callback = function(ev)
    local active_bg = colors.linkarzu_color10 -- darker background
    local inactive_bg = colors.linkarzu_color07 -- brighter background
    if ev.event == "FocusGained" or ev.event == "WinEnter" or ev.event == "BufEnter" then
      -- Active window - darker background
      vim.cmd("hi Normal guibg=" .. active_bg)
      vim.cmd("hi NormalFloat guibg=" .. active_bg)
      -- vim.cmd("hi NormalNC guibg=" .. active_bg)
      -- vim.cmd("hi NormalFloatNC guibg=" .. active_bg)
      vim.cmd("hi TreesitterContext guibg=" .. active_bg)
      vim.cmd("hi TreesitterContextLineNumber guibg=" .. active_bg)
    else
      -- Inactive window - brighter background
      vim.cmd("hi Normal guibg=" .. inactive_bg)
      vim.cmd("hi NormalNC guibg=" .. inactive_bg)
      vim.cmd("hi NormalFloat guibg=" .. inactive_bg)
      vim.cmd("hi NormalFloatNC guibg=" .. inactive_bg)
      vim.cmd("hi TreesitterContext guibg=" .. inactive_bg)
      vim.cmd("hi TreesitterContextLineNumber guibg=" .. inactive_bg)
    end
  end,
})

-- -- Debounce wrapper using vim.defer_fn
-- -- This debounce prevents to see the color switch when switching betweeen 2
-- -- buffers, it doesn't kick in if I switch between 2 different panes until I
-- -- switch to another tmux session
-- local function debounce(func, timeout)
--   local timer = nil
--   return function(...)
--     local args = { ... }
--     if timer then
--       -- Cancel any existing timer
--       timer:close()
--       timer = nil
--     end
--     timer = vim.defer_fn(function()
--       func(unpack(args))
--       timer = nil
--     end, timeout)
--   end
-- end
-- -- Callback function to handle background color change
-- local function update_background(ev)
--   local active_bg = colors.linkarzu_color10 -- darker background
--   local inactive_bg = colors.linkarzu_color07 -- brighter background
--   if
--     ev.event == "FocusGained"
--     or ev.event == "WinEnter"
--     or ev.event == "BufEnter"
--     or ev.event == "TabEnter"
--     or ev.event == "BufWinEnter"
--   then
--     -- Active window or tab - darker background
--     vim.cmd("hi Normal guibg=" .. active_bg)
--     vim.cmd("hi NormalFloat guibg=" .. active_bg)
--     vim.cmd("hi TreesitterContext guibg=" .. active_bg)
--     vim.cmd("hi TreesitterContextLineNumber guibg=" .. active_bg)
--   else
--     -- Inactive window or tab - brighter background
--     vim.cmd("hi Normal guibg=" .. inactive_bg)
--     vim.cmd("hi NormalNC guibg=" .. inactive_bg)
--     vim.cmd("hi NormalFloat guibg=" .. inactive_bg)
--     vim.cmd("hi NormalFloatNC guibg=" .. inactive_bg)
--     vim.cmd("hi TreesitterContext guibg=" .. inactive_bg)
--     vim.cmd("hi TreesitterContextLineNumber guibg=" .. inactive_bg)
--   end
-- end
-- -- Create autocmd with debounce
-- vim.api.nvim_create_autocmd(
--   { "FocusGained", "FocusLost", "WinEnter", "WinLeave", "BufEnter", "BufLeave", "TabEnter", "TabLeave", "BufWinEnter" },
--   {
--     callback = debounce(update_background, 500), -- 500 ms debounce delay
--   }
-- )
