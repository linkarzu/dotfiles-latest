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
          vim.schedule(function()
            vim.lsp.buf.code_action()
            -- Go back to the Trouble window (bottom) if it still exists
            if trouble_win and vim.api.nvim_win_is_valid(trouble_win) then
              vim.api.nvim_set_current_win(trouble_win)
            end
          end)
        end,
      },
    },
  },
}
