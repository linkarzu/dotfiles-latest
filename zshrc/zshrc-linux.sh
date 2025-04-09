# Add Debian-specific configurations here
# For example, you can add z.lua config for Linux here, if not installed will install them

# Using xterm-kitty as in macOS on my Debian servers is a nightmare
# If I hit backspace I see extra characters, if I type its all buggy, testing
# if this will fix it
export TERM=xterm-256color

alias ls='ls --color=auto'

echo "Updating packages, please wait (wont upgrade)..."
sudo apt-get update >/dev/null 2>&1

# Initialize Starship, if installed, otherwise install it
# Extract the last digit of $HOST
last_digit="${HOST: -1}"
# Determine the Starship config file to use
case $last_digit in
1)
  starship_file="starship1.toml"
  ;;
2)
  starship_file="starship2.toml"
  ;;
3)
  starship_file="starship3.toml"
  ;;
*)
  starship_file="starship4.toml"
  ;;
esac

install_this_package="yes"
if command -v starship &>/dev/null; then
  # This is what applies the specific profile
  export STARSHIP_CONFIG=$HOME/github/dotfiles-latest/starship-config/$starship_file >/dev/null 2>&1
  eval "$(starship init zsh)" >/dev/null 2>&1
else
  if [ "$install_this_package" != "no" ]; then
    echo
    echo "Installing starship, please wait..."
    # -y at the end answers 'yes' to any prompts
    curl -sS https://starship.rs/install.sh | sh -s - -y 2>&1 >/dev/null
    # Verify starship installation
    if ! command -v starship >/dev/null 2>&1; then
      echo -e "${boldRed}Warning: Failed to install Starship. Check this manually${noColor}"
      # sleep 1
    else
      # After installing, initialize it
      eval "$(starship init zsh)"
      # This is what applies the specific profile
      export STARSHIP_CONFIG=$HOME/github/dotfiles-latest/starship-config/$starship_file
      echo "Starship installed successfully."
    fi
  fi
fi

# Initialize z.lua, if it is installed
# If not installed, this will install lua and then z.lua
install_this_package="no"
if command -v $HOME/github/z.lua/z.lua &>/dev/null; then
  eval "$(lua $HOME/github/z.lua/z.lua --init zsh enhanced once)"
else
  if [ "$install_this_package" != "no" ]; then
    # First we need to install Lua
    # Search for the latest version of Lua and extract the package name
    echo
    echo "Installing lua, please wait..."
    LUA_PACKAGE=$(apt search lua | grep -o 'lua[0-9]\+\.[0-9]\+/stable' | sort -Vr | head -n 1 | cut -d'/' -f1)
    # Check if a package was found
    if [ -z "$LUA_PACKAGE" ]; then
      echo
      echo -e "${boldGreen}No Lua package found. Skipping z.lua installation...${noColor}"
      # sleep 1
    else
      # sleep 1
      sudo apt-get install -y $LUA_PACKAGE 2>&1 >/dev/null
      # Verify if Lua was installed successfully
      if ! command -v lua >/dev/null 2>&1; then
        echo -e "${boldRed}Warning: Failed to install Lua. Check this manually.${noColor}"
        # sleep 1
      else
      fi
    fi

    # After installing Lua, I need to install z.lua from github
    echo
    if [ ! -d "$HOME/github/z.lua" ]; then
      mkdir -p $HOME/github
      cd $HOME/github
      git clone https://github.com/skywind3000/z.lua.git 2>&1 >/dev/null
    fi

    # verify if the z.lua github repo was cloned successfully
    if [ ! -d "$HOME/github/z.lua" ]; then
      echo -e "${boldgreen}warning: failed to clone the repository. skipping the z.lua configuration....${nocolor}"
      # sleep 1
    else
      echo "successfully cloned the z.lua repository."
      # After installing, initialize it
      eval "$(lua $HOME/github/z.lua/z.lua --init zsh enhanced once)"
      echo "$LUA_PACKAGE installed successfully."
    fi
  fi
fi

