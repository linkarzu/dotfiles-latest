#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
canonical_repo_dir="$HOME/github/dotfiles-latest"

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2
}

die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --skip-packages    Do not install Homebrew packages (brew bundle).
  --skip-nvim-sync   Do not run LazyVim plugin sync.
  --no-chsh          Do not change the login shell to zsh.
  -h, --help         Show this help.
USAGE
}

skip_packages=0
skip_nvim_sync=0
change_shell=1

while (($#)); do
  case "$1" in
    --skip-packages)
      skip_packages=1
      ;;
    --skip-nvim-sync)
      skip_nvim_sync=1
      ;;
    --no-chsh)
      change_shell=0
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This bootstrap is for macOS. Detected: $(uname -s)"
fi

ensure_canonical_repo_path() {
  mkdir -p "$HOME/github"

  if [[ "$repo_dir" == "$canonical_repo_dir" ]]; then
    return
  fi

  if [[ -e "$canonical_repo_dir" || -L "$canonical_repo_dir" ]]; then
    die "$canonical_repo_dir already exists, but this script is running from $repo_dir. Run the installer from $canonical_repo_dir."
  fi

  ln -s "$repo_dir" "$canonical_repo_dir"
  log "Linked $canonical_repo_dir -> $repo_dir"
}

ensure_command_line_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    return
  fi

  log "Installing Xcode Command Line Tools (needed for git and the compiler toolchain)."
  xcode-select --install || true

  warn "A macOS dialog may have opened to install the Command Line Tools."
  warn "Finish that install, then re-run ./install.sh."
  die "Command Line Tools are required before continuing."
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return
  fi

  log "Installing Homebrew."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon installs to /opt/homebrew, Intel to /usr/local.
  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done

  command -v brew >/dev/null 2>&1 || die "Homebrew installation failed; 'brew' not found on PATH."
}

install_packages() {
  if ((skip_packages)); then
    log "Skipping package installation."
    return
  fi

  log "Updating Homebrew."
  brew update

  log "Installing packages from brew/Brewfile."
  brew bundle --file="$repo_dir/brew/Brewfile"
}

setup_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    warn "rustup is not installed; skipping Rust toolchain setup."
    return
  fi

  if ! rustup default >/dev/null 2>&1; then
    rustup default stable
  fi

  rustup component add rustfmt clippy rust-analyzer >/dev/null 2>&1 || true
}

setup_npm_prefix() {
  if ! command -v npm >/dev/null 2>&1; then
    return
  fi

  mkdir -p "$HOME/.npm-global"
  npm config set prefix "$HOME/.npm-global" >/dev/null
}

setup_go_tools() {
  if ((skip_packages)); then
    return
  fi

  if command -v sesh >/dev/null 2>&1; then
    return
  fi

  if ! command -v go >/dev/null 2>&1; then
    warn "go is not installed; cannot install sesh fallback."
    return
  fi

  log "Installing sesh with go install."
  go install github.com/joshmedeski/sesh/v2@latest
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [[ -d "$tpm_dir" ]]; then
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git is not installed; cannot clone tmux plugin manager (tpm)."
    return
  fi

  log "Cloning tmux plugin manager (tpm)."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
}

apply_symlinks() {
  # DOTFILES_SYMLINK_FORCE=1 overwrites any existing real configs (e.g. an
  # existing ~/.config/nvim) in place instead of backing them up, so this
  # repo becomes the single source of truth on the macbook.
  log "Applying dotfile symlinks (force-overwriting existing configs, no backups)."
  DOTFILES_SYMLINK_VERBOSE=1 DOTFILES_SYMLINK_FORCE=1 zsh -c "source '$canonical_repo_dir/zshrc/modules/colors.sh'; source '$canonical_repo_dir/zshrc/modules/symlinks.sh'"
}

setup_shell() {
  if ((change_shell == 0)); then
    return
  fi

  local zsh_path
  zsh_path="$(command -v zsh || true)"

  if [[ -z "$zsh_path" ]]; then
    warn "zsh is not installed; cannot change login shell."
    return
  fi

  # Register the shell in /etc/shells if it's not already listed (required by chsh).
  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    log "Adding $zsh_path to /etc/shells (needs sudo)."
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || warn "Could not update /etc/shells."
  fi

  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    log "Changing login shell to $zsh_path."
    chsh -s "$zsh_path" || warn "chsh failed. You can run: chsh -s $zsh_path"
  fi
}

sync_neovim() {
  if ((skip_nvim_sync)); then
    log "Skipping LazyVim sync."
    return
  fi

  if ! command -v nvim >/dev/null 2>&1; then
    warn "nvim is not installed; skipping LazyVim sync."
    return
  fi

  log "Syncing LazyVim plugins. This can take a while on first install."
  NVIM_APPNAME=lazyvim nvim --headless '+Lazy! sync' '+qa'
}

install_tmux_plugins() {
  if ! command -v tmux >/dev/null 2>&1; then
    warn "tmux is not installed; skipping tmux plugin install."
    return
  fi

  local installer="$HOME/.tmux/plugins/tpm/bin/install_plugins"

  if [[ ! -x "$installer" ]]; then
    warn "tpm installer not found; skipping tmux plugin install."
    return
  fi

  log "Installing tmux plugins via tpm."
  "$installer" || warn "tmux plugin install reported an error; you can also press prefix + I inside tmux."

  # If a tmux server is already running, reload the config so the freshly
  # installed plugins take effect immediately (no need to reopen tmux).
  if tmux info >/dev/null 2>&1; then
    log "Reloading running tmux config so plugins load now."
    tmux source-file ~/.tmux.conf >/dev/null 2>&1 || warn "Could not reload tmux config; restart tmux to load plugins."
  fi
}

main() {
  ensure_canonical_repo_path
  ensure_command_line_tools
  install_homebrew
  install_packages
  setup_rust
  setup_npm_prefix
  setup_go_tools
  install_tpm
  apply_symlinks
  setup_shell
  sync_neovim
  install_tmux_plugins

  log "macOS bootstrap complete. Restart the terminal or run: exec zsh"
}

main
