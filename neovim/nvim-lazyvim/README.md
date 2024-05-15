# Contents

<!-- toc -->

- [Things to remember](#things-to-remember)
  - [Surround](#surround)
  - [Syntax highlighting (treesitter)](#syntax-highlighting-treesitter)
  - [Change value of highlight colors](#change-value-of-highlight-colors)
  - [See messages history](#see-messages-history)
  - [See formatters applied to a file](#see-formatters-applied-to-a-file)
  - [Check the value of options](#check-the-value-of-options)
  - [Check the help command](#check-the-help-command)
  - [Spectre pattern matching](#spectre-pattern-matching)
  - [Working with markdown](#working-with-markdown)
    - [markdownlint config](#markdownlint-config)
- [Fix Mason warnings](#fix-mason-warnings)
- [Working with marks](#working-with-marks)

<!-- tocstop -->

## Things to remember

### Increment decrement selection

- This uses
  [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- The default lazyvim keymaps are
  - `<c-space>` (control+space) - to increment the selection
  - `<bs>` (backspace) - to decrease the selection

### Surround

- Replace a surrounding
  - Let's say I have this "surrounded text"
  - And I want to change it with 'surrounded text'
  - Place the cursor before the first "
  - Then press `gsrn"'`
    - goto, surround, replace, next, current surrounding, new surrounding
  - Test below
  - "surrounded text"
- Add **bold** as surrounding
  - First **select the text** in visual mode
  - Then press `2gsa*`
- Remove a surrounding surround
  - If we have 'this surrounded text'
    - Place cursor anywhere inside the surrounding and remove it with `gsd'`
  - If we **have this bold surround**
    - Place cursor anywhere inside the surrounding and remove it with `gsd*.`

### Syntax highlighting (treesitter)

- SQL wasn't showing colors in my codeblocks when editing .md files, it's
  because the `treesitter` language was not installed, so added the
  `treesitter.lua` file and added it there
- `go` files had same "issue", so added `go` to `treesitter` and that fixed it
- Use `checkhealth` to see which ones are installed

### Change value of highlight colors

- I got the answer on this
  [reddit post](https://www.reddit.com/r/neovim/comments/1alflp1/can_someone_please_help_me_changing_these_colors/)
- Move your cursor to the highlight you want to find out about and run the
  `:Inspect` command, there you will see the colors related to the highlight
- You can confirm using the `:highlight` command, there you can grep for the
  values and see the current hex colors

### noice.nvim

- This is a plugin created by folke, "Highly experimental plugin that completely
  replaces the UI for messages, cmdline and the popupmenu"
- Plugin that shows you little popups on the top right corner with messsages

#### See messages history

- Use the command `:NoiceHistory`
- There's a default lazyvim keymap `<leader>snh`

#### Dismiss All

- If you open neovim on an old outdated machine, you will get hundreds of nocice
  messages on the screen, sometimes occuppying the entire screen and you won't
  be able to read
- `<leader>snd` clears them all

### See formatters applied to a file

Use the command `:ConformInfo`

### Check the value of options

I wanted to change this option `vim.opt.conceallevel = 1`, but first I wanted to
check its value

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
  -  headlines.nvim  markdown-preview.nvim  mason.nvim  nvim-lspconfig 
    nvim-treesitter  none-ls.nvim  nvim-lint
  - headlines.nvim is the one that shows my headlines with colors and stuff
- `:LazyExtras` is where I enable `prettier`
  - You can also manage this in the `lazy.lua` file, but now I'll manage them in
    the `lazyvim.json` file instead
  - Prettier is the one that automatically formats my markdown files
    - It removes blank lines
    - Removes blank spaces at the end of a line
    - But also messes up my chirpy tips because it adds additional texts
- I like following markdown guidelines, so I don't like my lines to be longer
  than 80 characters, I like to enable wrapping for them

#### markdownlint config

- This is the plugin that shows me markdown warnings when the line length is
  exceeded, or headings are not properly used for example
- To modify the warning settings, copy the following file
  `~/github/dotfiles-latest/neovim/nvim-lazyvim/.markdownlint.yaml`
- To each dir in which you want the settings to be applied, for example, I
  copied it to my `github/obsidian_main` and `github/linkarzu.github.io` dir.
- I copied it to `~/github` but the changes were never applied, not sure why

## Fix Mason warnings

- You should not install neovim and all it's dependencies on a linux servers
  this is due to security reasons, but if you still want to do it keep reading
  - In `:MasonLog` I was getting these errors
  - "Installation failed for Package(name=json-lsp) error=spawn: npm failed with
    exit code - and signal -. npm is not executable"
  - `npm` is node package manager, first check if you have it installed with
    - `npm --version`
  - If not installed, install it, `nodejs` includes `npm` as part of its
    installation
  - I later realized that `unzip` is needed as well, so installing it
  - I later realized that `python3-venv` is also needed, so adding it

```bash
sudo apt update
sudo apt install nodejs unzip python3-venv
```

- Then I `reopened` neovim, and the error in `:MasonLog` changed to
- "Installation failed for Package(name=stylua) error=spawn: unzip failed with
  exit code - and signal -. unzip is not executable"
  - `unzip` is not installed, so that was fixed by installing it
- Then I was getting this error in the logs
  - "Installation failed for Package(name=ruff-lsp) error=spawn: python3 failed
    with exit code 1 and signal 0."
  - I opened `:Mason` and tried to install `ruff-lsp` there with `i`
  - It showed me the full log

```bash
Creating virtual environment…
The virtual environment was not created successfully because ensurepip is not
available.  On Debian/Ubuntu systems, you need to install the python3-venv
package using the following command.

    apt install python3.11-venv

You may need to use sudo with that command.  After installing the python3-venv
package, recreate your virtual environment.

Failing command: /home/krishna/.local/share/nvim/mason/packages/ruff-lsp/venv/bin/python3

spawn: python3 failed with exit code 1 and signal 0.
```

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

## Replacements

### Increase markdown headings

- I have several `.md` documents that do not follow markdown guidelines
- There are some old ones that have more than one H1 heading in them, so when I
  open one of those old documents, I want to add one more `#` to each heading
- The command below does this only for:
  - Lines that have a newline `above` AND `below`
  - Lines that have a space after the `##` to avoid `#!/bin/bash`

```bash
# Leaving a test shebang here
#!/bin/bash

# This asks for a confirmation so you can quickly confirm if it works or not
# Just press `n` to NOT replace them
:g/\(^$\n\s*#\+\s.*\n^$\)/ .+1 s/^#\+\s/#&/c

# Once you're certain the command above works, remove the `c` at the end so it replaces all
#
# After using this command, go over your file because there might be bash
# comments with a newline above and below them, so remove the double `##`
:g/\(^$\n\s*#\+\s.*\n^$\)/ .+1 s/^#\+\s/#&/
```

- This other command doesn't care if there are newlines above and below
- It will go over all the lines with a # and a space after
  - So it will ignore `#!/bin/bash`

```bash
:%s/^\s*#\+\s/#&/gc
```

### Reduce markdown headings

- This decreases the markdown heading levels throughout the whole file
  - If ### turns it into ##
  - If #### turns it into ###
  - If ##### turns it into ####
  - If ###### turns it into #####

```bash
# With confirmation
:g/^\s*#\{2,}\s/ s/^#\(#\+\s.*\)/\1/c

# Without confirmation
:g/^\s*#\{2,}\s/ s/^#\(#\+\s.*\)/\1/
```

## Providers

### Python 3 provider

- When running the `:healtcheck` command, I used to see these warnings under
  they python 3 provider

```bash
provider: health#provider#check

Python 3 provider (optional) ~
- WARNING No Python executable found that can `import neovim`. Using the first available executable for diagnostics.
- WARNING Could not load Python 3:
  /opt/homebrew/bin/python3 does not have the "neovim" module.
  /opt/homebrew/bin/python3.12 does not have the "neovim" module.
  python3.11 not found in search path or not executable.
  python3.10 not found in search path or not executable.
  python3.9 not found in search path or not executable.
  python3.8 not found in search path or not executable.
  python3.7 not found in search path or not executable.
  python not found in search path or not executable.
  - ADVICE:
    - See :help |provider-python| for more information.
    - You may disable this provider (and warning) by adding `let g:loaded_python3_provider = 0` to your init.vim
- Executable: Not found
```

- So I ran `:help provider-python` which showed me this
  - In the documentation you can move around "tags" with `shift+k` that takes
    you to the `|sections|`

```bash
To use Python plugins, you need the "pynvim" module. Run |:checkhealth| to see
if you already have it (some package managers install the module with Nvim
itself).

For Python 3 plugins:
1. Make sure Python 3.4+ is available in your $PATH.
2. Install the module (try "python" if "python3" is missing): >bash
   python3 -m pip install --user --upgrade pynvim

The pip `--upgrade` flag ensures that you get the latest version even if
a previous version was already installed.

See also |python-virtualenv|.
```

- To fix this

```bash
# check the installed Python version, mine was 3.12, so Im good
python3 --version

# Create a virtual environment for Neovim
python3 -m venv ~/.venvs/neovim

# Activate the virtual environment
source ~/.venvs/neovim/bin/activate

# nstall the pynvim module within the virtual environment
python3 -m pip install --upgrade pynvim

# Then configure Neovim to use the virtual environment
# I added the following to my lazy.lua file
# -- Set the python3_host_prog variable
# vim.g.python3_host_prog = "~/.venvs/neovim/bin/python"
#
# Right before the `require("lazy").setup({` line

# Deactivate the virtual environment
# This command deactivates the virtual environment in the current terminal session,
# so you won't see the virtual environment name in your starship prompt anymore.
# However, Neovim will still use the Python executable and packages from the virtual
# environment because we have configured the `python3_host_prog` variable to point to
# the Python executable within the virtual environment.
# Deactivating the virtual environment only affects the current terminal session and
# doesn't impact Neovim's ability to use the virtual environment for its Python support.
deactivate
```

- After this, the python 3 provider shows this in `healtcheck`

```bash
Python 3 provider (optional) ~
- Using: g:python3_host_prog = "~/.venvs/neovim/bin/python"
- Executable: /Users/linkarzu/.venvs/neovim/bin/python
- Python version: 3.12.3
- pynvim version: 0.5.0
- OK Latest pynvim is installed.
```

## Plugins stopped working

### Reinstall markdown-preview.nvim

- This plugin just stopped working, all I see when I try to run a preview was an
  error `Node. js v21.7.3` and nothing else.
- I updated all my packages, fixed errors in the `checkhealth` section, but
  nothing worked
- Reinstalling the plugin fixed it, here's how:
  - Open `:Lazy` I normally do with `<leader>l`
  - Find the plugin, and hit the lowercase `x` when next to it
  - Then I just pressed uppercase `C` to check for updates
  - Then I pressed `I` to install, and it installed it again
- That solved the issue

## End of file
