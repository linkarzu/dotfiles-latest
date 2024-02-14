# Contents

<!-- toc -->

- [Things to remember](#things-to-remember)
  - [Change value of highlight colors](#change-value-of-highlight-colors)
  - [See messages history](#see-messages-history)
  - [See formatters applied to a file](#see-formatters-applied-to-a-file)
  - [Check the value of options](#check-the-value-of-options)
  - [Check the help command](#check-the-help-command)
  - [Spectre pattern matching](#spectre-pattern-matching)
  - [Working with markdown](#working-with-markdown)
- [Working with marks](#working-with-marks)

<!-- tocstop -->

## Things to remember

### Change value of highlight colors

- I got the answer on this [reddit post](https://www.reddit.com/r/neovim/comments/1alflp1/can_someone_please_help_me_changing_these_colors/)
- Move your cursor to the highlight you want to find out about and run the
  `:Inspect` command, there you will see the colors related to the highlight
- You can confirm using the `:highlight` command, there you can grep for the
  values and see the current hex colors

### See messages history

Use the command `:NoiceHistory`

### See formatters applied to a file

Use the command `:ConformInfo`

### Check the value of options

I wanted to change this option `vim.opt.conceallevel = 1`, but first I wanted
to check its value

- Can check it with the command `:set conceallevel?`

### Check the help command

If I want to check the help for the `conceallevel` option shown above use the
help command

- `:help conceallevel`

### Spectre pattern matching

- `https://github.com/nvim-pack/nvim-spectre`
- Press `ti` to toggle ignore case
- I needed to match:
  - `>/dev/null 2>&1`
- So I used (but didn't work, and don't have time to deal with this right now)
  - `[>]\/dev\/null 2[>]\&1`

### Working with markdown

- `:LazyExtras` is where I enable `lang.markdown`, this includes several plugins
  -  headlines.nvim  markdown-preview.nvim  mason.nvim  nvim-lspconfig
     nvim-treesitter  none-ls.nvim  nvim-lint
  - headlines.nvim is the one that shows my headlines with colors and stuff
- `:LazyExtras` is where I enable `prettier`
  - You can also manage this in the `lazy.lua` file, but now I'll manage them in
    the `lazyvim.json` file instead
  - Prettier is the one that automatically formats my markdown files
    - It removes blank lines
    - Removes blank spaces at the end of a line
    - But also messes up my chirpy tips because it adds
      additional texts

## Working with marks

- While in normal mode, press `m` and then a letter `a-z` will create a mark
  - Lowercase letters (a to z) are for marks local to the current buffer
  - Uppercase letters (A to Z) create global marks that can be jumped to from
    any buffer
- To jump to a mark
  - `'a` - will jump to mark on the first non-blank character
  - \`a - with backtick , jumps to the mark on first character
- To see all the marks use `:marks`
- `:delmarks a` would remove the mark a
- `:delmarks a j k l m z n` removes all the marks specified
