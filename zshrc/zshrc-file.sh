# Filename: ~/github/dotfiles-latest/zshrc/zshrc-file.sh

# #############################################################################
# Do not delete the `UNIQUE_ID` line below, I use it to backup original files
# so they're not lost when my symlinks are applied
# UNIQUE_ID=do_not_delete_this_line
# #############################################################################

source ~/github/dotfiles-latest/zshrc/zshrc-common.sh

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
# If you don't want to fork, comment this section if you don't want to always pull
# my latest changes, otherwise your changes will be overriden by my updates
#
# If the variable DISABLE_PULL is UNSET, pull the latest changes
# I set this var from neovim when opening a tmux pane on the right
echo
if [[ -z "$DISABLE_PULL" ]]; then
  echo "Pulling latest changes, please wait..."
  (cd ~/github/dotfiles-latest && git pull >/dev/null 2>&1) || echo "Failed to pull dotfiles"
fi
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
  source ~/github/dotfiles-latest/zshrc/zshrc-macos.sh
fi

# Linux (Debian)-specific configurations
if [ "$OS" = 'Linux' ]; then
  source ~/github/dotfiles-latest/zshrc/zshrc-linux.sh
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/linkarzu/.lmstudio/bin"
