# Tmux useful commands and settings

## Install tmux on macos

```bash
clear

echo
echo ">>>>>>>>>>>>>>>>>>>>>>>"
echo
brew install tmux

echo
echo ">>>>>>>>>>>>>>>>>>>>>>>"
echo
echo "Cloning tmux plugin manager repo"
echo "if it already exists it will just error and no issue"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo
echo ">>>>>>>>>>>>>>>>>>>>>>>"
echo
echo "running a git pull on my dotfiles-public repo to get latest changes"
cd ~/github/dotfiles-public
git pull

echo
echo ">>>>>>>>>>>>>>>>>>>>>>>"
echo
echo "Applying my own tmux config"
ln -snf ~/github/dotfiles-public/tmux/tmux.conf.sh ~/.tmux.conf

echo
echo ">>>>>>>>>>>>>>>>>>>>>>>"
echo
echo "Now that tmux is installed, first open it with 'tmux'"
echo "After opening it, install the plugins as shown below"
echo ">>>>>>>>>>>Once in tmux run 'ctrl+b' and then 'shift+i'<<<<<<<<<<<"
echo
echo "You should see the file below pointing to the newly configured file"
ls -l ~/.tmux.conf
```

## Delete tmux resurrect settings

I wanted to delete my resurrect data to start fresh with tmux,
so all you need to do is delete this folder below.
You can `mv` it instead of deleting it in case you want to back it up

```bash
rm -rf ~/.local/share/tmux
```

## Configure tmux for the first time

Open a tmux session

```bash
tmux
```

The first time you apply changes to the tmux.conf file
you'll have to source it to apply changes
But I configured a remap to source it afterwards

- So press `ctrl+b`
- Then `:`
- And type

```bash
source-file ~/.tmux.conf
```

Now you have to install the plugins

- So press `ctrl+b`
- then `shift+i` for capital `I` to install
- This will open a window in which you'll see the plugins get installed

```bash
Already installed "tpm"   [0/0]Already installed "vim-tmux-navigator"
Already installed "tmux-themepack"
Already installed "tmux-resurrect"
Already installed "tmux-continuum"

TMUX environment reloaded.

Done, press ENTER to continue.
```

## Tmux basics

To start a new tmux session without sourcing the `.tmux.conf` file
this is useful to see if your config is causing any issues

```bash
tmux -f /dev/null
```

From inside tmux to view the list of all the commands run

- `ctrl+b?`

Create a new session with a name outside tmux

```bash
tmux new -s xcp
```

Create a new session with a name from within tmux

- So press `ctrl+b`
- Then `:`

```bash
new -s dotfiles
```

Detach from the session (this even closes Alacritty for me)

- `ctrl+b d` - from within tmux

```bash
tmux detach
```

See list of sessions

- `ctrl+b s` - from within tmux

```bash
tmux ls
```

See list of windows and sessions

- `ctrl+b w`
- When in here, you can type `x` to kill a session and type `yes` at the bottom

Attach to a session

```bash
tmux a -t xcp
tmux a -t 0
```

To create a new window inside a session

- `ctrl+b c`

Kill current window (or just type exit on the terminal)

- `C-b &`

To navigate between windows inside a session

- `ctrl+b n` - next
- `ctrl+b p` - previous (I remapped this to 'm')
- `ctrl+b #` - specify a number

Maximize and minimize back a pane

- `ctrl+b m` - I remapped this to `ctrl+b M`

Rename a session

- `ctrl+b $`

Rename current window

- `ctrl+b ,`

---

Scroll in a tmux pane

- `ctrl+[`
- Then scroll with vim navigation
- When inside this mode you can also use the following
  and the cursor will be kept in a **fixed position**
  - shift J
  - shift K
- When in this mode:
  - We can select text with `v`
  - And copy the text with `y`
  - This is because the `bind-key -T copy-mode-vi 'v' send -X begin-selection`
    lines in our tmux config file
- `q` to stop scrolling
  - or `ctrl+c`
