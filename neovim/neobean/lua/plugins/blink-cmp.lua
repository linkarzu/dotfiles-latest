return {
  "saghen/blink.cmp",
  enabled = false,
  opts = {
    sources = {
      compat = { "luasnip" },
      default = { "lsp", "path", "snippets", "buffer", "copilot" },
      providers = {
        luasnip = {
          name = "luasnip",
          enabled = true,
          module = "blink.compat.source",
          kind = "Snippet",
          score_offset = 900, -- the higher the number, the higher the priority
        },
        lsp = {
          name = "lsp",
          enabled = true,
          module = "blink.cmp.sources.lsp",
          kind = "LSP",
          score_offset = 1000, -- the higher the number, the higher the priority
        },
        -- Third class citizen mf always talking shit
        copilot = {
          name = "copilot",
          enabled = true,
          module = "blink-cmp-copilot",
          kind = "Copilot",
          score_offset = 0, -- the higher the number, the higher the priority
          async = true,
        },
      },
    },
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
  },
}
