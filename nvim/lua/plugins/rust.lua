return {
  {
    "neovim/nvim-lspconfig",
    opts = { diagnostics = { update_in_insert = true } },
  },
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { rust = { "rustfmt" } } },
  },
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            -- The default LazyVim setting enables every feature, which can
            -- produce conflicting cfgs in crates with exclusive features.
            cargo = { allFeatures = false },
            checkOnSave = true,
            check = { command = "clippy" },
            diagnostics = { enable = true },
          },
        },
      },
    },
    keys = {
      { "<localleader>r", "<cmd>RustLsp runnables<cr>", ft = "rust", desc = "Rust runnables" },
      { "<localleader>t", "<cmd>RustLsp testables<cr>", ft = "rust", desc = "Rust tests" },
      { "<localleader>e", "<cmd>RustLsp explainError<cr>", ft = "rust", desc = "Explain Rust error" },
      { "<localleader>m", "<cmd>RustLsp expandMacro<cr>", ft = "rust", desc = "Expand Rust macro" },
      { "<localleader>c", "<cmd>RustLsp flyCheck<cr>", ft = "rust", desc = "Run Rust Clippy" },
      { "<localleader>R", "<cmd>RustAnalyzer restart<cr>", ft = "rust", desc = "Restart rust-analyzer" },
    },
  },
}
