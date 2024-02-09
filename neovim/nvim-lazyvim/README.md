# Things to remember

## Change value of highlight colors

- I got the answer on this [reddit post](https://www.reddit.com/r/neovim/comments/1alflp1/can_someone_please_help_me_changing_these_colors/)
- Move your cursor to the highlight you want to find out about and run the
  `:Inspect` command, there you will see the colors related to the highlight
- You can confirm using the `:highlight` command, there you can grep for the
  values and see the current hex colors

## See messages history

Use the command `:NoiceHistory`

## See formatters applied to a file

Use the command `:ConformInfo`

## Check the value of options

I wanted to change this option `vim.opt.conceallevel = 1`, but first I wanted
to check its value

- Can check it with the command `:set conceallevel?`

## Check the help command

If I want to check the help for the `conceallevel` option shown above use the
help command

- `:help conceallevel`

## Spectre pattern matching

- I needed to match:
  - `>/dev/null 2>&1`
- So I used (but didn't work, and don't have time to deal with this right now)
  - `[>]\/dev\/null 2[>]\&1`
