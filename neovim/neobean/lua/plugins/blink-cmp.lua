-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua

-- completion plugin with support for LSPs and external sources that updates
-- on every keystroke with minimal overhead

-- https://www.lazyvim.org/extras/coding/blink
-- https://github.com/saghen/blink.cmp
-- Documentation site: https://cmp.saghen.dev/

return {
  "saghen/blink.cmp",
  enabled = true,
  opts = function(_, opts)
    -- Merge custom sources with the existing ones from lazyvim
    -- NOTE: by default lazyvim already includes the lazydev source, so not adding it here again
    opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
      default = { "lsp", "path", "snippets", "buffer", "copilot", "luasnip", "dadbod" },
      providers = {
        lsp = {
          name = "lsp",
          enabled = true,
          module = "blink.cmp.sources.lsp",
          kind = "LSP",
          -- When linking markdown notes, I would get snippets and text in the
          -- suggestions, I want those to show only if there are no LSP
          -- suggestions
          fallbacks = { "snippets", "luasnip", "buffer" },
          score_offset = 90, -- the higher the number, the higher the priority
        },
        luasnip = {
          name = "luasnip",
          enabled = true,
          module = "blink.cmp.sources.luasnip",
          min_keyword_length = 2,
          fallbacks = { "snippets" },
          score_offset = 85,
          max_items = 8,
          -- Only show luasnip items if I type the ; character, so
          -- to expand the "bash" snippet, I have to type ";bash"
          should_show_items = function()
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)
            return before_cursor:match(";%w*$") ~= nil
          end,
          -- After accepting the completion, delete the ";" character from the
          -- final inserted text
          transform_items = function(ctx, items)
            -- WARNING: Explicitly referencing ctx otherwise I was getting an "unused" warning
            local _ = ctx
            -- Get the current line and cursor position
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)
            -- Check if we have the trigger character
            local semicolon_pos = before_cursor:find(";[^;]*$")
            if semicolon_pos then
              -- Modify each completion item to remove the character
              for _, item in ipairs(items) do
                local original_text = item.insertText or item.label
                -- Create a TextEdit that will replace from the character to the cursor
                item.textEdit = {
                  newText = original_text,
                  range = {
                    start = {
                      line = vim.api.nvim_win_get_cursor(0)[1] - 1,
                      character = semicolon_pos - 1,
                    },
                    ["end"] = {
                      line = vim.api.nvim_win_get_cursor(0)[1] - 1,
                      character = col,
                    },
                  },
                }
              end
            end
            return items
          end,
        },
        path = {
          name = "Path",
          module = "blink.cmp.sources.path",
          score_offset = 3,
          -- When typing a path, I would get snippets and text in the
          -- suggestions, I want those to show only if there are no path
          -- suggestions
          fallbacks = { "snippets", "luasnip", "buffer" },
          opts = {
            trailing_slash = false,
            label_trailing_slash = true,
            get_cwd = function(context)
              return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
            end,
            show_hidden_files_by_default = true,
          },
        },
        buffer = {
          name = "Buffer",
          enabled = true,
          max_items = 3,
          module = "blink.cmp.sources.buffer",
          min_keyword_length = 4,
        },
        snippets = {
          name = "snippets",
          enabled = true,
          max_items = 3,
          module = "blink.cmp.sources.snippets",
          min_keyword_length = 4,
          score_offset = 80, -- the higher the number, the higher the priority
        },
        -- Example on how to configure dadbod found in the main repo
        -- https://github.com/kristijanhusak/vim-dadbod-completion
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
          score_offset = 85, -- the higher the number, the higher the priority
        },
        -- Third class citizen mf always talking shit
        copilot = {
          name = "copilot",
          enabled = true,
          module = "blink-cmp-copilot",
          kind = "Copilot",
          min_keyword_length = 6,
          score_offset = -100, -- the higher the number, the higher the priority
          async = true,
        },
      },
    })

    -- This comes from the luasnip extra, if you don't add it, won't be able to
    -- jump forward or backward in luasnip snippets
    -- https://www.lazyvim.org/extras/coding/luasnip#blinkcmp-optional
    opts.snippets = {
      expand = function(snippet)
        require("luasnip").lsp_expand(snippet)
      end,
      active = function(filter)
        if filter and filter.direction then
          return require("luasnip").jumpable(filter.direction)
        end
        return require("luasnip").in_snippet()
      end,
      jump = function(direction)
        require("luasnip").jump(direction)
      end,
    }

    -- The default preset used by lazyvim accepts completions with enter
    -- I don't like using enter because if on markdown and typing
    -- something, but you want to go to the line below, if you press enter,
    -- the completion will be accepted
    -- https://cmp.saghen.dev/configuration/keymap.html#default
    opts.keymap = {
      preset = "default",
      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },

      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },

      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
    }

    return opts
  end,
}
