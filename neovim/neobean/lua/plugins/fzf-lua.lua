-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/fzf-lua.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/fzf-lua.lua

-- https://github.com/ibhagwan/fzf-lua

return {
  {
    "ibhagwan/fzf-lua",
    enabled = false,
    opts = function(_, opts)
      opts.winopts = vim.tbl_extend("force", opts.winopts or {}, {
        width = 1, -- Set to full screen width
        height = 0.65, -- Adjust height
        row = 1, -- window row position (0=top, 1=bottom)
        preview = {
          -- This sets the size of the preview window
          horizontal = "right:45%",
        },
      })
    end,
  },
}
