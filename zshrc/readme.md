# Contents

<!-- toc -->

- [Symlink backup verification commands](#symlink-backup-verification-commands)
  - [List all the files and backups](#list-all-the-files-and-backups)
  - [Deletion original files and directories](#deletion-original-files-and-directories)
  - [Simulate replacement of existing dirs and symlinks](#simulate-replacement-of-existing-dirs-and-symlinks)
  - [See all the files and backups](#see-all-the-files-and-backups)
  - [Delete all the backups](#delete-all-the-backups)

<!-- tocstop -->

## Symlink backup verification commands

I used all the following to make sure that the sylink backup process works as
expected, it seems to be working as expected

### List all the files and backups

```bash
# These are files
ls -l /Users/krishna/.vimrc*
ls -l /Users/krishna/github/obsidian_main/.obsidian.vimrc*
ls -l /Users/krishna/.zshrc*
ls -l /Users/krishna/.tmux.conf*
ls -l /Users/krishna/.config/alacritty/alacritty.toml*
ls -l /Users/krishna/.yabairc*

# Below ones are directories
ls -ld /Users/krishna/.config/nvim*
ls -ld /Users/krishna/.hammerspoon*
ls -ld /Users/krishna/.config/karabiner*
```

### Deletion original files and directories

- To delete all the original files and directories and confirm they will be
  recreated

```bash
# These are files
rm /Users/krishna/.vimrc
rm /Users/krishna/github/obsidian_main/.obsidian.vimrc
rm /Users/krishna/.tmux.conf
rm /Users/krishna/.config/alacritty/alacritty.toml
rm /Users/krishna/.yabairc

# Below ones are directories
rm -r /Users/krishna/.config/nvim
rm -r /Users/krishna/.hammerspoon
rm -r /Users/krishna/.config/karabiner
```

### Simulate replacement of existing dirs and symlinks

This will delete all the original files and directories, in case they're
symlinks, then re-create them as regular files with test data Useful to test
backup funcionality

```bash
# These are files
rm /Users/krishna/.vimrc
rm /Users/krishna/github/obsidian_main/.obsidian.vimrc
rm /Users/krishna/.tmux.conf
rm /Users/krishna/.config/alacritty/alacritty.toml
rm /Users/krishna/.yabairc

# Below ones are directories
rm -r /Users/krishna/.config/nvim
rm -r /Users/krishna/.hammerspoon
rm -r /Users/krishna/.config/karabiner

echo "# Test file auto created" > /Users/krishna/.vimrc
echo "# Test file auto created" > /Users/krishna/github/obsidian_main/.obsidian.vimrc
echo "# Test file auto created" > /Users/krishna/.tmux.conf
echo "# Test file auto created" > /Users/krishna/.config/alacritty/alacritty.toml
echo "# Test file auto created" > /Users/krishna/.yabairc
mkdir -p /Users/krishna/.config/nvim
echo "echo 'Test content'" > /Users/krishna/.config/nvim/testfile.sh
mkdir -p /Users/krishna/.hammerspoon
echo "echo 'Test content'" > /Users/krishna/.hammerspoon/testfile.sh
mkdir -p /Users/krishna/.config/karabiner
echo "echo 'Test content'" > /Users/krishna/.config/karabiner/testfile.sh
```

### See all the files and backups

```bash
# These are files
ls -l /Users/krishna/.vimrc*
ls -l /Users/krishna/github/obsidian_main/.obsidian.vimrc*
ls -l /Users/krishna/.zshrc*
ls -l /Users/krishna/.tmux.conf*
ls -l /Users/krishna/.config/alacritty/alacritty.toml*
ls -l /Users/krishna/.yabairc*

# Below ones are directories
ls -ld /Users/krishna/.config/nvim*
ls -ld /Users/krishna/.hammerspoon*
ls -ld /Users/krishna/.config/karabiner*
```

### Delete all the backups

```bash
# These are files
rm /Users/krishna/.vimrc_backup_*
rm /Users/krishna/github/obsidian_main/.obsidian.vimrc_backup_*
rm /Users/krishna/.zshrc.backup
rm /Users/krishna/.tmux.conf_backup_*
rm /Users/krishna/.config/alacritty/alacritty.toml_backup_*
rm /Users/krishna/.yabairc_backup_*

# Below ones are directories
rm -r /Users/krishna/.config/nvim_backup_*
rm -r /Users/krishna/.hammerspoon_backup_*
rm -r /Users/krishna/.config/karabiner_backup_*
```
