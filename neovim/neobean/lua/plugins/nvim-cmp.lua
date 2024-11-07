-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-cmp.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-cmp.lua
--
-- I don't want to accept a snippet or an autocomplete when pressing enter, but
-- instead accept them with ctrl+y

-- I got this configuration from here
-- https://github.com/LazyVim/LazyVim/discussions/2549#discussioncomment-8462690

return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
        -- Found this tip related to cmp.config.disable here
        -- https://www.reddit.com/r/neovim/comments/19054s4/help_how_do_i_auto_complete_with_tab_in_lazyvim/
        ["<CR>"] = cmp.config.disable,

        -- -- Below are defaults for lazyvim.org config
        -- -- http://www.lazyvim.org/plugins/coding#nvim-cmp-2
        -- ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
        -- ["<C-Space>"] = cmp.mapping.complete(),
        -- ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
        -- -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        -- ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }),
        -- ["<C-CR>"] = function(fallback)
        --   cmp.abort()
        --   fallback()
        -- end,
      })

      -- Modify existing sources priorities
      for _, source in ipairs(opts.sources) do
        if source.name == "luasnip" then
          source.priority = 1000 -- Highest priority for snippets
        end
      end

      -- Add copilot source with lower priority
      table.insert(opts.sources, 1, {
        name = "copilot",
        -- `group_index` in nvim-cmp is used to group completion sources
        -- Sources with lower group numbers (like 1) appear before sources
        -- with higher numbers (like 2).
        group_index = 2, -- Changed from 1 to 2
        priority = 100, -- Lower priority than snippets
      })

      opts.sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.kind,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      }
    end,
  },
}
