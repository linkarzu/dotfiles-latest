return {

  { -- manage projects
    'gnikdroy/projections.nvim',
    keys = {
      {
        '<leader>fp',
        function()
          vim.cmd 'Telescope projections'
        end,
        desc = '[p]rojects',
      },
    },
    config = function()
      -- Save localoptions to session file
      vim.opt.sessionoptions:append 'localoptions'
      require('projections').setup {
        store_hooks = {
          pre = function()
            -- nvim-tree
            local nvim_tree_present, api = pcall(require, 'nvim-tree.api')
            if nvim_tree_present then
              api.tree.close()
            end
          end,
        },
      }

      -- Autostore session on VimExit
      local Session = require 'projections.session'
      vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
        callback = function()
          local cwd = vim.loop.cwd()
          if cwd ~= nil then
            Session.store(cwd)
          end
        end,
      })

      -- Switch to project if vim was started in a project dir
      local switcher = require 'projections.switcher'
      vim.api.nvim_create_autocmd({ 'VimEnter' }, {
        callback = function()
          if vim.fn.argc() == 0 then
            local cwd = vim.loop.cwd()
            if cwd ~= nil then
              switcher.switch(cwd)
            end
          end
        end,
      })
    end,
  },
}
