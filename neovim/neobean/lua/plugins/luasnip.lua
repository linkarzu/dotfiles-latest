-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/luasnip.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/luasnip.lua

-- This allows me to create my custom snippets
-- All you need to do, if using the lazyvim.org distro, is to enable the
-- coding.luasnip LazyExtra and then add this file

-- If you're a dotfiles scavenger, definitely watch this video (you're welcome)
-- https://youtu.be/FmHhonPjvvA?si=8NrcRWu4GGdmTzee

return {
  "L3MON4D3/LuaSnip",
  opts = function(_, opts)
    local ls = require("luasnip")

    -- Preserve existing opts from LazyVim
    opts = vim.tbl_deep_extend("force", opts, {
      history = true,
      delete_check_events = "TextChanged",
    })

    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    -- Custom snippets
    -- the "all" after ls.add_snippets("all" is the filetype, you can know a
    -- file filetype with :set ft
    -- Custom snippets

    -- #####################################################################
    --                            Markdown
    -- #####################################################################

    -- Helper function to create code block snippets
    local function create_code_block_snippet(lang)
      return s(lang, {
        t({ "```" .. lang, "" }),
        i(1),
        t({ "", "```" }),
      })
    end

    -- Define languages for code blocks
    local languages = {
      "txt",
      "lua",
      "sql",
      "go",
      "regex",
      "bash",
      "markdown",
      "markdown_inline",
      "yaml",
      "json",
      "jsonc",
      "cpp",
      "csv",
      "java",
      "javascript",
      "python",
      "dockerfile",
      "html",
      "css",
      "templ",
      "php",
    }

    -- Generate snippets for all languages
    local snippets = {}
    for _, lang in ipairs(languages) do
      table.insert(snippets, create_code_block_snippet(lang))
    end

    table.insert(
      snippets,
      s("chirpy", {
        t({
          " ",
          "<!-- markdownlint-disable -->",
          "<!-- prettier-ignore-start -->",
          " ",
          "<!-- tip=green, info=blue, warning=yellow, danger=red -->",
          " ",
          "> ",
        }),
        i(1),
        t({
          "",
          "{: .prompt-",
        }),
        -- In case you want to add a default value "tip" here, but I'm having
        -- issues with autosave
        -- i(2, "tip"),
        i(2),
        t({
          " }",
          " ",
          "<!-- prettier-ignore-end -->",
          "<!-- markdownlint-restore -->",
        }),
      })
    )

    table.insert(
      snippets,
      s("markdownlint", {
        t({
          " ",
          "<!-- markdownlint-disable -->",
          " ",
          "> ",
        }),
        i(1),
        t({
          " ",
          " ",
          "<!-- markdownlint-restore -->",
        }),
      })
    )

    table.insert(
      snippets,
      s("prettier-ignore", {
        t({
          " ",
          "<!-- prettier-ignore-start -->",
          " ",
          "> ",
        }),
        i(1),
        t({
          " ",
          " ",
          "<!-- prettier-ignore-end -->",
        }),
      })
    )

    table.insert(
      snippets,
      s("link", {
        t("["),
        i(1),
        t("]("),
        i(2),
        t(")"),
      })
    )

    table.insert(
      snippets,
      s("linkt", {
        t("["),
        i(1),
        t("]("),
        i(2),
        t('){:target="_blank"}'),
      })
    )

    table.insert(
      snippets,
      s("todo", {
        t("<!-- TODO: "),
        i(1),
        t(" -->"),
      })
    )

    ls.add_snippets("markdown", snippets)

    -- #####################################################################
    --                         all the filetypes
    -- #####################################################################
    ls.add_snippets("all", {
      s("workflow", {
        t("lamw25wmal"),
      }),

      s("lam", {
        t("lamw25wmal"),
      }),

      s("mw25", {
        t("lamw25wmal"),
      }),
    })

    return opts
  end,
}
