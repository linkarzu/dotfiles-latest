return {
  "chomosuke/typst-preview.nvim",
  cmd = { "TypstPreview", "TypstPreviewToggle", "TypstPreviewUpdate" },
  keys = {
    -- <leader>cp will bring work to preview current file
    -- <leader>cpp previews the main.typ file
    {
      "<leader>cpp",
      ft = "typst",
      function()
        vim.g.typst_preview_use_main = true
        local main = vim.fs.normalize(vim.fn.getcwd() .. "/main.typ")
        if vim.fn.filereadable(main) ~= 1 then
          vim.notify("No main.typ found at: " .. main, vim.log.levels.WARN, { title = "typst-preview.nvim" })
          return
        end
        vim.cmd("TypstPreview")
      end,
      desc = "Toggle Typst Preview (main.typ at PWD)",
    },
  },
  opts = {
    dependencies_bin = {
      tinymist = "tinymist",
    },
    -- get_main_file is called by typst-preview.nvim to decide what file is the
    -- “main” Typst entrypoint for the preview.
    get_main_file = function(path_of_buffer)
      if vim.g.typst_preview_use_main then
        return vim.fs.normalize(vim.fn.getcwd() .. "/main.typ")
      end
      return path_of_buffer
    end,
  },
}
