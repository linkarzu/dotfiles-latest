# Filename: ~/github/dotfiles-latest/zshrc/zshrc-macos.sh
#
# macOS-specific zsh configuration.
# Sourced from zshrc-file.sh when `uname -s` is Darwin.
#
# This is intentionally a lean, portable config: everything is guarded by
# `command -v` / file-existence checks and uses `$(brew --prefix)` so it works
# on both Apple Silicon (/opt/homebrew) and Intel (/usr/local) without edits.

# Don't auto-update Homebrew on every `brew` invocation
export HOMEBREW_NO_AUTO_UPDATE="1"

# Open man pages in neovim, if neovim is installed
if command -v nvim &>/dev/null; then
  export MANPAGER='nvim +Man!'
  export MANWIDTH=999
fi

#############################################################################
#                        Colorscheme configuration
#############################################################################
# colorscheme_profile is set in ~/github/dotfiles-latest/colorscheme/colorscheme-vars.sh
~/github/dotfiles-latest/zshrc/colorscheme-set.sh "$colorscheme_profile"

#############################################################################
#                        Homebrew shell completions
#############################################################################
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if command -v brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

#############################################################################
#                        kitty terminfo
#############################################################################
# Ensure xterm-kitty terminfo exists (we use kitty as a terminal)
install_xterm_kitty_terminfo() {
  if ! infocmp xterm-kitty &>/dev/null; then
    echo "xterm-kitty terminfo not found. Installing..."
    local tempfile
    tempfile=$(mktemp)
    if curl -o "$tempfile" https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/kitty.terminfo; then
      tic -x -o ~/.terminfo "$tempfile" &&
        echo "xterm-kitty terminfo installed successfully."
    fi
    rm -f "$tempfile"
  fi
}
install_xterm_kitty_terminfo

#############################################################################
#                        fzf
#############################################################################
# https://github.com/junegunn/fzf
if command -v fzf &>/dev/null; then
  # Key bindings + completion (fzf >= 0.48 ships `fzf --zsh`)
  if fzf --zsh &>/dev/null; then
    source <(fzf --zsh)
  elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
  fi

  # Use :: as the completion trigger instead of the default **
  export FZF_COMPLETION_TRIGGER='::'

  # Preview file content using bat on ctrl-t
  export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi

#############################################################################
#                        starship prompt
#############################################################################
# https://starship.rs
if command -v starship &>/dev/null; then
  type starship_zle-keymap-select >/dev/null ||
    {
      export STARSHIP_CONFIG=$HOME/github/dotfiles-latest/starship-config/active-config.toml
      eval "$(starship init zsh)" >/dev/null 2>&1
    }
fi

#############################################################################
#                        eza (ls replacement)
#############################################################################
# https://github.com/eza-community/eza
if command -v eza &>/dev/null; then
  alias ls='eza'
  alias ll='eza -lhg'
  alias lla='eza -alhg'
  alias tree='eza --tree'
fi

#############################################################################
#                        bat (cat replacement)
#############################################################################
# https://github.com/sharkdp/bat
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never --style=plain'
  alias catt='bat'
  alias cata='bat --show-all --paging=never --style=plain'
fi

#############################################################################
#                        zsh-vi-mode
#############################################################################
# https://github.com/jeffreytse/zsh-vi-mode
if [ -f "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]; then
  source "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

  # Remap escape to `kj`
  ZVM_VI_ESCAPE_BINDKEY=kj
  ZVM_VI_INSERT_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
  ZVM_VI_VISUAL_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
  ZVM_VI_OPPEND_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY

  # Cursor styles per mode
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE

  function zvm_after_lazy_keybindings() {
    zvm_bindkey vicmd 'gh' beginning-of-line
    zvm_bindkey vicmd 'gl' end-of-line
  }

  # zsh-vi-mode overrides the ctrl-r binding; give it back to fzf after init
  zvm_after_init_commands+=('command -v fzf &>/dev/null && source <(fzf --zsh) 2>/dev/null')
fi

#############################################################################
#                        zsh-autosuggestions
#############################################################################
# https://github.com/zsh-users/zsh-autosuggestions  (right arrow to accept)
if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

#############################################################################
#                        zoxide (smarter cd)
#############################################################################
# https://github.com/ajeetdsouza/zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
  alias cdd='z -'
fi

#############################################################################
#                        neovim aliases
#############################################################################
# NVIM_APPNAME points at ~/.config/lazyvim (symlinked to dotfiles-latest/nvim)
alias v='NVIM_APPNAME=lazyvim nvim'
alias vl='NVIM_APPNAME=lazyvim nvim'

#############################################################################
#                        SSH keys
#############################################################################
# Add keys to the agent if the corresponding private key files exist
for _key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa; do
  [ -f "$_key" ] && ssh-add "$_key" >/dev/null 2>&1
done
unset _key

#############################################################################
#                        Local, machine-only overrides
#############################################################################
# Anything host-specific that should NOT live in the public dotfiles
if [ -f "$HOME/.zshrc_local/env-setup.sh" ]; then
  source "$HOME/.zshrc_local/env-setup.sh"
fi
