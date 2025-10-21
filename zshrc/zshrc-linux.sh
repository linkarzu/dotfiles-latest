# ------------------------
# Arch Linux-specific zsh config
# ------------------------

# Log prefix
LOG_PREFIX="[ZSHRC]"

# TERM ayarı
export TERM=xterm-256color
echo "$LOG_PREFIX TERM set to $TERM"

# Aliases
alias ls='ls --color=auto'
echo "$LOG_PREFIX Alias ls set"

# ------------------------
# Update system packages (yay)
# ------------------------
echo "$LOG_PREFIX Updating system packages..."
if command -v yay &>/dev/null; then
    yay -Sy --noconfirm >/dev/null 2>&1
    echo "$LOG_PREFIX yay packages updated"
else
    echo "$LOG_PREFIX yay not found, please install yay manually"
fi

# ------------------------
# Starship prompt
# ------------------------
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
    echo "$LOG_PREFIX Starship initialized using $STARSHIP_CONFIG"
else
    echo "$LOG_PREFIX Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    eval "$(starship init zsh)"
    echo "$LOG_PREFIX Starship installed and initialized"
fi

# ------------------------
# Zsh Custom Plugins Directory
# ------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ------------------------
# zsh-autosuggestions
# ------------------------
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "$LOG_PREFIX Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
echo "$LOG_PREFIX zsh-autosuggestions loaded"

# ------------------------
# zsh-syntax-highlighting
# ------------------------
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "$LOG_PREFIX Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
echo "$LOG_PREFIX zsh-syntax-highlighting loaded"

# ------------------------
# z.lua (optional)
# ------------------------
if command -v lua &>/dev/null && [ -f "$HOME/github/z.lua/z.lua" ]; then
    eval "$(lua $HOME/github/z.lua/z.lua --init zsh enhanced once)"
    echo "$LOG_PREFIX z.lua loaded"
fi

# ------------------------
# fzf
# ------------------------
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
    echo "$LOG_PREFIX fzf loaded"
else
    echo "$LOG_PREFIX Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/github/fzf"
    echo "y\ny\nn" | "$HOME/github/fzf/install"
    source ~/.fzf.zsh
    echo "$LOG_PREFIX fzf installed and loaded"
fi

# ------------------------
# neofetch
# ------------------------
if command -v neofetch &>/dev/null; then
    neofetch
    echo "$LOG_PREFIX neofetch executed"
fi

# ------------------------
# zsh-vi-mode (optional)
# ------------------------
if [ -d "$HOME/github/zsh-vi-mode" ]; then
    source "$HOME/github/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
    ZVM_VI_ESCAPE_BINDKEY=kj
    ZVM_VI_INSERT_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    ZVM_VI_VISUAL_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    ZVM_VI_OPPEND_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    echo "$LOG_PREFIX zsh-vi-mode loaded with escape bind 'kj'"
fi

# ------------------------
# kubectl autocompletion
# ------------------------
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
    echo "$LOG_PREFIX kubectl autocompletion enabled"
fi
