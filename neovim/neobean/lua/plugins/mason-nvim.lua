-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mason-nvim.lua

-- https://github.com/williamboman/mason.nvim
-- https://github.com/jonschlinkert/markdown-toc
return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      -- I installed "templ" and other LSPS, these requirements can be found in
      -- the TEMPL docs https://templ.guide/commands-and-tools/ide-support/#neovim--050
      -- The templ command must be in your system path for the LSP to be able to start
      -- vim.list_extend(opts.ensure_installed, { "templ", "html-lsp", "htmx-lsp", "tailwindcss-language-server" })
      "templ",
      "html-lsp",
      -- htmx-lsp is the culprit for a bug that haunted me for fucking days.
      -- only when in markdown files my blink completions would take like 5
      -- seconds to load. You have no idea what I had to go through to figure
      -- this out. It broke after some updates, not sure which one, if the LSP
      -- itself, blink or what
      -- "htmx-lsp",
      "tailwindcss-language-server",
      "harper-ls",
      -- Not installing the tree-sitter CLI through mason due do this
      -- https://github.com/LazyVim/LazyVim/issues/6437#issuecomment-3304278107
      -- "tree-sitter-cli",
      -- marksman and markdownlint come by default in the lazyvim config
      --
      -- I installed markdown-toc as I use to to automatically create and upate
      -- the TOC at the top of each file
      -- vim.list_extend(opts.ensure_installed, { "markdownlint-cli2", "marksman", "markdown-toc" })
    })
  end,
}
