-- https://github.com/okuuva/auto-save.nvim
--
-- This is a fork of original plugin `https://github.com/pocco81/auto-save.nvim`
-- but the original one was updated 2 years ago, and I was experiencing issues
-- with autoformat and undo/redo
--
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/auto-save.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/auto-save.lua

-- My related YouTube video
-- Save neovim files automatically with auto-save.nvim
-- https://youtu.be/W5fjlU4tSpw

-- Autocommand for printing the autosaved message
local group = vim.api.nvim_create_augroup("autosave", {})
vim.api.nvim_create_autocmd("User", {
  pattern = "AutoSaveWritePost",
  group = group,
  callback = function(opts)
    if opts.data.saved_buffer ~= nil then
      -- print("AutoSaved at " .. vim.fn.strftime("%H:%M:%S"))
      print("AutoSaved")
    end
  end,
})

return {
  {
    "okuuva/auto-save.nvim",
    enabled = true,
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
      trigger_events = { -- See :h events
        -- -- vim events that trigger an immediate save
        -- immediate_save = { "BufLeave", "FocusLost" },
        -- -- I'm disabling this, as it's autosaving when I leave the buffer and
        -- -- that's autoformatting stuff if on insert mode and following a tutorial
        immediate_save = { nil },
        defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
        cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
      },
      -- function that takes the buffer handle and determines whether to save the current buffer or not
      -- return true: if buffer is ok to be saved
      -- return false: if it's not ok to be saved
      -- if set to `nil` then no specific condition is applied
      condition = function(buf)
        -- Disable auto-save for the harpoon plugin, otherwise it just opens and closes
        -- https://github.com/ThePrimeagen/harpoon/issues/434
        --
        -- don't save for `sql` file types
        -- I do this so when working with dadbod the file is not saved every time
        -- I make a change, and a SQL query executed
        -- Run `:set filetype?` on a dadbod query to make sure of the filetype
        local filetype = vim.bo[buf].filetype
        if filetype == "harpoon" or filetype == "mysql" then
          return false
        end
        -- Skip autosave if you're in an active snippet
        if require("luasnip").in_snippet() then
          return false
        end
        return true
      end,
      write_all_buffers = false, -- write all buffers when the current one meets `condition`
      -- Do not execute autocmds when saving
      -- This is what fixed the issues with undo/redo that I had
      -- https://github.com/okuuva/auto-save.nvim/issues/55
      -- Issue in original plugin
      -- https://github.com/pocco81/auto-save.nvim/issues/70
      noautocmd = false,
      lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
      -- delay after which a pending save is executed (default 1000)
      debounce_delay = 750,
      -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
      debug = false,
    },
  },
}
