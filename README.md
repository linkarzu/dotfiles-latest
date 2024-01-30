# Youtube video explaining my dotfiles and how to clone them

<div align="center">
    <a href="https://youtu.be/XBjfzySpGdE">
        <img src="https://res.cloudinary.com/daqwsgmx6/image/upload/v1706358848/youtube/2024-macos-workflow/04-dotfiles-playback" alt="04 - What are dotfiles and how to clone them" width="600"/>
    </a>
</div>

# Symbolic links creation

<!-- # https://github.com/linkarzu/dotfiles-public -->

After cloning the repo, I create a symbolic link
that points to my custom vimrc file

- Commands below will create all the files if they don't yet exist
  if they do exist, it will update them.
- `-n` allows the link to be treated as a normal file if it is a
  symlink to a directory
- `-f` "force" overwrites without warning if it already exists

```bash
# Create the symlinks I normally use
# ~/.config dir holds nvim, neofetch, alacritty configs
# If the dir/file that the symlink points to doesnt exist
# it will error out, so I direct them to dev null
mkdir -p ~/.config
ln -snf ~/github/dotfiles-public/vimrc/vimrc-file ~/.vimrc >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/vimrc/vimrc-file ~/github/obsidian_main/.obsidian.vimrc >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/zshrc/zshrc-file.sh ~/.zshrc >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/tmux/tmux.conf.sh ~/.tmux.conf >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/karabiner/mxstbr ~/.config/karabiner >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/neovim/nvim-lazyvim ~/.config/nvim >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/yabai/yabairc ~/.yabairc >/dev/null 2>&1
ln -snf ~/github/dotfiles-public/hammerspoon ~/.hammerspoon >/dev/null 2>&1

# # This is on the other repo where I keep my ssh config files
# I commented this as I don't have give access to this repo to all the hosts
# ln -snf ~/github/dotfiles/sshconfig-pers ~/.ssh/config >/dev/null 2>&1

echo
echo "In case you have obsidian installed, restart obsidian"

# I'm sourcing the ~/.zshrc file in case it was replaced
# using the symlink above
source ~/.zshrc
```
