ensure_dir() {
  if [ -L "$1" ]; then
    return 0
  fi

  mkdir -p "$1"
}

# ~/.config is used by neovim, alacritty and karabiner
ensure_dir ~/.config
# Alacritty is inside its own dir
ensure_dir ~/.config/alacritty
# Kitty is inside its own dir
ensure_dir ~/.config/kitty/
ensure_dir ~/.config/wezterm/
ensure_dir ~/.config/ghostty
# Creating obsidian directory
# Even if you don't use obsidian, don't remove this dir to avoid warnings
ensure_dir ~/github/obsidian_main
ensure_dir ~/.config/neovide
ensure_dir ~/.config/rio
ensure_dir ~/.config/yazi
ensure_dir ~/.config/btop
ensure_dir ~/.config/fastfetch
ensure_dir ~/.config/sesh
ensure_dir ~/.config/eligere
ensure_dir ~/.config/aerospace
ensure_dir ~/.config/skhd

# Create the symlinks I normally use
# ~/.config dir holds nvim, neofetch, alacritty configs
# If the dir/file that the symlink points to doesnt exist, it will error out, so I direct them to dev null
# This will update the symlink even if its pointing to another file
# If the file exists, it will create a backup in the same dir
# echo "1"
create_symlink() {
  local source_path=$1
  local target_path=$2
  local backup_path
  local backup_number=1

  if [ ! -e "$source_path" ] && [ ! -L "$source_path" ]; then
    if [ "${DOTFILES_SYMLINK_VERBOSE:-0}" = "1" ]; then
      echo -e "${boldYellow}Skipping missing source: '$source_path'${noColor}"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$target_path")"

  # echo

  # Check if symlink already exists and points to the correct source
  if [ -L "$target_path" ]; then
    if [ "$(readlink "$target_path")" = "$source_path" ]; then
      # echo "$target_path exists and is correct, no action needed"
      return 0
    else
      echo -e "${boldYellow}'$target_path' is a symlink"
      echo -e "but it points to a different source, updating it${noColor}"
    fi
  fi

  # Preserve every real file or directory before replacing it with a link.
  if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
    backup_path="${target_path}_backup_$(date +%Y%m%d%H%M%S)"
    while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
      backup_path="${target_path}_backup_$(date +%Y%m%d%H%M%S)_$backup_number"
      backup_number=$((backup_number + 1))
    done
    echo -e "${boldYellow}Backing up your existing file '$target_path' to '$backup_path'${noColor}"
    mv "$target_path" "$backup_path"
  fi

  # Create the symlink and print message
  ln -snf "$source_path" "$target_path"
  echo -e "${boldPurple}Created or updated symlink"
  echo -e "${boldGreen}FROM: '$source_path'"
  echo -e "  TO: '$target_path'${noColor}"
}

# Creating symlinks for files
create_symlink ~/github/dotfiles-latest/vimrc/vimrc-file ~/.vimrc
create_symlink ~/github/dotfiles-latest/vimrc/vimrc-file ~/github/obsidian_main/.obsidian.vimrc
create_symlink ~/github/dotfiles-latest/zshrc/zshrc-file.sh ~/.zshrc
create_symlink ~/github/dotfiles-latest/bashrc/bashrc-file.sh ~/.bashrc
create_symlink ~/github/dotfiles-latest/tmux/tmux.conf.sh ~/.tmux.conf
create_symlink ~/github/dotfiles-latest/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
create_symlink ~/github/dotfiles-latest/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
create_symlink ~/github/dotfiles-latest/yabai/yabairc ~/.yabairc
create_symlink ~/github/dotfiles-latest/.prettierrc.yaml ~/.prettierrc.yaml
create_symlink ~/github/dotfiles-latest/ubersicht/.simplebarrc ~/.simplebarrc
create_symlink ~/github/dotfiles-latest/eligere/.eligere.json ~/.eligere.json
create_symlink ~/github/dotfiles-latest/eligere/eligere.toml ~/.config/eligere/.eligere.toml
if command -v code &>/dev/null; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    create_symlink ~/github/dotfiles-latest/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
  else
    create_symlink ~/github/dotfiles-latest/vscode/settings.json "$HOME/.config/Code/User/settings.json"
  fi
