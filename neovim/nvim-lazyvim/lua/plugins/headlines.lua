-- https://github.com/lukas-reineke/headlines.nvim

return {
  "lukas-reineke/headlines.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()
    -- Define custom highlight groups using Vimscript
    vim.cmd([[highlight Headline1 guibg=#295715 guifg=white]])
    vim.cmd([[highlight Headline2 guibg=#8d8200 guifg=white]])
    vim.cmd([[highlight Headline3 guibg=#a56106 guifg=white]])
    vim.cmd([[highlight Headline4 guibg=#7e0000 guifg=white]])
    vim.cmd([[highlight Headline5 guibg=#1e0b7b guifg=white]])
    vim.cmd([[highlight Headline6 guibg=#560b7b guifg=white]])
    vim.cmd([[highlight CodeBlock guibg=#09090d]])
    -- vim.cmd [[highlight Dash guibg=#D19A66 gui=bold]]

    -- Setup headlines.nvim with the newly defined highlight groups
    require("headlines").setup({
      markdown = {
        fat_headlines = true,
        fat_headline_upper_string = "▃",
        fat_headline_lower_string = "-",
        headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
        -- Additional configurations as needed
      },
      -- Add configurations for other file types if necessary
    })
  end,
}
