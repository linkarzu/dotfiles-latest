# Filename: /Users/krishna/github/dotfiles-latest/tmux.conf

# #############################################################################
# Do not delete the `UNIQUE_ID` line below, I use it to backup original files
# so they're not lost when my symlinks are applied
# UNIQUE_ID=do_not_delete_this_line
# #############################################################################

# Tmux prefix key
set -g prefix C-b

# My terminal, alacritty, was configured to use TERM: xterm-256color, in the alacritty.yml file
# The only one that made truecolors work on nvim when using xterm-256color on alacritty is screen-256color
# set -g default-terminal "xterm-256color"
# set -g default-terminal "screen-256color"
# tmux-256color used to fuck up everything when using xterm-256 color
# I couldn't use backspace, but working fine since changed alacritty TERM to alacritty
# https://copyprogramming.com/howto/why-would-i-set-term-to-xterm-256color-when-using-alacritty
set -g default-terminal "tmux-256color"
# I was getting this warning in neovim
# Neither Tc nor RGB capability set. True colors are disabled
# Confirm your $TERM value outside of tmux first, mine returned "screen-256color"
# echo $TERM
# set-option -sa terminal-features ',xterm-256color:RGB'
set -sg terminal-overrides ",*:RGB"

# When pressing prefix+s to list sessions, I want them sorted by time
# That way my latest used sessions show at the top of the list
# -s starts with sessions collapsed (doesn't show windows)
# -Z zooms the pane (don't uderstand what this does)
# -O specifies the initial sort field: one of ‘index’, ‘name’, or ‘time’ (activity).
# https://unix.stackexchange.com/questions/608268/how-can-i-force-tmux-to-sort-my-sessions-alphabetically
bind s choose-tree -Zs -O time

# Create vertical split
unbind '|'
bind '|' split-window -h

# Create horizontal split
unbind '-'
bind - split-window -v

# how to navigate across the different panes in a window
# Notice I'm using vim motions
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Switch to windows 1 through 4
# 'p' is normally used to go to the previous window, but I won't use it
# ctrl+b c -> new window
# ctrl+b , -> rename current window
# ctrl+b w -> show list of windows and sessions
unbind p
bind u select-window -t 1
bind i select-window -t 2
bind o select-window -t 3
bind p select-window -t 4

# Switch to sessions 1 through 4
# ctrl+b : -> new -s 0 -> new session with name '0'
# ctrl+b $ -> rename current session
# ctrl+b s -> show list of sessions
bind 7 switch-client -t 1
bind 8 switch-client -t 2
bind 9 switch-client -t 3
bind 0 switch-client -t 4

# If you want to use the default meta key, which is 'option' in macos, you have to
# configure the alacritty 'option_as_alt' option, but that messed up my hyper key,
# so if I enable that option in alacritty, I cant do hyper+b which is what I use for
# tmux commands instead of ctrl+b. So instead, I'll just remap these
unbind J
unbind K
unbind L
unbind C-j
unbind C-k
unbind C-l
bind J select-layout even-horizontal
bind K select-layout even-vertical
# bind L select-layout tiled
bind L run-shell ~/github/dotfiles-latest/tmux/layouts/7030/apply_layout.sh
bind C-j select-layout main-horizontal
bind C-k select-layout main-vertical
bind C-l run-shell ~/github/dotfiles-latest/tmux/layouts/2x3/apply_layout.sh

# Switch between the last 2 tmux sessions, similar to 'cd -' in the terminal
unbind Space
bind-key Space switch-client -l

###############################################################################
# ThePrimeagen's tmux-sessionizer script, got 'em
###############################################################################

# ThePrimeagen's tmux-sessionizer script, got 'em
# I don't really care what these mappings are, pressing ctrl+* doesn't make any
# sense whatsoever, because it's not ergonomic, but I call them from
# bettertouchtool, and BTT is called from karabiner-elements
unbind C-u
unbind C-i
unbind C-o
unbind C-p
unbind C-y
unbind C-t
unbind C-h
unbind C-g

unbind C-w
unbind C-q
unbind C-a
unbind C-d
unbind C-f
unbind C-x
unbind C-c
unbind f
unbind C-v
unbind C-n
unbind C-m

tmux_sessionizer="~/github/dotfiles-latest/tmux/tools/prime/tmux-sessionizer.sh"
tmux_sshonizer_agen="~/github/dotfiles-latest/tmux/tools/linkarzu/tmux-sshonizer-agen.sh"
ssh_select="~/github/dotfiles-latest/tmux/tools/linkarzu/ssh-select.sh"
# Script below goes through you `~/.ssh/config` file and shows the hosts in an fzf menu
ssh_config_select="~/github/dotfiles-latest/tmux/tools/linkarzu/ssh_config_select.sh"

