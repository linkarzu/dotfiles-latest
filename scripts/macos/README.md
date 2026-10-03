# macOS setup

Automated bootstrap for this dotfiles repo on a Mac (Apple Silicon or Intel).
The workflow installer is available on the `bootstrap/reproduce-workflow-20261003` branch.

## Install

```sh
mkdir -p ~/github && cd ~/github
git clone --branch bootstrap/reproduce-workflow-20261003 https://github.com/bulutcan99/dotfiles-latest.git   # if not already cloned
cd dotfiles-latest
./install.sh
```

`./install.sh` detects macOS and runs [`mac/bootstrap.sh`](mac/bootstrap.sh), which:

1. Ensures the Xcode Command Line Tools are installed.
2. Installs Homebrew if missing (auto-detects `/opt/homebrew` vs `/usr/local`).
3. Installs every package in [`../../brew/Brewfile`](../../brew/Brewfile)
   (CLI tools, .NET SDK, GUI apps, Nerd Fonts) via `brew bundle`.
4. Sets up the Rust toolchain, the npm prefix, and a `sesh` fallback.
5. Clones the tmux plugin manager (tpm) and installs tmux plugins.
6. Disables the macOS input-source Ctrl+Space shortcut so Ghostty receives it,
   and disables the old LaunchAgent that deleted idle tmux sessions.
7. Applies dotfile symlinks (`zshrc/modules/symlinks.sh`) after backing up
   existing files and directories with timestamped names.
8. Sets the login shell to zsh.
9. Syncs LazyVim plugins headlessly.
10. Installs tmux plugins via tpm, and reloads a running tmux server so they load
   immediately.

After it finishes, open a new terminal or run `exec zsh`.

## Flags

| Flag | Effect |
| --- | --- |
| `--skip-packages` | Skip `brew bundle` (re-run symlinks / nvim only). |
| `--skip-nvim-sync` | Don't run the LazyVim plugin sync. |
| `--no-chsh` | Don't change the login shell to zsh. |
| `-h`, `--help` | Show usage. |

Re-running is safe: existing packages are skipped and symlinks already pointing
to this repo are left alone. Existing real configuration files are backed up.
