-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/trouble.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/trouble.lua

return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      lsp = {
        win = { position = "right" },
      },
    },
    keys = {
      -- If I close the incorrect pane, I can bring it up with ctrl+o
      ["<esc>"] = "close",
      -- I want to be able to bring up code actions from within trouble, this is
      -- very useful for harper-ls / harper_ls / harper language server
      ["<leader>ca"] = {
        desc = "Code Action",
        action = function()
          local trouble = require("trouble")
          -- Save the Trouble window id (if Trouble is currently open in some window)
          local trouble_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if ft == "trouble" then
              trouble_win = win
              break
            end
          end
          -- Get the diagnostics view (doesn't steal focus), and use the view method
          local view = trouble.open({ mode = "diagnostics", focus = false })
          if view then
            view:jump()
          end
          local target_name = vim.api.nvim_buf_get_name(0)
          local target_tick = vim.api.nvim_buf_get_changedtick(0)
          vim.schedule(function()
            vim.lsp.buf.code_action()
            -- Go back to the Trouble window (bottom) if it still exists
            if trouble_win and vim.api.nvim_win_is_valid(trouble_win) then
              vim.api.nvim_set_current_win(trouble_win)
            end
            -- Wait until the file changes, then save it (by filename)
            local tries = 0
            local function save_if_changed()
              tries = tries + 1
              local bufnr = vim.fn.bufnr(target_name, false)
              if bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr) then
                if vim.api.nvim_buf_get_changedtick(bufnr) ~= target_tick or vim.bo[bufnr].modified then
                  vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("silent! update")
                  end)
                  return
                end
              end
              if tries < 120 then
                vim.defer_fn(save_if_changed, 150)
              end
            end
            vim.defer_fn(save_if_changed, 150)
          end)
        end,
      },
    },
  },
}
