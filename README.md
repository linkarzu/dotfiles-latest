# Contents

<!-- toc -->

- [Repo overview](#repo-overview)
- [Some of my YouTube videos](#some-of-my-youtube-videos)
  * [My complete Neovim markdown setup and workflow in 2024](#my-complete-neovim-markdown-setup-and-workflow-in-2024)
  * [Tired of seeing Catppuccin everywhere? Meet the Eldritch theme](#tired-of-seeing-catppuccin-everywhere-meet-the-eldritch-theme)
  * [Neovim or Neovide, what is the difference?](#neovim-or-neovide-what-is-the-difference)
  * [Why I switched from Alacritty to kitty, and how to configure kitty](#why-i-switched-from-alacritty-to-kitty-and-how-to-configure-kitty)
  * [My dotfiles and how to clone them](#my-dotfiles-and-how-to-clone-them)
- [Update symbolic links](#update-symbolic-links)
- [Point your `~/.zshrc` file to the desired repo](#point-your-zshrc-file-to-the-desired-repo)

<!-- tocstop -->

## Repo overview

- This repo is where I keep the dotfiles I'm currently using
- The other repo `https://github.com/linkarzu/dotfiles-public` is referenced in
  my youtube 2024 macos workflow video series
  - `https://youtube.com/playlist?list=PLZWMav2s1MZTanWwNKYvS8qgwl0HBH9J-&si=q6ByPmN8I7SOBKmX`
  - That old repo is no longer maintained, so use this new repo instead

## Some of my YouTube videos

### My complete Neovim markdown setup and workflow in 2024

<div align="left">
    <a href="https://youtu.be/c0cuvzK1SDo">
        <img
          src="https://res.cloudinary.com/daqwsgmx6/image/upload/q_75/v1717456413/youtube/neovim/markdown-setup-2024.avif"
          alt="My complete Neovim markdown setup and workflow in 2024"
          width="600"
        />
    </a>
</div>

### Tired of seeing Catppuccin everywhere? Meet the Eldritch theme

<div align="left">
    <a href="https://youtu.be/wKPaBQ0GaCM">
        <img
          src="https://res.cloudinary.com/daqwsgmx6/image/upload/q_75/v1717456413/youtube/neovim/eldritch-theme.avif"
          alt="Tired of seeing Catppuccin everywhere? Meet the Eldritch theme"
          width="600"
        />
    </a>
</div>

### Neovim or Neovide, what is the difference?

<div align="left">
    <a href="https://youtu.be/cY1KSeIkQCs">
        <img
          src="https://res.cloudinary.com/daqwsgmx6/image/upload/q_75/v1717456413/youtube/neovim/neovim-vs-neovide.avif"
          alt="Neovim or Neovide, what is the difference?"
          width="600"
        />
    </a>
</div>

### Why I switched from Alacritty to kitty, and how to configure kitty

<div align="left">
    <a href="https://youtu.be/MZNvjclifD8">
        <img
          src="https://res.cloudinary.com/daqwsgmx6/image/upload/q_75/v1719362711/youtube/macos/alacritty-to-kitty.avif"
          alt="Why I switched from Alacritty to kitty, and how to configure kitty"
          width="600"
        />
    </a>
</div>

### My dotfiles and how to clone them

- This video may seem old and outdated, and it is, but it's content is still
  relevant

<div align="left">
     <a href="https://youtu.be/XBjfzySpGdE">
         <img
           src="https://res.cloudinary.com/daqwsgmx6/image/upload/v1706358848/youtube/2024-macos-workflow/04-dotfiles-playback"
           alt="04 - What are dotfiles and how to clone them"
           width="600"
         />
     </a>
 </div>

## Update symbolic links

- Commands below will create all the files if they don't yet exist if they do
  exist, it will update them.
- `-n` allows the link to be treated as a normal file if it is a symlink to a
  directory
- `-f` "force" overwrites without warning if it already exists

## Point your `~/.zshrc` file to the desired repo

```bash
ln -snf ~/github/dotfiles-latest/zshrc/zshrc-file.sh ~/.zshrc >/dev/null 2>&1
source ~/.zshrc
```

```bash
ln -snf ~/github/dotfiles-public/zshrc/zshrc-file.sh ~/.zshrc >/dev/null 2>&1
source ~/.zshrc
```

```bash
# This is on the other repo where I keep my ssh config files
ln -snf ~/github/dotfiles/sshconfig-pers ~/.ssh/config >/dev/null 2>&1
```
