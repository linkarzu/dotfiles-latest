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

-- Change background color when switching between neovim splits and tmux panes
vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost", "WinEnter", "WinLeave", "BufEnter", "BufLeave" }, {
  callback = function(ev)
    if ev.event == "FocusGained" or ev.event == "WinEnter" or ev.event == "BufEnter" then
      -- Active window - darker background
      vim.cmd("hi Normal guibg=" .. colors.linkarzu_color10)
      vim.cmd("hi NormalFloat guibg=" .. colors.linkarzu_color10)
      -- vim.cmd("hi NormalNC guibg=" .. colors.linkarzu_color10)
      -- vim.cmd("hi NormalFloatNC guibg=" .. colors.linkarzu_color10)
      vim.cmd("hi TreesitterContext guibg=" .. colors.linkarzu_color10)
      vim.cmd("hi TreesitterContextLineNumber guibg=" .. colors.linkarzu_color10)
    else
      -- Inactive window - brighter background
      vim.cmd("hi Normal guibg=" .. colors.linkarzu_color25)
      vim.cmd("hi NormalNC guibg=" .. colors.linkarzu_color25)
      vim.cmd("hi NormalFloat guibg=" .. colors.linkarzu_color25)
      vim.cmd("hi NormalFloatNC guibg=" .. colors.linkarzu_color25)
      vim.cmd("hi TreesitterContext guibg=" .. colors.linkarzu_color25)
      vim.cmd("hi TreesitterContextLineNumber guibg=" .. colors.linkarzu_color25)
    end
  end,
})
