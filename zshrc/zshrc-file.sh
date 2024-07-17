# Filename: ~/github/dotfiles-latest/zshrc/zshrc-file.sh

# #############################################################################
# Do not delete the `UNIQUE_ID` line below, I use it to backup original files
# so they're not lost when my symlinks are applied
# UNIQUE_ID=do_not_delete_this_line
# #############################################################################

boldGreen="\033[1;32m"
boldYellow="\033[1;33m"
boldRed="\033[1;31m"
boldPurple="\033[1;35m"
boldBlue="\033[1;34m"
noColor="\033[0m"

# Run a clear command right after I log in to any host
clear

# ~/.config is used by neovim, alacritty and karabiner
mkdir -p ~/.config
# Alacritty is inside its own dir
mkdir -p ~/.config/alacritty
# Kitty is inside its own dir
mkdir -p ~/.config/kitty/
# Creating obsidian directory
# Even if you don't use obsidian, don't remove this dir to avoid warnings
mkdir -p ~/github/obsidian_main

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
create_symlink ~/github/dotfiles-latest/yabai/yabairc ~/.yabairc
create_symlink ~/github/dotfiles-latest/.prettierrc.yaml ~/.prettierrc.yaml

# Creating symlinks for directories
create_symlink ~/github/dotfiles-latest/neovim/neobean/ ~/.config/neobean
create_symlink ~/github/dotfiles-latest/neovim/quarto-nvim-kickstarter/ ~/.config/quarto-nvim-kickstarter
create_symlink ~/github/dotfiles-latest/neovim/kickstart.nvim/ ~/.config/kickstart.nvim
create_symlink ~/github/dotfiles-latest/neovim/lazyvim/ ~/.config/lazyvim
create_symlink ~/github/dotfiles-latest/hammerspoon/ ~/.hammerspoon
create_symlink ~/github/dotfiles-latest/karabiner/mxstbr/ ~/.config/karabiner
create_symlink ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/ ~/.config/sketchybar
# Notice I also have the "nvim" directory below and I have it pointing to my
# "neobean" config.
# If I don't do this, my daily note with hyper+t+r won't work
# If you want to open the daily note with a different distro, update the "nvim"
# symlink, for example you can change it from "neobean" to "lazyvim"
create_symlink ~/github/dotfiles-latest/neovim/neobean/ ~/.config/nvim
# create_symlink ~/github/dotfiles-latest/sketchybar/felixkratz ~/.config/sketchybar
# create_symlink ~/github/dotfiles-latest/sketchybar/default ~/.config/sketchybar
# create_symlink ~/github/dotfiles-latest/sketchybar/neutonfoo ~/.config/sketchybar
# echo "finished 1"

# # This is on the other repo where I keep my ssh config files
# I commented this as I don't have access to this repo in all the hosts
# ln -snf ~/github/dotfiles/sshconfig-pers ~/.ssh/config 2>&1 >/dev/null

# I'm keeping the old manual commands here
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

# Autocompletion settings
# https://github.com/Phantas0s/.dotfiles/blob/master/zsh/completion.zsh
# These have to be on the top, I remember I had issues with some autocompletions if not
zmodload zsh/complist
autoload -U compinit
compinit
_comp_options+=(globdots) # With hidden files
# setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST        # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD # Complete from both ends of a word.
# Define completers
zstyle ':completion:*' completer _extensions _complete _approximate
# Use cache for commands using cache
zstyle ':completion:*' use-cache on
# You have to use $HOME, because since in "" it will be treated as a literal string
zstyle ':completion:*' cache-path "$HOME/.zcompcache"
# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true
# Allow you to select in a menu
zstyle ':completion:*' menu select
# Autocomplete options for cd instead of directory stack
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# zstyle ':completion:*:default' list-prompt '%S%M matches%s'
# Colors for files and directory
# zstyle ':completion:*:*:*:*:default' list-colors '${(s.:.)LS_COLORS}'

