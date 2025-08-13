-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lint.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/nvim-lint.lua

--[=====[
https://github.com/mfussenegger/nvim-lint

This plugin allows you to globally set the .markdownlint.yaml file instead of 
doing it on a per :pwd directory

If you add the file to the :pwd directory, that file will take precedence
instead of the --config file specified below lamw25wmal

This suggestion came from one of my youtube videos from user @killua_148
"My complete Neovim markdown setup and workflow in 2024"
https://youtu.be/c0cuvzK1SDo

--]=====]

-- Only load when the config file exists, I added this for users that don't
-- have this file, so they don't get an error. They'll get a warning letting
-- them know where this file is being looked for
local cfg_path = os.getenv("HOME") .. "/github/dotfiles-latest/.markdownlint.yaml"

return {
  "mfussenegger/nvim-lint",
  optional = true,
  cond = function()
    if vim.fn.filereadable(cfg_path) == 1 then
      return true
    else
      vim.schedule(function()
        vim.notify(
          string.format(
            "[nvim-lint] Skipping markdownlint-cli2 setup — expected config file not found at:\n%s",
            cfg_path
          ),
          vim.log.levels.WARN
        )
      end)
      return false
    end
  end,
  opts = {
    linters = {
      -- https://github.com/LazyVim/LazyVim/discussions/4094#discussioncomment-10178217
      ["markdownlint-cli2"] = {
        args = { "--config", cfg_path, "--" },
      },
    },
  },
}
