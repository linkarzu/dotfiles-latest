# How to create new layouts

- `https://superuser.com/questions/1803835/tmux-tile-layout-arranges-8-panes-into-3x3-instead-of-4x2`
- In a tmux window, first configure your panes the way you want, in my example
  I configured 2 rows and 3 columns
- Then query tmux for `window_layout` and save the response to a file
- Following script will create the files needed and give you the command you
  need to add to your tmux.conf file

```bash
LAYOUT_NAME="new-lay"
LAYOUT_KEYBIND="L"

mkdir -p ~/github/dotfiles-latest/tmux/layouts/$LAYOUT_NAME

# Save the window layout to a file
tmux display-message -p '#{window_layout}' > ~/github/dotfiles-latest/tmux/layouts/$LAYOUT_NAME/layout.txt

# Create apply_layout.sh
cat <<EOF > ~/github/dotfiles-latest/tmux/layouts/$LAYOUT_NAME/apply_layout.sh
#!/bin/bash

LAYOUT=\$(cat ~/github/dotfiles-latest/tmux/layouts/$LAYOUT_NAME/layout.txt)
tmux select-layout "\$LAYOUT"
EOF

# Make the script executable
chmod +x ~/github/dotfiles-latest/tmux/layouts/$LAYOUT_NAME/apply_layout.sh

echo
echo "Tmux config command for this layout:"
echo "bind $LAYOUT_KEYBIND run-shell ~/github/dotfiles-latest/tmux/layouts/$LAYOUT_NAME/apply_layout.sh"
```
