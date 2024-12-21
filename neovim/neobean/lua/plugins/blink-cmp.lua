-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua

return {
  "saghen/blink.cmp",
  enabled = true,
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "copilot", "luasnip" },
      providers = {
        lsp = {
          name = "lsp",
          enabled = true,
          module = "blink.cmp.sources.lsp",
          kind = "LSP",
          score_offset = 1000, -- the higher the number, the higher the priority
        },
        luasnip = {
          name = "luasnip",
          enabled = true,
          module = "blink.cmp.sources.luasnip",
          score_offset = 950, -- the higher the number, the higher the priority
        },
        snippets = {
          name = "snippets",
          enabled = true,
          module = "blink.cmp.sources.snippets",
          score_offset = 900, -- the higher the number, the higher the priority
        },
        -- Third class citizen mf always talking shit
        copilot = {
          name = "copilot",
          enabled = true,
          module = "blink-cmp-copilot",
          kind = "Copilot",
          score_offset = -100, -- the higher the number, the higher the priority
          async = true,
        },
      },
    },
    -- This comes from the luasnip extra, if you don't add it, won't be able to
    -- jump forward or backward in luasnip snippets
    -- https://www.lazyvim.org/extras/coding/luasnip#blinkcmp-optional
    snippets = {
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
    },
    -- The default preset used by lazyvim accepts completions with enter
    -- I don't like using enter because if on markdown and typing
    -- something, but you want to go to the line below, if you press enter,
    -- the completion will be accepted
    keymap = {
      preset = "default",
      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },
  },
}