fi
if command -v lazygit &>/dev/null; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    create_symlink ~/github/dotfiles-latest/lazygit/config.yml "$HOME/Library/Application Support/lazygit/config.yml"
  else
    create_symlink ~/github/dotfiles-latest/lazygit/config.yml "$HOME/.config/lazygit/config.yml"
  fi
fi
# create_symlink ~/github/dotfiles-latest/mouseless/config.yaml "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml"

# Creating symlinks for directories
# Neovim was reset to a fresh LazyVim starter in dotfiles-latest/nvim.
# Keep the existing shell alias (NVIM_APPNAME=lazyvim nvim) pointed at it,
# and do not recreate the older local Neovim app configs on shell startup.
# create_symlink ~/github/dotfiles-latest/neovim/neobean/ ~/.config/neobean
# create_symlink ~/github/dotfiles-latest/neovim/quarto-nvim-kickstarter/ ~/.config/quarto-nvim-kickstarter
# create_symlink ~/github/dotfiles-latest/neovim/kickstart.nvim/ ~/.config/kickstart.nvim
create_symlink ~/github/dotfiles-latest/nvim ~/.config/nvim
create_symlink ~/.config/nvim ~/.config/lazyvim
create_symlink ~/github/dotfiles-latest/hammerspoon/ ~/.hammerspoon
# create_symlink ~/github/dotfiles-latest/karabiner/mxstbr/ ~/.config/karabiner
create_symlink ~/github/dotfiles-latest/karabiner/ ~/.config/karabiner
create_symlink ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/ ~/.config/sketchybar
create_symlink ~/github/dotfiles-latest/neovide/ ~/.config/neovide
create_symlink ~/github/dotfiles-latest/ghostty/ ~/.config/ghostty
create_symlink ~/github/dotfiles-latest/rio/ ~/.config/rio
create_symlink ~/github/dotfiles-latest/yazi/ ~/.config/yazi
create_symlink ~/github/dotfiles-latest/btop/ ~/.config/btop
create_symlink ~/github/dotfiles-latest/fastfetch/ ~/.config/fastfetch
create_symlink ~/github/dotfiles-latest/sesh ~/.config/sesh
create_symlink ~/github/dotfiles-latest/aerospace ~/.config/aerospace
create_symlink ~/github/dotfiles-latest/kitty ~/.config/kitty
create_symlink ~/github/dotfiles-latest/skhd ~/.config/skhd

# # This is on the other repo where I keep my ssh config files
# I commented this as I don't have access to this repo in all the hosts
# ln -snf ~/github/dotfiles/sshconfig-pers ~/.ssh/config 2>&1 >/dev/null

# # I'm keeping the old manual commands here
# ln -snf ~/github/dotfiles-latest/zshrc/zshrc-file.sh ~/.zshrc >/dev/null 2>&1
# ln -snf ~/github/dotfiles-latest/vimrc/vimrc-file ~/.vimrc >/dev/null 2>&1
# ln -snf ~/github/dotfiles-latest/vimrc/vimrc-file ~/github/obsidian_main/.obsidian.vimrc >/dev/null 2>&1
# ln -snf ~/github/dotfiles-latest/tmux/tmux.conf.sh ~/.tmux.conf >/dev/null 2>&1
# ln -snf ~/github/dotfiles-latest/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml >/dev/null 2>&1
# ln -snf ~/github/dotfiles-latest/yabai/yabairc ~/.yabairc >/dev/null 2>&1
#
# # Below are symlinks that point to directories
# ln -snf ~/github/dotfiles-latest/neovim/neobean ~/.config/nvim >/dev/null 2>&1
# ln -snf ~/github/dotfiles-latest/hammerspoon ~/.hammerspoon >/dev/null 2>&1
# ln -snf ~/github/dotfiles-latest/karabiner/mxstbr ~/.config/karabiner >/dev/null 2>&1
