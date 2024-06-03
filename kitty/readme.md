# Contents

<!-- toc -->

- [Install kitty](#install-kitty)
- [See themes](#see-themes)
- [Configure themes](#configure-themes)

<!-- tocstop -->

## Install kitty

-The reason I'm trying kitty out, is to be able to see images in my terminal,
I've been using obsidian for that, but I'm so used to typing in neovim that I
don't like typing in obsidian anymore

```bash
brew install --cask kitty
```

- Press `fn+ctrl+shift+f2` in kitty to open its fully commented sample config
  file in your text editor

## See themes

- The documentation tells you how to change the themes
  [link here](https://sw.kovidgoyal.net/kitty/kittens/themes/)

```bash
kitten themes
```

- When I run this command, I cannot apply the themes or exit out of there, so I
  have to close the tmux window

## Configure themes

- I'll clone the themes repo to one of my local folders and delete the .git
  directory

```bash
mkdir -p ~/github/dotfiles-latest/kitty/themes/
git clone --depth 1 https://github.com/kovidgoyal/kitty-themes.git ~/github/dotfiles-latest/kitty/themes/
rm -rf ~/github/dotfiles-latest/kitty/themes/.git/
rm -rf ~/github/dotfiles-latest/kitty/themes/.github/
```

- Then just include the file in my kitty.conf file and the theme gets applied
