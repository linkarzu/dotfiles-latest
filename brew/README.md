# Homebrew

## Install brew

In the [brew documentation](https://docs.brew.sh/Installation)
you can see the macOS Requirements

- A 64-bit Intel CPU or Apple Silicon CPU 1
- macOS Big Sur (11) (or higher) 2
- Command Line Tools (CLT) for Xcode (from xcode-select --install or
  `https://developer.apple.com/download/all/`) or Xcode 3
- The Bourne-again shell for installation (i.e. bash) 4

So first I'll install the Command Line Tools (CLT) for xcode

- ==Takes like 20 min to install==
- You don't need the entire 14GB Xcode app from the appstore

```bash
xcode-select --install
```

---

Then go to the main page `https://brew.sh` to find the installation command

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

After the installation is completed, notice that you need to configure your
shell for homebrew in the **Next steps** section

```bash
echo
echo "Configuring shell for brew"
echo '' >>~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Here's the file that gets modified

```bash
krishna@chris-m1-mini ~ % cat .zprofile

eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

Make sure everything's set up correctly

```bash
brew doctor
```

```bash
krishna@chris-m1-mini ~ % brew doctor
Your system is ready to brew.
```

## Use a brewfile

The Brewfile is a list of software installed by Homebrew

- This will create a file named `Brewfile` in the current directory.

```bash
brew bundle dump
```

---

To install the apps listed in the Brewfile

- Make sure you're in the directory in which the brewfile is

```bash
brew bundle
```

## Caveats

The caveats for each one of the apps I use, are already taken care of by the
`dotfiles-latest/zshrc/zshrc-file.sh` file, but in case you need to see
the caveats of a single app

```bash
brew list
```

```bash
brew info z.lua
```

---

With this script, [found in stackoverflow](https://stackoverflow.com/questions/13333585/how-do-i-replay-the-caveats-section-from-a-homebrew-recipe), you can check the caveats for each one of the installed packages

- 2nd one is the same, but with comments
- Just copy and paste the code in your terminal

```bash
for cmd in $(brew list); do
  if brew info $cmd | grep -q Caveats; then
    echo "$cmd\n";
    brew info $cmd | sed '/==> Caveats/,/==>/!d;//d';
    printf '%40s\n' | tr ' ' -;
  fi;
done;
```

```bash
# This loop will go through each installed Homebrew package
for cmd in $(brew list); do

  # This line checks if there are any caveats for the current package
  # 'grep -q' suppresses the output and just returns an exit status
  # If caveats exist, the exit status will be 0 (success), triggering the if block
  if brew info $cmd | grep -q Caveats; then

    # This line will print the name of the current package followed by a newline
    echo "$cmd\n";

    # This line prints the caveats for the current package
    # The 'sed' command is used to print only the lines between '==> Caveats' and the next '==>' line
    # The '/!d' at the end deletes all lines not matching the pattern, leaving only the caveats
    # The '//d' deletes the 'Caveats' and next '==>' line itself
    brew info $cmd | sed '/==> Caveats/,/==>/!d;//d';

    # This line prints a 40-character long string of dashes
    # It's used to visually separate the caveats for different packages
    printf '%40s\n' | tr ' ' -;
  fi;

done;
```
