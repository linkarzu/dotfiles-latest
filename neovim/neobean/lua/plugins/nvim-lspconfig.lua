-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lspconfig.lua
-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lspconfig.lua
--
-- https://github.com/neovim/nvim-lspconfig

return {
  "neovim/nvim-lspconfig",
  opts = {

    -- This disables inlay hints
    -- When programming in Go, these made my experience feel like shit, because were
    -- very intrusive and I never got used to them.
    --
    -- Folke has a keymap to toggle inaly hints with <leader>uh
    inlay_hints = { enabled = false },

    -- Add a border to the diagnostics window or popup
    -- https://github.com/LazyVim/LazyVim/discussions/2825#discussioncomment-8914135
    diagnostics = {
      float = {
        border = "rounded",
      },
    },

    servers = {
      ["*"] = {
        keys = {
          {
            "<leader>cr",
            function()
              local group = vim.api.nvim_create_augroup("LinkarzuSaveAfterLspRename", { clear = true })
              -- LSP rename updates references in other buffers but does not save them.
              -- Autosave usually keeps unrelated files clean, so after rename completes,
              -- write all modified buffers to avoid quit prompts for each updated note.
              local autocmd
              autocmd = vim.api.nvim_create_autocmd("LspRequest", {
                group = group,
                callback = function(ev)
                  local request = ev.data and ev.data.request
                  if not request or request.method ~= "textDocument/rename" or request.type ~= "complete" then
                    return
                  end
                  if autocmd then
                    pcall(vim.api.nvim_del_autocmd, autocmd)
                  end
                  vim.schedule(function()
                    vim.cmd("silent! wall")
                  end)
                end,
              })
              vim.lsp.buf.rename()
            end,
            desc = "Rename",
            has = "rename",
          },
        },
      },
      marksman = {
        enabled = false,
      },
      -- markdown-oxide
      markdown_oxide = {
        -- Ensure that dynamicRegistration is enabled
        -- This allows the LS to take into account actions like Create Unresolved File, etc
        capabilities = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          require("blink.cmp").get_lsp_capabilities(),
          {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          }
        ),
      },
      -- https://www.reddit.com/r/neovim/comments/1j7ookn/comment/mgysste/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      -- The hover window configuration for the diagnostics is done in lamw26wmal
      -- ~/github/dotfiles-latest/neovim/neobean/lua/config/autocmds.lua
      harper_ls = {
        enabled = true,
        filetypes = { "markdown", "typst" },
        root_dir = function(bufnr, on_dir)
          local umg_root = vim.fs.normalize(vim.fn.expand("~/github/obsidian_main/075-umg"))
          local path = vim.api.nvim_buf_get_name(bufnr)
          if path ~= "" then
            path = vim.fs.normalize(path)
            if vim.bo[bufnr].filetype == "markdown" and (path == umg_root or vim.startswith(path, umg_root .. "/")) then
              return
            end
          end
          local root = vim.fs.root(bufnr, { ".harper-dictionary.txt", ".git" })
          if root then
            on_dir(root)
          end
        end,
        settings = {
          ["harper-ls"] = {
            userDictPath = "~/github/dotfiles-latest/neovim/neobean/spell/en.utf-8.add",
            -- linters = {
            --   -- Disabling ToDoHyphen because of
            --   -- https://github.com/Automattic/harper/issues/1573#issuecomment-3777776431
            --   -- -- ToDoHyphen = false,
            --   -- SentenceCapitalization = true,
            --   -- SpellCheck = true,
            -- },
            isolateEnglish = true,
            markdown = {
              -- [ignores this part]()
              -- [[ also ignores my marksman links ]]
              IgnoreLinkTitle = true,
            },
          },
        },
      },
    },
  },
}
