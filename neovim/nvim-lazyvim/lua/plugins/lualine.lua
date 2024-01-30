return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- Function to decide color based on hostname
    local function decide_color()
      local hostname = vim.fn.systemlist("hostname")[1]
      local last_char = string.sub(hostname, -1)
      local bg_color
      local fg_color = "#36454F" -- default dark gray

      if last_char == "1" then
        bg_color = "#0DFFAE"
        -- fg_color = "#000080"  -- dark blue
      elseif last_char == "2" then
        bg_color = "#FF6200"
        -- fg_color = "#000080"  -- dark blue
      elseif last_char == "3" then
        bg_color = "#DBF227"
        -- fg_color = "#000080"  -- dark blue
      else
        bg_color = "#FF69B4" -- default pink
      end

      return bg_color, fg_color
    end

    local bg_color, fg_color = decide_color()

    -- Adding hostname to lualine_x
    table.insert(opts.sections.lualine_x, 1, {
      "hostname",
      color = { fg = fg_color, bg = bg_color, gui = "bold" },
      separator = { left = "", right = "" },
      -- separator = { left = "", right = "" },
      padding = 2,
    })
  end,
}
