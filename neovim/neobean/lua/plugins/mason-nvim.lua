-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mason-nvim.lua

-- https://github.com/williamboman/mason.nvim
-- https://github.com/jonschlinkert/markdown-toc
return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      -- I installed "templ" and other LSPS, these requirements can be found in
      -- the TEMPL docs https://templ.guide/commands-and-tools/ide-support/#neovim--050
      -- The templ command must be in your system path for the LSP to be able to start
      -- vim.list_extend(opts.ensure_installed, { "templ", "html-lsp", "htmx-lsp", "tailwindcss-language-server" })
      "templ",
      "html-lsp",
      "htmx-lsp",
      "tailwindcss-language-server",
      -- marksman and markdownlint come by default in the lazyvim config
      --
      -- I installed markdown-toc as I use to to automatically create and upate
      -- the TOC at the top of each file
      -- vim.list_extend(opts.ensure_installed, { "markdownlint-cli2", "marksman", "markdown-toc" })
    },
  },
}