# Current number of entries Zsh is configured to store in memory (HISTSIZE)
# How many commands Zsh is configured to save to the history file (SAVEHIST)
# echo "HISTSIZE: $HISTSIZE"
# echo "SAVEHIST: $SAVEHIST"
# Store 10,000 entries in the command history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# Check if the history file exists, if not, create it
if [[ ! -f $HISTFILE ]]; then
  touch $HISTFILE
  chmod 600 $HISTFILE
fi
# Append commands to the history file as they are entered
setopt appendhistory
# Record timestamp of each command (helpful for auditing)
setopt extendedhistory
# Share command history data between all sessions
setopt sharehistory
# Incrementally append to the history file, rather than waiting until the shell exits
setopt incappendhistory
# Ignore duplicate commands in a row
setopt histignoredups
# Exclude commands that start with a space
setopt histignorespace
# Custom list of commands to ignore (adjust as needed)
# HISTIGNORE='ls*:bg*:fg*:exit*:ll*'

# Common settings and plugins
alias ll='ls -lh'
alias lla='ls -alh'
alias python='python3'
# Shows the last 30 entries, default is 15
alias history='history -30'

# You can use NVIM_APPNAME=nvim-NAME to maintain multiple configurations.
#
# NVIM_APPNAME is the name of the directory inside ~/.config
# For example, you can install the kickstart configuration
# in ~/.config/nvim-kickstart, the NVIM_APPNAME would be "nvim-kickstart"
#
# In my case, the neovim directories inside ~/.config/ are symlinks that point
# to their respective neovim directories stored in my $my_working_directory
#
# Notice that both "v" and "nvim" start "neobean"
# "vk" opens kickstart and "vl" opens lazyvim
alias v='export NVIM_APPNAME="neobean" && /opt/homebrew/bin/nvim'
alias vq='export NVIM_APPNAME="quarto-nvim-kickstarter" && /opt/homebrew/bin/nvim'
alias vk='export NVIM_APPNAME="kickstart.nvim" && /opt/homebrew/bin/nvim'
alias vl='export NVIM_APPNAME="lazyvim" && /opt/homebrew/bin/nvim'
# I'm also leaving this "nvim" alias, which points to the "nvim" APPNAME, but
# that APPNAME in fact points to my "neobean" config in the symlinks section
# If I don't do this, my daily note doesn't work
#
# If you want to open the daily note with a different distro, update the "nvim"
# symlink in the symlinks section
alias nvim='export NVIM_APPNAME="nvim" && /opt/homebrew/bin/nvim'

# kubernetes, if you need help, just run 'kgp --help' for example
alias k='kubectl'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpo='kubectl get pods -o wide'

# golang aliases
alias coverage='go test -coverprofile=coverage.out && go tool cover -html=coverage.out'

# echo
# echo "2"
# #############################################################################
#                       DISABLE AUTO-PULL SECTION
# #############################################################################
# Instead of directly cloning my repo, to avoid my changes being applied, I
# instead recommend you fork it, and clone that fork to your local machine
# That way, my changes won't affect you.
# If you don't fork, and for example I change my karabiner mappings, from
# opening the terminal with hyper+space+j to hyper+space+b, it will
# change your mappings too
#
# If you don't want to fork, comment the 3 lines below if you don't want to always pull
# my latest changes, otherwise your changes will be overriden by my updates
echo
echo "Pulling latest changes, please wait..."
(cd ~/github/dotfiles-latest && git pull >/dev/null 2>&1) || echo "Failed to pull dotfiles"
# Every time I log into a host I want to pull my github repos, but not cd to that dir
# So running the command above in a subshell
#
# #############################################################################
# echo "finished 2"

# Detect OS
case "$(uname -s)" in
Darwin)
  OS='Mac'
  ;;
Linux)
  OS='Linux'
  ;;
*)
  OS='Other'
  ;;
esac

