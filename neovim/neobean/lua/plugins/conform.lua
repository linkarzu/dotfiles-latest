-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/conform.lua
--
-- https://github.com/stevearc/conform.nvim

-- Auto-format when focus is lost or I leave the buffer
-- Useful if on skitty-notes or a regular buffer and switch somewhere else the
-- formatting doesn't stay all messed up
-- I found this autocmd example in the readme
-- https://github.com/stevearc/conform.nvim/blob/master/README.md#setup
-- "FocusLost" used when switching from skitty-notes
-- "BufLeave" is used when switching between 2 buffers
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  callback = function(args)
    local buf = args.buf or vim.api.nvim_get_current_buf()
    -- Don't format mini.files buffers
    -- tinymist panics when it receives a minifiles:// URI during formatting
    if vim.bo[buf].filetype == "minifiles" then
      return
    end
    if vim.api.nvim_buf_get_name(buf):match("^minifiles://") then
      return
    end
    -- Only format if the current mode is normal mode
    -- Only format if autoformat is enabled for the current buffer (if
    -- autoformat disabled globally the buffers inherits it, see :LazyFormatInfo)
    if LazyVim.format.enabled(buf) and vim.fn.mode() == "n" then
      -- Add a small delay to the formatting so it doesn’t interfere with
      -- CopilotChat’s or grug-far buffer initialization, this helps me to not
      -- get errors when using the "BufLeave" event above, if not using
      -- "BufLeave" the delay is not needed
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
          require("conform").format({ bufnr = buf })
        end
      end, 100)
    end
  end,
})

return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters = {
      ["prettypst"] = {
        prepend_args = { "--use-configuration" },
      },
      ["typstyle"] = {
        prepend_args = { "--wrap-text" },
      },
      ["codeblock_blankline"] = {
        command = "perl",
        args = {
          "-0777",
          "-pe",
          -- Add 1 blank line right after the opening fence, and 1 blank line
          -- right before the closing fence
          [[s/^(\s*```[^\n]*)\n(?!\n)/$1\n\n/gm; s/(?<!\n)\n(?=^\s*```\s*$)/\n\n/gm;]],
        },
        stdin = true,
      },
      ["codeblock_remove_opening_blank"] = {
        command = "perl",
        args = {
          "-0777",
          "-pe",
          [[
my @lines = split(/\n/, $_, -1);
my $in = 0;
my $drop_next_blank = 0;
my @out;

for my $line (@lines) {
  if (!$in) {
    if ($line =~ /^\s*```/) {
      $in = 1;
      $drop_next_blank = 1;
      push @out, $line;
      next;
    }
    push @out, $line;
    next;
  }

  if ($line =~ /^\s*```\s*$/) {
    # Remove ONE blank line right above the closing fence (only if it exists)
    if (@out && $out[-1] =~ /^\s*$/) {
      pop @out;
    }
    $in = 0;
    $drop_next_blank = 0;
    push @out, $line;
    next;
  }

  # Remove ONE blank line right after the opening fence (only if it exists)
  if ($drop_next_blank && $line =~ /^\s*$/) {
    $drop_next_blank = 0;
    next;
  }

  $drop_next_blank = 0;
  push @out, $line;
}

$_ = join("\n", @out);
]],
        },
        stdin = true,
      },
    },
    formatters_by_ft = {
      -- I was having issues formatting .templ files, all the lines were aligned
      -- to the left.
      -- When I ran :ConformInfo I noticed that 2 formatters showed up:
      -- "LSP: html, templ"
      -- But none showed as `ready` This fixed that issue and now templ files
      -- are formatted correctly and :ConformInfo shows:
      -- "LSP: html, templ"
      -- "templ ready (templ) /Users/linkarzu/.local/share/neobean/mason/bin/templ"
      templ = { "templ" },
      -- Not sure why I couldn't make ruff work, so I'll use ruff_format instead
      -- it didn't work even if I added the pyproject.toml in the project or
      -- root of my dots, I was getting the error [LSP][ruff] timeout
      python = { "ruff_format" },
      -- php = { nil },

      -- sqeeze_blanks is a conform formatter that removes extra blank lines. So
      -- below, first the typstyle formatter is ran, then the sqeeze_blanks one
      --
      -- codeblock_blankline adds a single blank line right after the opening
      -- triple backticks in code blocks (example: ```bash), so the content starts
      -- separated from the fence for better readability
      -- typst = { "typstyle", "squeeze_blanks", "codeblock_blankline", lsp_format = "never" },
      typst = { "typstyle", "squeeze_blanks", "codeblock_remove_opening_blank", lsp_format = "never" },
      -- typst = { "typstyle", lsp_format = "prefer" },
      -- typst = { "prettypst" },
    },
  },
}
