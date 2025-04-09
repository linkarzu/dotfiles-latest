# Common settings and plugins
alias ll='ls -lh'
alias lla='ls -alh'
alias python='python3'
# Shows the last 30 entries, default is 15
alias history='history -30'
alias x='exit'

# kubernetes, if you need help, just run 'kgp --help' for example
alias k='kubectl'
alias kx='kubectx'
# alias ks='kubeswap'
alias ks='kubens'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpo='kubectl get pods -o wide'

alias emacs='~/.config/emacs/bin/doom run'

# golang aliases
alias coverage='go test -coverprofile=coverage.out && go tool cover -html=coverage.out'

alias pulldeez='echo "Pulling latest changes, please wait..."; (cd ~/github/dotfiles-latest && git pull >/dev/null 2>&1) || echo "Failed to pull dotfiles"; source ~/.zshrc'
