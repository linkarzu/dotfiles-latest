# dotfiles-latest/neovim/neobean

<a href="https://dotfyle.com/linkarzu/dotfiles-latest-neovim-neobean">
  <img
    src="https://dotfyle.com/linkarzu/dotfiles-latest-neovim-neobean/badges/plugins?style=flat"
    alt="plugins"
  />
</a>
<br>
<a href="https://dotfyle.com/linkarzu/dotfiles-latest-neovim-neobean">
  <img src="https://dotfyle.com/linkarzu/dotfiles-latest-neovim-neobean/badges/leaderkey?style=flat"
    alt="leaderkey"
  />
</a>
<br>
<a href="https://dotfyle.com/linkarzu/dotfiles-latest-neovim-neobean">
  <img src="https://dotfyle.com/linkarzu/dotfiles-latest-neovim-neobean/badges/plugin-manager?style=flat"
    alt="plugin-manager"
  />
</a>

## Contents

### Table of contents

<!-- toc -->

- [Install Instructions](#install-instructions)
  * [Check if you have an alias for nvim](#check-if-you-have-an-alias-for-nvim)
  * [Install pre-requisites](#install-pre-requisites)
  * [Clone my repo](#clone-my-repo)
  * [How do I start using Neovim?](#how-do-i-start-using-neovim)
- [Plugins](#plugins)
  * [colorscheme](#colorscheme)
  * [completion](#completion)
  * [diagnostics](#diagnostics)
  * [editing-support](#editing-support)
  * [file-explorer](#file-explorer)
  * [formatting](#formatting)
  * [fuzzy-finder](#fuzzy-finder)
  * [icon](#icon)
  * [indent](#indent)
  * [keybinding](#keybinding)
  * [lsp](#lsp)
  * [lsp-installer](#lsp-installer)
  * [markdown-and-latex](#markdown-and-latex)
  * [marks](#marks)
  * [media](#media)
  * [motion](#motion)
  * [plugin-manager](#plugin-manager)
  * [preconfigured](#preconfigured)
  * [search](#search)
  * [session](#session)
  * [snippet](#snippet)
  * [startup](#startup)
  * [statusline](#statusline)
  * [syntax](#syntax)
  * [utility](#utility)
  * [workflow](#workflow)
- [Language Servers](#language-servers)
- [Things to remember](#things-to-remember)
  * [grug-far.nvim replacements](#grug-farnvim-replacements)
  * [Paste issues](#paste-issues)
  * [markdown-preview.nvim image size](#markdown-previewnvim-image-size)
  * [Plugin that enables vio and vao](#plugin-that-enables-vio-and-vao)
  * [Record macro or new macro](#record-macro-or-new-macro)
  * [Increment decrement selection](#increment-decrement-selection)
  * [Surround](#surround)
  * [Syntax highlighting (treesitter)](#syntax-highlighting-treesitter)
  * [Change value of highlight colors](#change-value-of-highlight-colors)
  * [noice.nvim](#noicenvim)
    + [See messages history](#see-messages-history)
    + [Dismiss All](#dismiss-all)
  * [See formatters applied to a file](#see-formatters-applied-to-a-file)
  * [Check the value of options](#check-the-value-of-options)
  * [Check the help command](#check-the-help-command)
  * [Spectre pattern matching](#spectre-pattern-matching)
  * [Working with markdown](#working-with-markdown)
    + [markdownlint config](#markdownlint-config)
- [Fix Mason warnings](#fix-mason-warnings)
- [Working with marks](#working-with-marks)
- [Replacements](#replacements)
  * [Increase markdown headings](#increase-markdown-headings)
  * [Reduce markdown headings](#reduce-markdown-headings)
- [Providers](#providers)
  * [Python 3 provider](#python-3-provider)
- [Plugins stopped working](#plugins-stopped-working)
  * [Reinstall markdown-preview.nvim](#reinstall-markdown-previewnvim)
- [image.nvim](#imagenvim)
  * [Install image.nvim](#install-imagenvim)
  * [Install luarocks (optional)](#install-luarocks-optional)

<!-- tocstop -->

## Install Instructions

### Check if you have an alias for nvim

- Before continuing, make sure the `nvim` command isn't aliased (personally, I
  did have it aliased in the past)
- If **not** aliased, notice that nvim points directly to the neovim executable

```bash
which nvim
```

```bash
❯❯❯❯ which nvim
/opt/homebrew/bin/nvim
```

- If aliased something similar to this is shown:

```bash
❯❯❯❯ which nvim
nvim: aliased to export NVIM_APPNAME="nvim" && /opt/homebrew/bin/nvim
```

- If you have your command aliased, when you see `nvim` below in the guide, you
  will probably have to run nvim using the full path as seen below

```bash
# instead of this:
NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim

# You would run this:
NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean /opt/homebrew/bin/nvim
```

- You can create an alias in your `.bashrc` or `.zshrc` file, just add this

```bash
alias neobean='NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim'
```

- Then to run this config, just run `neobean`

### Install pre-requisites

> Install requires Neovim 0.9+. Always review the code before installing a
> configuration.

- My neovim version is 0.10.2

```bash
nvim -v
```

```bash
linkarzu.@.[24/12/17]
~/Library/Mobile Documents/com~apple~CloudDocs/spice
kubernetes
❯❯❯❯ nvim -v
NVIM v0.10.2
Build type: Release
LuaJIT 2.1.1732813678
Run "nvim -V1 -v" for more info
```

- To `view and paste images` you need to install a few things

```bash
brew install imagemagick
brew install pkg-config
brew install lua
brew install pngpaste
```

- I have a detailed video on how I set up neovim for images, similar to the way
  you work with images in [Obsidian](https://obsidian.md/)
- It's quite long (that's what she said) but I cover everything in detail
- **Click on the image below to watch the video:**

<div align="left">
    <a href="https://youtu.be/0O3kqGwNzTI">
        <img
          src="../../assets/img/imgs/neovim-view-paste-images.avif"
          alt="View and paste images in Neovim like in Obsidian"
          width="600"
        />
    </a>
</div>

![Image](./../../assets/img/imgs/250107-voyager.avif)

### Clone my repo

- This repo contains all my dotfiles, keep reading if you want to just download
  my neobean dir

```sh
git clone git@github.com:linkarzu/dotfiles-latest ~/.config/linkarzu/dotfiles-latest
```

Open Neovim with this config:

```sh
NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim
```

- If you don't want to clone my entire repo, but instead just download my
  neobean folder, I have a video in which I cover this
- **Click on the image below to watch the video:**

<div align="left">
    <a href="https://youtu.be/xN1hdY1cc3E">
        <img
          src="../../assets/img/imgs/neovim-install-multiple-distros.avif"
          alt="Download and test multiple Neovim distros and configurations | Without affecting your current config"
          width="600"
        />
    </a>
</div>

### How do I start using Neovim?

- Start by taking notes in neovim, I mean editing markdown files
- If you use Obsidian, try switching the editing of your notes to Neovim
- I have a video in which I go over my markdown workflow, so I highly recommend
  you check it out:
  - [My complete Neovim markdown setup and workflow in 2024](https://youtu.be/c0cuvzK1SDo)
- If you experience any errors or have any issues, let me know down in the
  comments and me or others can try to help
- **Click on the image below to watch the video:**

<div align="left">
    <a href="https://youtu.be/c0cuvzK1SDo">
        <img
          src="../../assets/img/imgs/241217-thux-markdown-setup-2024.avif"
          alt="My complete Neovim markdown setup and workflow in 2024"
          width="600"
        />
    </a>
</div>

## Plugins

### colorscheme

- I use a custom colorscheme based off of
  [eldritch-theme/eldritch.nvim](https://dotfyle.com/plugins/eldritch-theme/eldritch.nvim)
- This colorscheme is already part of my config, so once you download and run my
  config you should get it applied automatically
- **Click on the image below to watch the video:**

<div align="left">
    <a href="https://youtu.be/WIATPUK33XU">
        <img
          src="../../assets/img/imgs/241217-thux-dark-eldritch.avif"
          alt="Dark Eldritch colorscheme variant in Neovim"
          width="600"
        />
    </a>
</div>

- I also have a video in which I go over a colorscheme selector I created that
  changes my colors not only in Neovim, but also in SketchyBar, my terminal,
  tmux, starship and more
- **Click on the image below to watch the video:**

<div align="left">
    <a href="https://youtu.be/SBU2YRv02Mc">
        <img
          src="../../assets/img/imgs/241217-thux-colorscheme-selector.avif"
          alt="Colorscheme selector to change the colors in kitty, tmux, starship, neovim, sketchybar and more"
          width="600"
        />
    </a>
</div>

### completion

- [hrsh7th/nvim-cmp](https://dotfyle.com/plugins/hrsh7th/nvim-cmp)

### diagnostics

- [folke/trouble.nvim](https://dotfyle.com/plugins/folke/trouble.nvim)

### editing-support

- [nvim-treesitter/nvim-treesitter-context](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter-context)
- [okuuva/auto-save.nvim](https://dotfyle.com/plugins/okuuva/auto-save.nvim)

### file-explorer

- [echasnovski/mini.files](https://dotfyle.com/plugins/echasnovski/mini.files)
- [nvim-neo-tree/neo-tree.nvim](https://dotfyle.com/plugins/nvim-neo-tree/neo-tree.nvim)
- [stevearc/oil.nvim](https://dotfyle.com/plugins/stevearc/oil.nvim)

### formatting

- [stevearc/conform.nvim](https://dotfyle.com/plugins/stevearc/conform.nvim)

### fuzzy-finder

- [Rics-Dev/project-explorer.nvim](https://dotfyle.com/plugins/Rics-Dev/project-explorer.nvim)
- [nvim-telescope/telescope.nvim](https://dotfyle.com/plugins/nvim-telescope/telescope.nvim)

### icon

- [nvim-tree/nvim-web-devicons](https://dotfyle.com/plugins/nvim-tree/nvim-web-devicons)

### indent

- [echasnovski/mini.indentscope](https://dotfyle.com/plugins/echasnovski/mini.indentscope)

### keybinding

- [folke/which-key.nvim](https://dotfyle.com/plugins/folke/which-key.nvim)

### lsp

- [jose-elias-alvarez/typescript.nvim](https://dotfyle.com/plugins/jose-elias-alvarez/typescript.nvim)
- [simrat39/symbols-outline.nvim](https://dotfyle.com/plugins/simrat39/symbols-outline.nvim)
- [neovim/nvim-lspconfig](https://dotfyle.com/plugins/neovim/nvim-lspconfig)
- [mfussenegger/nvim-lint](https://dotfyle.com/plugins/mfussenegger/nvim-lint)
- [hedyhli/outline.nvim](https://dotfyle.com/plugins/hedyhli/outline.nvim)

### lsp-installer

- [williamboman/mason.nvim](https://dotfyle.com/plugins/williamboman/mason.nvim)

### markdown-and-latex

- [iamcco/markdown-preview.nvim](https://dotfyle.com/plugins/iamcco/markdown-preview.nvim)
- [MeanderingProgrammer/render-markdown.nvim](https://dotfyle.com/plugins/MeanderingProgrammer/render-markdown.nvim)

### marks

- [chentoast/marks.nvim](https://dotfyle.com/plugins/chentoast/marks.nvim)
- [ThePrimeagen/harpoon](https://dotfyle.com/plugins/ThePrimeagen/harpoon)

### media

- [HakonHarnes/img-clip.nvim](https://dotfyle.com/plugins/HakonHarnes/img-clip.nvim)
- [3rd/image.nvim](https://dotfyle.com/plugins/3rd/image.nvim)

### motion

- [ggandor/leap.nvim](https://dotfyle.com/plugins/ggandor/leap.nvim)

### plugin-manager

- [folke/lazy.nvim](https://dotfyle.com/plugins/folke/lazy.nvim)

### preconfigured

- [LazyVim/LazyVim](https://dotfyle.com/plugins/LazyVim/LazyVim)

### search

- [nvim-telescope/telescope-frecency.nvim](https://dotfyle.com/plugins/nvim-telescope/telescope-frecency.nvim)

### session

- [folke/persistence.nvim](https://dotfyle.com/plugins/folke/persistence.nvim)

### snippet

- [L3MON4D3/LuaSnip](https://dotfyle.com/plugins/L3MON4D3/LuaSnip)

### startup

- [nvimdev/dashboard-nvim](https://dotfyle.com/plugins/nvimdev/dashboard-nvim)

### statusline

- [nvim-lualine/lualine.nvim](https://dotfyle.com/plugins/nvim-lualine/lualine.nvim)

### syntax

- [nvim-treesitter/nvim-treesitter](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter)
- [echasnovski/mini.surround](https://dotfyle.com/plugins/echasnovski/mini.surround)

### utility

- [leath-dub/snipe.nvim](https://dotfyle.com/plugins/leath-dub/snipe.nvim)
- [folke/noice.nvim](https://dotfyle.com/plugins/folke/noice.nvim)

### workflow

- [ramilito/kubectl.nvim](https://dotfyle.com/plugins/ramilito/kubectl.nvim)

## Language Servers

- html
- intelephense
- marksman
- phpactor
- zk

## Things to remember

### grug-far.nvim replacements

- Remember to use the `--multiline` flag
- Make sure to include `spaces` in case a blank line has a space, otherwise you
  won't be able to match

```regex
<!-- markdownlint-disable -->
<!-- prettier-ignore-start -->

<!-- tip=green, info=blue, warning=yellow, danger=red -->

> - This helps me to keep creating content and sharing it
\- \[Share a tip here\]\(https:\/\/ko\-fi\.com\/linkarzu\)\{:target="\\_blank"\}
\{: .prompt-tip \}

<!-- prettier-ignore-end -->
<!-- markdownlint-restore -->
```

- For this to work, just make sure to add a newline after `from` after pasting
  in the search bar for grug-far

```regex
## How do you manage your passwords\?

- I've tried many different password managers in the past, I've switched from
  `LastPass` to `Dashlane` and finally ended up in `1password`
- You want to find out why\? More info in my article:
  - \[How I use 1password to keep all my accounts safe\]\(https:\/\/chirpy.home.linkarzu.com\/posts\/1password\/1password\/\)\{:target="\\_blank"\}

\[!\[Image\]\(..\/..\/assets\/img\/imgs\/250124-1password-banner.avif\)\{: width="300" \}\]\(https:\/\/www.dpbolvw.net\/click-101327218-15917064\)\{:target="\\_blank"\}

```

### Paste issues

- Let's say I have these paragraphs in neovim, I want to replace the middle one
  with text from outside neovim, text coming from my browser

```bash
Laborum aute consectetur sit reprehenderit.
Laborum aute consectetur sit reprehenderit.

# h1 Heading 8-)
## h2 Heading
### h3 Heading
#### h4 Heading
##### h5 Heading
###### h6 Heading

Minim tempor ullamco do eu pariatur minim.
Minim tempor ullamco do eu pariatur minim.
```

- Notice that paragraph 2 has a newline right below it
- I copy the text from my browser with cmd+c (macos)
- I select the 2 lines in the middle with visual mode
- I paste that text inside neovim with cmd+v and it pastes it, but it removes
  the newline right after the 2nd paragraph, and it sucks
- If instead of pasting the text with cmd+v, I paste it with shift+p
  `it pastes it correctly`

### markdown-preview.nvim image size

- This is how you can specify the size of the image when you look at it on the
  browser
  - Found in
    [custom examples](https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#custom-examples)
- `![2024-06-04-at-18-49-47.avif](0604-proyecto-final-img/2024-06-04-at-18-49-47.avif =300x)`
- But prettier autoformats them and breaks them into separate lines, have to
  figure out how to stop that

### Plugin that enables vio and vao

- I use `vio` A LOT when working with markdown files to select all the text in a
  codeblock, but it suddenly stopped working
- By looking at the changelog, I realized that the plugin that does this is
  `mini.ai`, it can be enabled via `:LazyExtras`, but I added manually instead

### Record macro or new macro

- I want to convert all the words inside '' to lowercase, as they're in
  uppercase
- Without macros I position myself on the first line, press `vi'u`
  - select inside ' and then lowercase
- I want to do this for 13 lines, so I'll create a macro:
- Position your cursor on the first line where you want to start the macro
- Press `qa` to start recording the macro in registar `a`
- Perform the desired actions:
  - Press `vi'u`
  - Press `j` to move to the next line
  - Press `q` to stop recording the macro
- To execute the macro on the next 12 lines:
  - Press `12@a`

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
  - Place the cursor anywhere inside the " "
  - Then press `gsr"'`
    - goto, surround, replace, current surrounding, new surrounding
- Add **bold** as surrounding
  - First **select the text** in visual mode
  - Then press `2gsa*`
- Remove a surround
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
  `~/github/dotfiles-latest/neovim/neobean/.markdownlint.yaml`
- To each dir in which you want the settings to be applied, for example, I
  copied it to my `github/obsidian_main` and `github/linkarzu.github.io` dir.
- Copy it to the working directory, you can see it with `:pwd`

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

## image.nvim

### Install image.nvim

- I have an M1 mac running macos 14 (Sonoma)

```bash
sysctl -a | grep cpu.brand
sw_vers
```

```bash
linkarzu.@.mini~/github
[24/05/23 14:33:36] kubernetes-admin@kubernetes ()
❯ sysctl -a | grep cpu.brand
machdep.cpu.brand_string: Apple M1

linkarzu.@.mini~/github
[24/05/23 14:33:40] kubernetes-admin@kubernetes ()
❯ sw_vers
ProductName:            macOS
ProductVersion:         14.4.1
BuildVersion:           23E224
```

- My neovim version is 0.10

```bash
nvim -v
```

```bash
test comment
linkarzu.@.mini~/.luarocks/share/lua/5.1/magick/wand via 🌙 v5.4.6
[24/05/23 14:19:03] kubernetes-admin@kubernetes ()
❯ nvim -v
NVIM v0.10.0
Build type: Release
LuaJIT 2.1.1713773202
Run "nvim -V1 -v" for more info
```

- I'm using the kitty terminal, version 0.34.1
  - kitty is required, unless you want to use `ueberzugpp`

```bash
kitty --version
```

```bash
linkarzu.@.mini~
[24/05/23 09:53:24] kubernetes-admin@kubernetes ()
❯ kitty --version
kitty 0.34.1 created by Kovid Goyal
```

- I'm using zsh

```bash
echo $0
```

```bash
linkarzu.@.mini~
[24/05/23 09:53:28] kubernetes-admin@kubernetes ()
❯ echo $0
-zsh
```

- I installed the ImageMagick system package
- `https://github.com/ImageMagick/ImageMagick/blob/main/Install-mac.txt`

```bash
brew install imagemagick
```

-To confirm that ImageMagick is installed

```bash
identify -version
```

```bash
linkarzu.@.mini~
[24/05/23 11:49:33] kubernetes-admin@kubernetes ()
❯ identify -version
Version: ImageMagick 7.1.1-32 Q16-HDRI aarch64 22207 https://imagemagick.org
Copyright: (C) 1999 ImageMagick Studio LLC
License: https://imagemagick.org/script/license.php
Features: Cipher DPC HDRI Modules OpenMP(5.0)
Delegates (built-in): bzlib fontconfig freetype gslib heic jng jp2 jpeg jxl lcms lqr ltdl lzma openexr png ps raw tiff webp xml zlib zstd
Compiler: gcc (4.2)
```

- Review the imagemagick package information, pay close attention to the
  `Dependencies` section
  - Notice that I'm missing the `pkg-config` one (`x` next to the name)
- Figuring this out took me a day, so pay close attention to it
- I'll install this missing dependency below

```bash
brew info imagemagick
```

```bash
linkarzu.@.mini/opt/homebrew/lib on  master via 🌙 via  v22.2.0
[24/05/23 18:49:25] kubernetes-admin@kubernetes ()
❯ brew info imagemagick
==> imagemagick: stable 7.1.1-32 (bottled), HEAD
Tools and libraries to manipulate images in many formats
https://imagemagick.org/index.php
Installed
/opt/homebrew/Cellar/imagemagick/7.1.1-32 (809 files, 32.3MB) *
  Poured from bottle using the formulae.brew.sh API on 2024-05-22 at 16:22:20
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/i/imagemagick.rb
License: ImageMagick
==> Dependencies
Build: pkg-config ✘
Required: freetype ✔, ghostscript ✔, jpeg-turbo ✔, libheif ✔, liblqr ✔, libpng ✔, libraw ✔, libtiff ✔, libtool ✔, little-cms2 ✔, openexr ✔, openjpeg ✔, webp ✔, xz ✔, libomp ✔
==> Options
--HEAD
        Install HEAD version
==> Analytics
install: 71,186 (30 days), 224,277 (90 days), 885,106 (365 days)
install-on-request: 65,697 (30 days), 208,218 (90 days), 816,570 (365 days)
build-error: 19 (30 days)
```

- I'm installing the missing dependency shown above
  - `https://github.com/3rd/image.nvim/issues/18#issuecomment-1837218766`

```bash
brew install pkg-config
```

- If you don't install this dependency above, you will get the error

```bash
msg_show image.nvim: magick rock not found, please install it and restart your editor.
Error: "/Users/linkarzu/.luarocks/share/lua/5.1/magick/wand/lib.lua:220: Failed to load ImageMagick (MagickWand)"
```

- You need lua, notice the version I have installed
  - `brew install lua`

```bash
lua -v
```

```bash
linkarzu.@.mini~
[24/05/24 12:03:10] kubernetes-admin@kubernetes ()
❯ lua -v
Lua 5.4.6  Copyright (C) 1994-2023 Lua.org, PUC-Rio
```

- Then just create the plugin file for `image.nvim`, which in my case is
  `plugins/image-nvim.lua`
  - This will install `luarocks` via `luarocks.nvim`, and the `magick`
    dependency needed to view images
  - If you do this, you don't need to install luarocks locally as shown in the
    section below
- `luarocks.nvim` is a Neovim plugin designed to streamline the installation of
  luarocks packages directly within Neovim. It simplifies the process of
  managing Lua dependencies, ensuring a hassle-free experience for Neovim users
  - `https://github.com/vhyrro/luarocks.nvim`

---

- If using tmux add this to the tmux.conf file

```bash
# https://github.com/3rd/image.nvim/?tab=readme-ov-file#tmux
# This is needed by the image.nvim plugin
set -gq allow-passthrough on
# This is related to the `tmux_show_only_in_active_window = true,` config in
# image.nvim
set -g visual-activity off
```

### Install luarocks (optional)

- You ONLY need to install `luarocks` and `magick` if you're not doing it via
  the `plugins/image-nvim.lua` neovim plugin
- You need to install `luarocks`, to then install `magick`
- `https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-macOS`

---

- This section is if you want to install lua through `luaver`
- I'm not sure if lua 5.1 is needed or if it works with 5.4, so I installed
  `luaver` to manage multiple lua and luarocks versions and I'm using 5.1
  - Notice that this install lua, luarocks and magick
  - If you already have lua installed through brew, uninstall it first
    - `brew uninstall lua`

```bash
	# Commands below downloads and uses a specific version
	my_lua_touse=5.1 && luaver install $my_lua_touse && luaver set-default $my_lua_touse && luaver use $my_lua_touse
	my_luar_touse=3.11.0 && luaver install-luarocks $my_luar_touse && luaver set-default-luarocks $my_luar_touse && luaver use-luarocks $my_luar_touse
	luarocks install magick
	luaver install 5.4.6
```

---

- This section below is if you DONT want to use `luaver` but use lua directly
  through brew
  - First make sure lua is installed
  - `brew install lua`
- Then install luarocks

```bash
brew install luarocks
```

- Here's my luarocks version

```bash
luarocks --version
```

```bash
linkarzu.@.mini~
[24/05/23 12:04:33] kubernetes-admin@kubernetes ()
❯ luarocks --version
/opt/homebrew/bin/luarocks 3.11.0
LuaRocks main command-line interface
```

- By just typing `luarocks` it shows me the configuration and also the lua
  version
  - I have lua 5.4 installed

```bash
luarocks
```

```bash
Configuration:
   Lua:
      Version    : 5.4
      LUA        : /opt/homebrew/opt/lua/bin/lua5.4 (ok)
      LUA_INCDIR : /opt/homebrew/opt/lua/include/lua5.4 (ok)
      LUA_LIBDIR : /opt/homebrew/opt/lua/lib (ok)

   Configuration files:
      System  : /opt/homebrew/etc/luarocks/config-5.4.lua (ok)
      User    : /Users/linkarzu/.luarocks/config-5.4.lua (not found)

   Rocks trees in use:
      /Users/linkarzu/.luarocks ("user")
      /opt/homebrew ("system")
```

- Now I'll install magick
- Remember that I'm using lua 5.4, but when looking at the magick
  [requirements](https://luarocks.org/modules/leafo/magick)
  - I noticed a dependency for lua 5.1
  - So I assume that's why the version 5.1 is specified below
  - Tried installing without that version but it does not install it

```bash
luarocks --local --lua-version=5.1 install magick
```

```bash
linkarzu.@.mini~
[24/05/23 12:09:35] kubernetes-admin@kubernetes ()
❯ luarocks --local --lua-version=5.1 install magick
Installing https://luarocks.org/magick-1.6.0-1.src.rock

magick 1.6.0-1 depends on lua 5.1 (5.1-1 provided by VM: success)
No existing manifest. Attempting to rebuild...
magick 1.6.0-1 is now installed in /Users/linkarzu/.luarocks (license: MIT)
```

- Notice that magick is installed

```bash
luarocks --lua-version=5.1 list
```

```bash
linkarzu.@.mini~/github/obsidian_main on  main [!] took 2s
[24/05/23 14:04:56] kubernetes-admin@kubernetes ()
❯ luarocks --lua-version=5.1 list

Rocks installed for Lua 5.1
---------------------------

magick
   1.6.0-1 (installed) - /Users/linkarzu/.luarocks/lib/luarocks/rocks-5.1
```

- If you want to use the local luarocks installation instead of the
  `luarocks.nvim` one
- Uncomment the lines at the top of the `plugins/image-nvim.lua` file
- Just make sure they point to the right path
