--[=====[
Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/project-explorer.lua
~/github/dotfiles-latest/neovim/neobean/lua/plugins/project-explorer.lua

https://github.com/Rics-Dev/project-explorer.nvim

Found out about this through reddit
https://www.reddit.com/r/neovim/comments/1ef1b2q/my_first_ever_neovim_plugin_a_simple_project/

This plugin allows me to explore different projects when using neovide, to kind 
of simulate the tmux-sessionizer functionality, as tmux is not available in neovide
--]=====]

return {
  "Rics-Dev/project-explorer.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    paths = {
      "~/github",
      os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/github",
      "/System/Volumes/Data/mnt",
    }, --custom paths set by user
    newProjectPath = "~/github", --custom path for new projects
    file_explorer = function(dir) --custom file explorer set by user
      vim.cmd("Neotree close")
      require("mini.files").open(dir, true)
      -- -- By default it uses neotree but I changed it for mini.files
      -- vim.cmd("Neotree " .. dir)
    end,
    -- Or for oil.nvim:
    -- file_explorer = function(dir)
    --   require("oil").open(dir)
    -- end,
  },
  config = function(_, opts)
    require("project_explorer").setup(opts)
  end,
  keys = {
    { "<leader>fP", "<cmd>ProjectExplorer<cr>", desc = "Project Explorer" },
  },
  lazy = false,
}