# Don't use C-r because it's used by tmux-resurrect
# Don't use C-e because I'm already using it for sending command to all panes/windows in current session
# Don't use C-s because Its used to save the session
# Don't use C-z, not sure what its for
bind-key -r C-u run-shell "$tmux_sessionizer ~/github/dotfiles-latest"
bind-key -r C-i run-shell "$tmux_sessionizer ~/github/dotfiles-public"
bind-key -r C-o run-shell "$tmux_sessionizer ~/github/linkarzu.github.io"
bind-key -r C-p run-shell "$tmux_sessionizer ~/github/scripts"
bind-key -r C-t run-shell "$tmux_sessionizer ~/github/obsidian_main"
bind-key -r C-y run-shell "$tmux_sessionizer ~/github/containerdata"
bind-key -r C-h run-shell "$tmux_sessionizer ~"
bind-key -r C-m run-shell "$tmux_sessionizer ~/github/containerdata-public"
# Leaving this in quotes because iCloud dir has a white space
bind-key -r C-g run-shell "$tmux_sessionizer '$HOME/Library/Mobile Documents/com~apple~CloudDocs/github/macos-setup'"

bind-key -r C-w run-shell "$tmux_sshonizer_agen docker3"
bind-key -r C-q run-shell "$tmux_sshonizer_agen prodkubecp3"
bind-key -r C-a run-shell "$tmux_sshonizer_agen dns3"
bind-key -r C-d run-shell "$tmux_sshonizer_agen lb3"
bind-key -r C-f run-shell "$tmux_sshonizer_agen prodkubew3"
bind-key -r C-x run-shell "$tmux_sshonizer_agen storage3"
bind-key -r C-c run-shell "$tmux_sshonizer_agen xocli3"

bind-key -r f run-shell "tmux neww $tmux_sessionizer"
bind-key -r C-v run-shell "tmux neww $ssh_select"
bind-key -r C-n run-shell "tmux neww $ssh_config_select"

###############################################################################

# Reload the tmux configuration, display a 2 second message
unbind r
bind r source-file ~/.tmux.conf \; display-message -d 2000 "Configuration reloaded!"

# Bind pane synchronization to Ctrl-b s
bind Q setw synchronize-panes

# This enables vim nagivation
# If for example I'm in the scrolling mode (yellow) can navigate with vim motions
# search with /, using v for visual mode, etc
set-window-option -g mode-keys vi

# Go to previous window, I'm using 'p' to change to window 4
unbind m
bind m previous-window

# Resize pane to zoom so it occupies the entire screen
unbind M
bind -r M resize-pane -Z

# The number at the end specifies number of cells
# Increase or decrease to your liking
bind -r Left resize-pane -L 1
bind -r Down resize-pane -D 1
bind -r Up resize-pane -U 1
bind -r Right resize-pane -R 1

# start selecting text with "v"
bind-key -T copy-mode-vi 'v' send -X begin-selection
# copy text with "y"
bind-key -T copy-mode-vi 'y' send -X copy-selection

# https://github.com/leelavg/dotfiles/blob/897aa883a/config/tmux.conf#L30-L39
# https://scripter.co/command-to-every-pane-window-session-in-tmux/
# Send the same command to all panes/windows in current session
bind C-e command-prompt -p "Command:" \
	"run \"tmux list-panes -s -F '##{session_name}:##{window_index}.##{pane_index}' \
                | xargs -I PANE tmux send-keys -t PANE '%1' Enter\""

# Send the same command to all panes/windows/sessions
bind E command-prompt -p "Command:" \
	"run \"tmux list-panes -a -F '##{session_name}:##{window_index}.##{pane_index}' \
              | xargs -I PANE tmux send-keys -t PANE '%1' Enter\""

# Increase scroll history
set-option -g history-limit 10000

# New windows normally start at 0, but I want them to start at 1 instead
set -g base-index 1

# With this set to off
# when you close the last window in a session, tmux will keep the session
# alive, even though it has no windows open. You won't be detached from
# tmux, and you'll remain in the session
set -g detach-on-destroy off

# Imagine if you have windows 1-5, and you close window 3, you are left with
# 1,2,4,5, which is inconvenient for my navigation method seen below
# renumbering solves that issue, so if you close 3 youre left with 1-4
set -g renumber-windows on

# There's no plugin to renumber sessions, but just do
# : new -s 4
# And that will give the new session the desired number

# Swap the pane with the next pane to the right
# Instead of this use `{` and `}` that are defaults
# bind S swap-pane -D

# Enable mouse support to resize panes, scrolling, etc
set -g mouse on

# I had to set this to on for osc52 to work
# https://github.com/ojroques/nvim-osc52
set -s set-clipboard on

