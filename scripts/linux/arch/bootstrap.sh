#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
canonical_repo_dir="$HOME/github/dotfiles-latest"

pacman_packages=(
  base-devel
  bat
  btop
  ca-certificates
  clang
  cmake
  curl
  dotnet-sdk
  eza
  fastfetch
  fd
  fzf
  gcc
  ghostty
  git
  git-delta
  github-cli
  go
  jq
  kitty
  lazygit
  lldb
  lua
  luarocks
  make
  neovim
  nodejs
  noto-fonts
  noto-fonts-emoji
  npm
  openssh
  pkgconf
  python
  python-pip
  ripgrep
  rustup
  shfmt
  shellcheck
  starship
  stylua
  tar
  tmux
  tree-sitter-cli
  ttf-cascadia-code-nerd
  ttf-jetbrains-mono-nerd
  unzip
  wget
  wl-clipboard
  xclip
  xz
  yazi
  zip
  zoxide
  zsh
)

optional_pacman_packages=(
  code
  docker
  docker-compose
  helm
  kubectl
  kubectx
  neovide
  ttf-meslo-nerd
)

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
  --skip-packages    Do not install pacman packages.
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

if [[ ! -r /etc/os-release ]]; then
  die "Cannot detect Linux distribution; /etc/os-release is missing."
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "arch" && "${ID_LIKE:-}" != *"arch"* ]]; then
  die "This bootstrap is for Arch Linux or Arch-based systems. Detected: ${PRETTY_NAME:-unknown}"
fi

if ! command -v pacman >/dev/null 2>&1; then
  die "pacman is required for this bootstrap."
fi

ensure_canonical_repo_path() {
  mkdir -p "$HOME/github"

  if [[ -e "$canonical_repo_dir" || -L "$canonical_repo_dir" ]]; then
    if [[ -d "$canonical_repo_dir" ]] &&
      [[ "$(cd -P "$canonical_repo_dir" && pwd)" == "$(cd -P "$repo_dir" && pwd)" ]]; then
      return
    fi
    die "$canonical_repo_dir already exists, but this script is running from $repo_dir. Run the installer from $canonical_repo_dir."
  fi

  ln -s "$repo_dir" "$canonical_repo_dir"
  log "Linked $canonical_repo_dir -> $repo_dir"
}

filter_available_packages() {
  local package
  local -a available=()

  for package in "$@"; do
    if pacman -Si "$package" >/dev/null 2>&1; then
      available+=("$package")
    else
      warn "Skipping unavailable pacman package: $package"
    fi
  done

  printf '%s\n' "${available[@]}"
}

install_packages() {
  if ((skip_packages)); then
    log "Skipping package installation."
    return
  fi

  sudo pacman -Syu --needed --noconfirm

  local -a packages
  mapfile -t packages < <(filter_available_packages "${pacman_packages[@]}" "${optional_pacman_packages[@]}")

  if ((${#packages[@]})); then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
  fi
}

setup_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    warn "rustup is not installed; skipping Rust toolchain setup."
    return
  fi

  rustup default stable
  rustup component add rustfmt clippy rust-analyzer rust-src
  export PATH="$HOME/.cargo/bin:$PATH"
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

  if [[ ! -d "$tpm_dir" ]]; then
    log "Cloning tmux plugin manager (tpm)."
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
}

install_tmux_plugins() {
  local installer="$HOME/.tmux/plugins/tpm/bin/install_plugins"

  if [[ ! -x "$installer" ]]; then
    die "TPM installer is missing: $installer"
  fi

  log "Installing tmux plugins via tpm."
  "$installer"

  if tmux info >/dev/null 2>&1; then
    tmux source-file "$HOME/.tmux.conf"
  fi
}

apply_symlinks() {
  log "Applying dotfile symlinks."
  DOTFILES_REPO_DIR="$canonical_repo_dir" DOTFILES_SYMLINK_VERBOSE=1 zsh -c \
    'source "$DOTFILES_REPO_DIR/zshrc/modules/colors.sh"; source "$DOTFILES_REPO_DIR/zshrc/modules/symlinks.sh"'
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

main() {
  ensure_canonical_repo_path
  install_packages
  setup_rust
  setup_npm_prefix
  setup_go_tools
  install_tpm
  apply_symlinks
  setup_shell
  sync_neovim
  install_tmux_plugins

  log "Arch bootstrap complete. Restart the terminal or run: exec zsh"
}

main
