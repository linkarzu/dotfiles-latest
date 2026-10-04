# Autocompletion settings
# https://github.com/Phantas0s/.dotfiles/blob/master/zsh/completion.zsh
# These have to be on the top, I remember I had issues with some autocompletions if not
zmodload zsh/complist
# Homebrew completions (brew, kubectl, gh, etc) must be in fpath before the
# single compinit below. `brew shellenv` in ~/.zprofile already adds it for
# login shells, this covers non-login shells without adding a duplicate.
# NOTE: Don't run compinit a second time anywhere else, two calls with a
# different fpath make each one rewrite ~/.zcompdump on every shell start
if [[ -d ${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions ]]; then
  fpath=(${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions ${fpath:#${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions})
fi
autoload -Uz compinit
# Only do the full completion check (compaudit + rescanning fpath) once a day,
# otherwise trust the existing ~/.zcompdump
zcompdump_stale=(~/.zcompdump(N.mh+24))
if (( $#zcompdump_stale )); then
  compinit
  # compinit only rewrites the dump if something changed, reset the 24h timer
  touch ~/.zcompdump
else
  compinit -C
fi
unset zcompdump_stale
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