# don't exit copy mode when dragging with mouse
unbind -T copy-mode-vi MouseDragEnd1Pane

# If I'm in insert mode typing text, and press escape, it will wait this amount
# of time to switch to normal mode when I press escape
# this setting was recommended by neovim `escape-time` (default 500)
# Can be set to a lower value, like 10 for it to be faster
set-option -sg escape-time 100

# Enables tracking of focus events, allows tmux to respond when the terminal
# window gains or looses focus
set-option -g focus-events on

set -g status-position bottom

##############################################################################
##############################################################################
#
# Plugins section
#
##############################################################################
##############################################################################

# Tmux Plugin Manager (tpm), to install it, clone the repo below
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
set -g @plugin 'tmux-plugins/tpm'

# list of tmux plugins
# for navigating panes and vim/nvim with Ctrl-hjkl
# set -g @plugin 'christoomey/vim-tmux-navigator'

##############################################################################
# Themes section, only enable 1

# >>>>>>>>>>>>>>>>>>>>>>>> VERY IMPORTANT NOTE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# To change the theme, delete the `~/.tmux/plugins/tmux` dir first
# rm -rf ~/.tmux/plugins/tmux
# Enable the desired theme in this tmux.conf file, just enable 1
# Then install plugins ctrl+b shift+i
# - If you don't follow these steps, the old theme won't be replaced by the new
# one
##############################################################################

# Dracula theme
# https://draculatheme.com/tmux
# available plugins: battery, cpu-usage, git, gpu-usage, ram-usage,
# tmux-ram-usage, network, network-bandwidth, network-ping, attached-clients,
# network-vpn, weather, time, spotify-tui, kubernetes-context, synchronize-panes

# set -g @plugin 'dracula/tmux'
# set -g @dracula-plugins "synchronize-panes git time network-ping tmux-ram-usage"
# set -g @dracula-synchronize-panes-label "Sync:"
# # available colors: white, gray, dark_gray, light_purple, dark_purple, cyan, green, orange, red, pink, yellow
# set -g @dracula-synchronize-panes-colors "orange gray"
# set -g @dracula-show-powerline true
# set -g @dracula-show-left-icon session
# set -g @dracula-tmux-ram-usage-label "tmuxRam:"
# set -g @dracula-tmux-ram-usage-colors "dark_purple white"
# set -g @dracula-border-contrast true

# ----------------------------------------------------------------------------

# Catppuccin theme
# https://github.com/catppuccin/tmux
# Cons:
# - Doesn't have a synch panes like dracula
# Pros:
# - I feel my terminal waaaaay smoother/faster, not completely sure about this
#   But could be due to all the refreshing and polling of data Dracula had to do

set -g @plugin 'catppuccin/tmux'
set -g @catppuccin_flavour 'mocha' # or frappe, macchiato, mocha

set -g @catppuccin_window_left_separator ""
set -g @catppuccin_window_right_separator " "
set -g @catppuccin_window_middle_separator " █"
set -g @catppuccin_window_number_position "right"

set -g @catppuccin_window_default_fill "number"
set -g @catppuccin_window_default_text "#W"

set -g @catppuccin_window_current_fill "number"
set -g @catppuccin_window_current_text "#W"

set -g @catppuccin_status_modules_left "session"
set -g @catppuccin_status_modules_right "directory"
# `user` and `host` are kind of useless, dont change when you ssh to devices
# set -g @catppuccin_status_modules_right "directory user host"
set -g @catppuccin_status_left_separator " "
set -g @catppuccin_status_right_separator ""
set -g @catppuccin_status_right_separator_inverse "no"
set -g @catppuccin_status_fill "icon"
set -g @catppuccin_status_connect_separator "no"

set -g @catppuccin_directory_text "#{pane_current_path}"

# ----------------------------------------------------------------------------

# Powerline theme
# https://github.com/jimeh/tmux-themepack
# set -g @plugin 'jimeh/tmux-themepack'
# set -g @themepack 'powerline/default/cyan'

##############################################################################
# Other plugins
##############################################################################

# persist tmux sessions after computer restart
# https://github.com/tmux-plugins/tmux-resurrect
set -g @plugin 'tmux-plugins/tmux-resurrect'
# allow tmux-ressurect to capture pane contents
set -g @resurrect-capture-pane-contents 'on'
# automatically saves sessions for you every 15 minutes (this must be the last plugin)
# https://github.com/tmux-plugins/tmux-continuum
set -g @plugin 'tmux-plugins/tmux-continuum'
# enable tmux-continuum functionality
set -g @continuum-restore 'on'
# Set the save interval in minutes, default is 15
set -g @continuum-save-interval '5'

# Initialize TMUX plugin manager
# (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
