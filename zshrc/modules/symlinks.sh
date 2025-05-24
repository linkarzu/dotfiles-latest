# ~/.config is used by neovim, alacritty and karabiner
mkdir -p ~/.config
# Alacritty is inside its own dir
mkdir -p ~/.config/alacritty
# Kitty is inside its own dir
mkdir -p ~/.config/kitty/
mkdir -p ~/.config/wezterm/
mkdir -p ~/.config/ghostty
# Creating obsidian directory
# Even if you don't use obsidian, don't remove this dir to avoid warnings
mkdir -p ~/github/obsidian_main
mkdir -p ~/.config/neovide
mkdir -p ~/.config/rio
mkdir -p ~/.config/yazi
mkdir -p ~/.config/btop
mkdir -p ~/.config/fastfetch
mkdir -p ~/.config/sesh

# Create the symlinks I normally use
# ~/.config dir holds nvim, neofetch, alacritty configs
# If the dir/file that the symlink points to doesnt exist, it will error out, so I direct them to dev null
# This will update the symlink even if its pointing to another file
# If the file exists, it will create a backup in the same dir
# echo "1"
create_symlink() {
  local source_path=$1
  local target_path=$2
  local backup_needed=true

  # echo

  # Check if the target is a file and contains the unique identifier
  if [ -f "$target_path" ] && grep -q "UNIQUE_ID=do_not_delete_this_line" "$target_path"; then
    # echo "$target_path is a FILE and contains UNIQUE_ID"
    backup_needed=false
  fi

  # Check if the target is a directory and contains the UNIQUE_ID.sh file with the unique identifier
  if [ -d "$target_path" ] && [ -f "$target_path/UNIQUE_ID.sh" ]; then
    if grep -q "UNIQUE_ID=do_not_delete_this_line" "$target_path/UNIQUE_ID.sh"; then
      # echo "$target_path is a DIRECTORY and contains UNIQUE_ID"
      backup_needed=false
    fi
  fi
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

  # Backup the target if it's not a symlink and backup is needed
  if [ -e "$target_path" ] && [ ! -L "$target_path" ] && [ "$backup_needed" = true ]; then
    local backup_path="${target_path}_backup_$(date +%Y%m%d%H%M%S)"
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
create_symlink ~/github/dotfiles-latest/kitty/kitty.conf ~/.config/kitty/kitty.conf
create_symlink ~/github/dotfiles-latest/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
create_symlink ~/github/dotfiles-latest/yabai/yabairc ~/.yabairc
create_symlink ~/github/dotfiles-latest/.prettierrc.yaml ~/.prettierrc.yaml
create_symlink ~/github/dotfiles-latest/ubersicht/.simplebarrc ~/.simplebarrc
create_symlink ~/github/dotfiles-latest/eligere/.eligere.json ~/.eligere.json
if command -v code &>/dev/null; then
  create_symlink ~/github/dotfiles-latest/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
fi
if command -v lazygit &>/dev/null; then
  create_symlink ~/github/dotfiles-latest/lazygit/config.yml "$HOME/Library/Application Support/lazygit/config.yml"
fi
# create_symlink ~/github/dotfiles-latest/mouseless/config.yaml "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml"

# Creating symlinks for directories
create_symlink ~/github/dotfiles-latest/neovim/neobean/ ~/.config/neobean
create_symlink ~/github/dotfiles-latest/neovim/quarto-nvim-kickstarter/ ~/.config/quarto-nvim-kickstarter
create_symlink ~/github/dotfiles-latest/neovim/kickstart.nvim/ ~/.config/kickstart.nvim
create_symlink ~/github/dotfiles-latest/neovim/lazyvim/ ~/.config/lazyvim
create_symlink ~/github/dotfiles-latest/hammerspoon/ ~/.hammerspoon
create_symlink ~/github/dotfiles-latest/karabiner/mxstbr/ ~/.config/karabiner
create_symlink ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/ ~/.config/sketchybar
create_symlink ~/github/dotfiles-latest/neovide/ ~/.config/neovide
create_symlink ~/github/dotfiles-latest/ghostty/ ~/.config/ghostty
create_symlink ~/github/dotfiles-latest/rio/ ~/.config/rio
create_symlink ~/github/dotfiles-latest/yazi/ ~/.config/yazi
create_symlink ~/github/dotfiles-latest/btop/ ~/.config/btop
create_symlink ~/github/dotfiles-latest/fastfetch/ ~/.config/fastfetch
create_symlink ~/github/dotfiles-latest/sesh ~/.config/sesh

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
