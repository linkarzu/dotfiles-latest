# ~/.config is used by neovim, alacritty and karabiner
# Alacritty, Kitty, etc are inside their own dir
# Creating obsidian directory
# Even if you don't use obsidian, don't remove this dir to avoid warnings
# NOTE: Only call mkdir for dirs that are missing, this runs on every shell
# start and each mkdir is a separate process
for dir in ~/.config ~/.config/alacritty ~/.config/kitty ~/.config/wezterm \
  ~/.config/ghostty ~/github/obsidian_main ~/.config/neovide ~/.config/rio \
  ~/.config/yazi ~/.config/btop ~/.config/fastfetch ~/.config/sesh \
  ~/.config/eligere ~/.config/aerospace ~/.config/skhd ~/.config/emacs; do
  [[ -d $dir ]] || mkdir -p "$dir"
done
unset dir

# Create the symlinks I normally use
# ~/.config dir holds nvim, neofetch, alacritty configs
# If the dir/file that the symlink points to doesnt exist, it will error out, so I direct them to dev null
# This will update the symlink even if its pointing to another file
# If the file exists, it will create a backup in the same dir
# echo "1"
zmodload -F zsh/stat b:zstat
create_symlink() {
  local source_path=$1
  local target_path=$2
  local backup_needed=true
  local current_link

  # Fast path, check if symlink already exists and points to the correct
  # source. zstat is a zsh builtin, so this doesn't fork readlink or grep,
  # which matters because this runs for every symlink on every shell start
  if [[ -L $target_path ]]; then
    zstat -A current_link +link -- "$target_path"
    if [[ $current_link == "$source_path" ]]; then
      # echo "$target_path exists and is correct, no action needed"
      return 0
    fi
    echo -e "${boldYellow}'$target_path' is a symlink"
    echo -e "but it points to a different source, updating it${noColor}"
  fi

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
create_symlink ~/github/dotfiles-latest/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
create_symlink ~/github/dotfiles-latest/yabai/yabairc ~/.yabairc
create_symlink ~/github/dotfiles-latest/.prettierrc.yaml ~/.prettierrc.yaml
create_symlink ~/github/dotfiles-latest/ubersicht/.simplebarrc ~/.simplebarrc
create_symlink ~/github/dotfiles-latest/eligere/.eligere.json ~/.eligere.json
create_symlink ~/github/dotfiles-latest/eligere/eligere.toml ~/.config/eligere/.eligere.toml
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
create_symlink ~/github/dotfiles-latest/opencode ~/.config/opencode
create_symlink ~/github/dotfiles-latest/hex ~/.config/hex
create_symlink ~/github/dotfiles-latest/skhd ~/.config/skhd
create_symlink ~/github/dotfiles-latest/emacs ~/.config/emacs

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