# macOS-specific configurations
if [ "$OS" = 'Mac' ]; then

  # Set JAVA_HOME to the OpenJDK installation managed by Homebrew
  export JAVA_HOME="/opt/homebrew/opt/openjdk"
  # Add JAVA_HOME/bin to the beginning of the PATH
  export PATH="$JAVA_HOME/bin:$PATH"

  # https://github.com/antlr/antlr4/blob/master/doc/getting-started.md#unix
  # Add antlr-4.13.1-complete.jar to your CLASSPATH
  export CLASSPATH=".:/usr/local/lib/antlr-4.13.1-complete.jar:$CLASSPATH"
  # Create an alias for running ANTLR's TestRig
  alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
  alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.1-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'

  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

  # Add templ to PATH if it is installed
  # templ is installed with
  # go install github.com/a-h/templ/cmd/templ@latest
  if [ -x "$HOME/go/bin/templ" ]; then
    export PATH=$PATH:$HOME/go/bin
  fi

  # sketchybar
  # This will update the brew package count after running a brew upgrade, brew
  # update or brew outdated command
  # Personally I added "list" and "install", and everything that is after but
  # that's just a personal preference.
  # That way sketchybar updates when I run those commands as well
  if command -v sketchybar &>/dev/null; then
    # When the zshrc file is ran, reload sketchybar, in case the theme was
    # switched
    # I disabled this as it was getting refreshed every time I opened the
    # terminal and if I restored a lot of sessions after rebooting it was a mess
    # sketchybar --reload

    # Define a custom 'brew' function to wrap the Homebrew command.
    function brew() {
      # Execute the original Homebrew command with all passed arguments.
      command brew "$@"
      # Check if the command includes "upgrade", "update", or "outdated".
      if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]] || [[ $* =~ "list" ]] || [[ $* =~ "install" ]] || [[ $* =~ "uninstall" ]] || [[ $* =~ "bundle" ]] || [[ $* =~ "doctor" ]] || [[ $* =~ "info" ]] || [[ $* =~ "cleanup" ]]; then
        # If so, notify SketchyBar to trigger a custom action.
        sketchybar --trigger brew_update
      fi
    }
  fi

  # Luaver
  # luaver can be used to install multiple lua and luarocks versions
  # Commands below downloads and uses a specific version
  # my_lua_touse=5.1 && luaver install $my_lua_touse && luaver set-default $my_lua_touse && luaver use $my_lua_touse
  # my_luar_touse=3.11.0 && luaver install-luarocks $my_luar_touse && luaver set-default-luarocks $my_luar_touse && luaver use-luarocks $my_luar_touse
  # luarocks install magick
  # luaver install 5.4.6
  #
  # This is in case luaver was installed through homebrew
  # If the file is not empty, then source it
  [ -s $(brew --prefix)/opt/luaver/bin/luaver ] && . $(brew --prefix)/opt/luaver/bin/luaver
  # This is in case it the repo was cloned with the following command
  # git clone https://github.com/DhavalKapil/luaver.git ~/.luaver
  # If the file is not empty, then source it
  [ -s ~/.luaver/luaver ] && . ~/.luaver/luaver
  # Line below won't work with zsh, there's no zsh completions I guess
  # [ -s ~/.luaver/completions/luaver.bash ] && . ~/.luaver/completions/luaver.bash

  # Starship
  # https://starship.rs/config/#prompt
  if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG=$HOME/github/dotfiles-latest/starship-config/starship.toml
    eval "$(starship init zsh)" >/dev/null 2>&1
  fi

  # Brew autocompletion settings
  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
  # -v makes command display a description of how the shell would
  # invoke the command, so you're checking if the command exists and is executable.
  if command -v brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

    autoload -Uz compinit
    compinit
  fi

  # ls replacement
  # exa is unmaintained, so now using eza
  # https://github.com/ogham/exa
  # https://github.com/eza-community/eza
  if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -lhg'
    alias lla='eza -alhg'
    alias tree='eza --tree'
  fi

  # Bat -> Cat with wings
  # https://github.com/sharkdp/bat
  if command -v bat &>/dev/null; then
    # --style=plain - removes line numbers and got modifications
    # --paging=never - doesnt pipe it through less
    alias cat='bat --paging=never --style=plain'
    alias catt='bat'
    alias cata='bat --show-all --paging=never'
  fi

  # Initialize fzf if installed
  # https://github.com/junegunn/fzf
  # Useful commands
  # ctrl+r - command history
  # ctrl+t - search for files
  # ssh ::<tab><name> - shows you list of hosts in case don't remember exact name
  # kill -9 ::<tab><name> - find and kill a process
  # telnet ::<TAB>
  if [ -f ~/.fzf.zsh ]; then

    # After installing fzf with brew, you have to run the install script
    # echo -e "y\ny\nn" | /opt/homebrew/opt/fzf/install

    source ~/.fzf.zsh

    # Preview file content using bat
    export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"

    # Use :: as the trigger sequence instead of the default **
    export FZF_COMPLETION_TRIGGER='::'
  fi

  # vi(vim) mode plugin for ZSH
  # https://github.com/jeffreytse/zsh-vi-mode
  # Insert mode to type and edit text
  # Normal mode to use vim commands
  # tets {really} long (command) using a { lot } of symbols {page} and {abc} and other ones [find] () "test page" {'command 2'}
  if [ -f "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]; then
    source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
    # Following 4 lines modify the escape key to `kj`
    ZVM_VI_ESCAPE_BINDKEY=kj
    ZVM_VI_INSERT_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    ZVM_VI_VISUAL_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    ZVM_VI_OPPEND_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY

    function zvm_after_lazy_keybindings() {
      # Remap to go to the beginning of the line
      zvm_bindkey vicmd 'gh' beginning-of-line
      # Remap to go to the end of the line
      zvm_bindkey vicmd 'gl' end-of-line
    }

    # Source .fzf.zsh so that the ctrl+r bindkey is given back fzf
    zvm_after_init_commands+=('[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh')
  fi

  # https://github.com/zsh-users/zsh-autosuggestions
  # Right arrow to accept suggestion
  if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

  # Changed from z.lua to zoxide, as it's more maintaned
  # smarter cd command, it remembers which directories you use most
  # frequently, so you can "jump" to them in just a few keystrokes.
  # https://github.com/ajeetdsouza/zoxide
  # https://github.com/skywind3000/z.lua
  if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"

    alias cd='z'
    # Alias below is same as 'cd -', takes to the previous directory
    alias cdd='z -'

    #Since I migrated from z.lua, I can import my data
    # zoxide import --from=z "$HOME/.zlua" --merge

    # Useful commands
    # z foo<SPACE><TAB>  # show interactive completions
  fi

  # Add MySQL client to PATH, if it exists
  if [ -d "/opt/homebrew/opt/mysql-client/bin" ]; then
    export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
  fi

  # Source Google Cloud SDK configurations, if Homebrew and the SDK are installed
  if command -v brew &>/dev/null; then
    if [ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]; then
      source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    fi
    if [ -f "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc" ]; then
      source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
    fi
  fi

  # Initialize kubernetes kubectl completion if kubectl is installed
  # https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#enable-shell-autocompletion
  if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
  fi

  # Check if chruby is installed
  # Source chruby scripts if they exist
  # Working instructions to install on macos can be found on the jekyll site
  # https://jekyllrb.com/docs/installation/macos/
  if [ -f "$(brew --prefix)/opt/chruby/share/chruby/chruby.sh" ]; then
    source "$(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
    source "$(brew --prefix)/opt/chruby/share/chruby/auto.sh"
    # Set default Ruby version using chruby
    # Replace 'ruby-3.1.3' with the version you have or want to use
    # You can also put a conditional check here if you want
    chruby ruby-3.1.3
  fi

fi

# Linux (Debian)-specific configurations
if [ "$OS" = 'Linux' ]; then
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
fi
