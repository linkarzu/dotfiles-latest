-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/fzf-lua.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/fzf-lua.lua

-- https://github.com/ibhagwan/fzf-lua

return {
  {
    "ibhagwan/fzf-lua",
    -- I'm enablig fzf-lua even though my main tool is still telescope, if
    -- disabled can't do gd to go to definition, will test and see what issues
    -- arise by having both telescope and fzf-lua enabled
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
    keys = {
      -- I want to use telescope to find files
      {
        "<leader><Space>",
        function()
          local cwd = vim.fn.getcwd()
          require("telescope").extensions.frecency.frecency(require("telescope.themes").get_ivy({
            workspace = "CWD",
            cwd = cwd,
            prompt_title = "FRECENCY " .. cwd,
          }))
        end,
        desc = "Find Files (Root Dir) [Space]",
      },
      -- I want to grep with telescope
      { "<leader>sg", LazyVim.pick("live_grep", { root = false, theme = "ivy" }), desc = "Grep (Root Dir)" },
      {
        "<leader>sg",
        function()
          local cwd = vim.fn.getcwd()
          require("telescope.builtin").live_grep(require("telescope.themes").get_ivy({
            -- gets current working directory
            cwd = cwd,
            prompt_title = "GREP " .. cwd,
          }))
        end,
        desc = "[P]Grep (Root Dir)",
      },
    },
  },
}