# Source zsh-autosuggestions if file exists
install_this_package="no"
if [ -f "$HOME/github/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source $HOME/github/zsh-autosuggestions/zsh-autosuggestions.zsh
else
  if [ "$install_this_package" != "no" ]; then
    echo
    echo "Installing zsh-autosuggestions, please wait..."
    # Download github repo
    mkdir -p $HOME/github
    cd $HOME/github
    git clone https://github.com/zsh-users/zsh-autosuggestions 2>&1 >/dev/null
    # Verify if the repo was cloned successfully
    if [ ! -d "$HOME/github/zsh-autosuggestions" ]; then
      echo
      echo -e "${boldRed}Warning: Failed to clone the zsh-autosuggestions repository. Check this manually${noColor}"
      # sleep 1
    else
      # After installing, initialize it
      source $HOME/github/zsh-autosuggestions/zsh-autosuggestions.zsh
      echo "Successfully installed zsh-autosuggestions"
    fi
  fi
fi

# Initialize zsh-vi-mode, if it is installed
install_this_package="no"
if [ -d "$HOME/github/zsh-vi-mode" ]; then
  source $HOME/github/zsh-vi-mode/zsh-vi-mode.plugin.zsh
  # This modifies the escape key
  ZVM_VI_ESCAPE_BINDKEY=kj
  ZVM_VI_INSERT_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
  ZVM_VI_VISUAL_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
  ZVM_VI_OPPEND_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
  # Source .fzf.zsh so that the ctrl+r bindkey is given back fzf
  zvm_after_init_commands+=('[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh')
else
  if [ "$install_this_package" != "no" ]; then
    echo
    echo "Installing zsh-vi-mode, please wait..."
    # Download zsh-vi-mode from github
    mkdir -p $HOME/github
    cd $HOME/github
    git clone https://github.com/jeffreytse/zsh-vi-mode.git 2>&1 >/dev/null
    # Verify if the zsh-vi-mode GitHub repo was cloned successfully
    if [ ! -d "$HOME/github/zsh-vi-mode" ]; then
      echo
      echo -e "${boldRed}Warning: Failed to clone the zsh-vi-mode repository. Check this manually.${noColor}"
      # sleep 1
    else
      # After installing, initialize it
      source $HOME/github/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      # This modifies the escape key
      ZVM_VI_ESCAPE_BINDKEY=kj
      ZVM_VI_INSERT_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
      ZVM_VI_VISUAL_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
      ZVM_VI_OPPEND_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
      # Source .fzf.zsh so that the ctrl+r bindkey is given back fzf
      zvm_after_init_commands+=('[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh')
      echo "Successfully installed zsh-vi-mode"
    fi
  fi
fi

# Initialize neofetch, if it is installed
if command -v neofetch &>/dev/null; then
  # leave blank space before the command
  echo
  neofetch
fi

# Initialize fzf if installed
install_this_package="yes"
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
else
  if [ "$install_this_package" != "no" ]; then
    echo
    echo "Installing fzf, please wait..."
    # Download fzf from GitHub if it's not installed
    mkdir -p $HOME/github
    cd $HOME/github
    git clone --depth 1 https://github.com/junegunn/fzf.git 2>&1 >/dev/null
    # Verify if the fzf GitHub repo was cloned successfully
    if [ ! -d "$HOME/github/fzf" ]; then
      echo -e "${boldRed}Warning: Failed to clone the fzf repository. Check this manually.${noColor}"
    else
      echo "Successfully cloned the fzf repository."
      # Install fzf, this will answer `y`, `y`, and `n` to the questions asked
      echo -e "y\ny\nn" | $HOME/github/fzf/install 2>&1 >/dev/null
      # After installing, initialize it
      source ~/.fzf.zsh
      echo "Successfully installed fzf"
    fi
  fi
fi

cd ~

# Check if the Meslo Nerd Font is already installed
install_this_package="no"
if [ "$install_this_package" != "no" ]; then
  if ! fc-list | grep -qi "Meslo"; then
    echo
    echo "Installing Meslo Nerd Fonts..."

    # Download the font archive
    curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz 2>&1 >/dev/null

    # Ensure the fonts directory exists and extract the fonts
    mkdir -p ~/.local/share/fonts
    tar -xvf Meslo.tar.xz -C ~/.local/share/fonts 2>&1 >/dev/null
    rm Meslo.tar.xz

    # Refresh the font cache
    fc-cache -fv 2>&1 >/dev/null

    echo "Meslo Nerd Fonts installed."
  fi
fi

# Check if Neovim is already installed, otherwise install it
install_this_package="no"
if ! command -v nvim &>/dev/null; then
  if [ "$install_this_package" != "no" ]; then
    echo
    echo "Installing neovim, please wait..."
    # Install latest version of neovim
    # Debian repos have a really old version, so had to go this route
    # switched to wget as was having issues when downloading with curl
    cd ~
    wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage 2>&1 >/dev/null
    # curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    # After downloading it, you have to make it executable to be able to extract it
    chmod u+x nvim.appimage
    # I'll extract the executable and expose it globally
    ./nvim.appimage --appimage-extract 2>&1 >/dev/null
    sudo mv squashfs-root /
    sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
    rm nvim.appimage
    # Remove any cached files that may exist from a previous config
    echo "removing backup files.."
    mv ~/.local/share/nvim{,.bak} >/dev/null 2>&1
    mv ~/.local/state/nvim{,.bak} >/dev/null 2>&1
    mv ~/.cache/nvim{,.bak} >/dev/null 2>&1
    echo "Downloaded neovim"

    # These below ones are neovim dependencies
    # Check and install lazygit if not installed
    if ! command -v lazygit &>/dev/null; then
      cd ~
      echo "Installing lazygit..."
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
      wget -O lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" 2>&1 >/dev/null
      tar xf lazygit.tar.gz lazygit
      sudo install lazygit /usr/local/bin
      rm -rf lazygit
      rm lazygit.tar.gz
      echo "Downloaded lazygit"
    fi

    # Check and install the C compiler (build-essential) if not installed
    if ! gcc --version &>/dev/null; then
      echo "Installing C compiler (build-essential) for nvim-treesitter..."
      sudo apt install build-essential -y 2>&1 >/dev/null
      echo "Installed C compiler"
    fi

    # Check and install ripgrep if not installed
    if ! command -v rg &>/dev/null; then
      echo "Installing ripgrep..."
      sudo apt-get install ripgrep -y 2>&1 >/dev/null
      echo "Installed ripgrep"
    fi

    # Check and install fd-find if not installed
    if ! command -v fdfind &>/dev/null; then
      echo "Installing fd-find..."
      sudo apt-get install fd-find -y 2>&1 >/dev/null
      echo "Installed fd_find"
    fi

    # Check and install fuse if not installed
    if ! command -v fusermount &>/dev/null; then
      echo "Installing fuse..."
      sudo apt install fuse -y 2>&1 >/dev/null
      echo "Installed fuse"
    fi
  fi
fi

# Initialize kubernetes kubectl completion if kubectl is installed
# https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#enable-shell-autocompletion
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi
