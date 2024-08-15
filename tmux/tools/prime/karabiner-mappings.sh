# Filename: ~/github/dotfiles-latest/tmux/tools/prime/karabiner-mappings.sh

# NOTE:
# This is not actually a script, just gave it .sh name for syntax highlighting

# NOTE:
# Make sure that you manually change your dirs here with '_' instead of
# '-' and '.' because these last 2 will be interpreted
# For example, I changed:
# - dotfiles-latest -> dotfiles_latest
# - linkarzu.github.io -> linkarzu_github_io
# - Notice I also escaped the ';' with '\;'
# - Using "'" works, but not too well, because cannot switch to it from the
# tmux sessions pane (ctrl+b s)

# `username_suffix` is the mapping for the home directory
# Do not modify this variable name because it's used by the tmux-sessionizer script
# You can change the mapping on the right from "h" to whatever you want
username_suffix="h"

dotfiles_latest="j"
watusy="k"
github_nfs="l"
scripts="\;"
obsidian_main="u"
php="i"
containerdata_public="o"
containerdata_nfs="p"
containerdata="y"
go="["
