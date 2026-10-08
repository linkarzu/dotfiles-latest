# Filename: ~/github/dotfiles-latest/zshrc/modules/prompt.sh
# ~/github/dotfiles-latest/zshrc/modules/prompt.sh

# Native zsh prompt, replaces starship. Same look as my starship config minus
# the git/language modules, which I never looked at:
#
#   linkarzu.@.[26/10/07]<logo>
#   ~/github/dotfiles-latest
#   ❯❯❯❯
#
# Starship forks 2 processes on every prompt (left and right), ~27ms per
# prompt inside a git repo. This is pure zsh, nothing gets forked when drawing
# the prompt
#
# U+E000 is the custom Linkarzu Logo glyph in
# ~/github/dotfiles-latest/starship-config/logo-font/LinkarzuLogo-Regular.ttf
# It is written as its UTF-8 bytes \xEE\x80\x80 because \uE000 errors out with
# "character not in range" when the locale is not UTF-8

setopt PROMPT_SUBST
zmodload -F zsh/stat b:zstat

_prompt_colors_file=$HOME/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh
_prompt_colors_mtime=
_prompt_status=0

# Colors come from the active colorscheme. The file is only re-read when its
# mtime changes, so colorscheme-set.sh still recolors already open shells on
# their next prompt, like starship did
_prompt_load_colors() {
  local -a mtime
  zstat -A mtime +mtime -- $_prompt_colors_file 2>/dev/null || return
  [[ $mtime[1] == $_prompt_colors_mtime ]] && return
  _prompt_colors_mtime=$mtime[1]
  source $_prompt_colors_file

  # Hostname only shows up over SSH
  local host=
  [[ -n $SSH_CONNECTION ]] && host="%B%F{$linkarzu_color02}%m%f%b"

  PROMPT=$'\n'
  PROMPT+="%B%(!.%F{white}.%F{$linkarzu_color04})%n%f%b.@.${host}"
  PROMPT+="%B%F{$linkarzu_color04}[%D{%y/%m/%d}]%f%b"
  PROMPT+="%F{$linkarzu_color02}"$'\xEE\x80\x80'"%f"$'\n'
  PROMPT+="%B%F{$linkarzu_color03}%~%f%b"$'\n'
  PROMPT+='${_prompt_char} '
  RPROMPT=
}

# Sets the ❯❯❯❯ / XXXX symbol from the exit status of the last command
_prompt_set_char() {
  if ((_prompt_status == 0)); then
    _prompt_char="%B%F{$linkarzu_color02}❯❯❯❯%f%b"
  else
    _prompt_char="%B%F{$linkarzu_color11}XXXX%f%b"
  fi
}

_prompt_precmd() {
  _prompt_status=$?
  _prompt_load_colors
  _prompt_set_char
}

# Runs first so $? is still the exit status of the last command. The guard
# keeps it from being added twice when the zshrc is re-sourced
((${precmd_functions[(I)_prompt_precmd]})) ||
  precmd_functions=(_prompt_precmd $precmd_functions)

