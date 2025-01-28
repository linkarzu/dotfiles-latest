-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/grug-far.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/grug-far.lua

-- https://github.com/MagicDuck/grug-far.nvim

-- I needed to replace colors["linkarzu_color10"] with "linkarzu_color10"
-- and not only for color10, but from color01 to color20 in multiple files,
-- hundreds of times. To achieve this use:
-- colors\["(linkarzu_color\d+)"\]
-- "$1"
--
-- I wanted to exclude 2 files from the replace, so added each file in a
-- separate line under
-- Files Filter:
-- !wezterm.lua
-- !eldritch.lua
--
-- I needed to change this
-- { desc = "Lazygit (Root Dir)" }
--  for this in all my keymaps
-- { desc = "Lazygit (Root Dir)", lhs = "", mode = "n" }
--
-- So did this
-- \{ desc = "(.*?)" }
-- { desc = "$1", lhs = "", mode = "n" }
--
-- To add `{:target="\_blank"}` to links that don't have it
-- \[(.*?)\]\((http[s]?:\/\/.*?)\)(?:[^{]|$)
-- [$1]($2){:target="_blank"}
--
-- \- \[Here's the link\]\(https:\/\/x.com\/link_arzu\)\{:target="\\_blank"\}

-- See ~/github/dotfiles-latest/neovim/neobean/README.md for more multiline
-- examples

return {
  "MagicDuck/grug-far.nvim",
  --- Ensure existing keymaps and opts remain unaffected
  config = function(_, opts)
    require("grug-far").setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "grug-far",
      callback = function()
        -- Map <Esc> to quit after ensuring we're in normal mode
        vim.keymap.set({ "i", "n" }, "<Esc>", "<Cmd>stopinsert | bd!<CR>", { buffer = true })
      end,
    })
  end,
  keys = {
    {
      "<leader>sr",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
  },
}
