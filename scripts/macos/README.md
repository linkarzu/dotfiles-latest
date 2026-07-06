# macOS setup

Automated bootstrap for this dotfiles repo on a Mac (Apple Silicon or Intel).
Everything lives on the `macbook` branch.

## Install

```sh
mkdir -p ~/github && cd ~/github
git clone git@github.com:bulutcan99/dotfiles-latest.git   # if not already cloned
cd dotfiles-latest
git checkout macbook
./install.sh
```

`./install.sh` detects macOS and runs [`mac/bootstrap.sh`](mac/bootstrap.sh), which:

1. Ensures the Xcode Command Line Tools are installed.
2. Installs Homebrew if missing (auto-detects `/opt/homebrew` vs `/usr/local`).
3. Installs every package in [`../../brew/Brewfile`](../../brew/Brewfile)
   (CLI tools, languages, GUI apps, Nerd Fonts) via `brew bundle`.
4. Sets up the Rust toolchain, the npm prefix, and a `sesh` fallback.
5. Clones the tmux plugin manager (tpm) and installs tmux plugins.
6. Applies all dotfile symlinks (`zshrc/modules/symlinks.sh`) with
   `DOTFILES_SYMLINK_FORCE=1` — **any existing config (e.g. `~/.config/nvim`) is
   overwritten in place, not backed up.** This repo becomes the single source of
   truth on the macbook.
7. Sets the login shell to zsh.
8. Syncs LazyVim plugins headlessly.
9. Installs tmux plugins via tpm, and reloads a running tmux server so they load
   immediately.

After it finishes, open a new terminal or run `exec zsh`.

## Flags

| Flag | Effect |
| --- | --- |
| `--skip-packages` | Skip `brew bundle` (re-run symlinks / nvim only). |
| `--skip-nvim-sync` | Don't run the LazyVim plugin sync. |
| `--no-chsh` | Don't change the login shell to zsh. |
| `-h`, `--help` | Show usage. |

Re-running is safe (idempotent): existing packages are skipped and symlinks are
refreshed in place. Note that on macOS symlinking runs in force mode, so any real
config files at the symlink targets are overwritten (not backed up).
