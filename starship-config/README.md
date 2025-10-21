# Installation

To install starship go to the [main page](https://starship.rs) and follow the instructions for your OS. Below are the steps for linux and macOS

For consistency across machines, clone this repo inside the `~/github` directory

## Linux using bash

Install the latest version
```bash
curl -sS https://starship.rs/install.sh | sh
```

Add this line to the end of your `~/.bashrc`
```bash
eval "$(starship init bash)"
```

## macos using zsh

Install the latest version
```bash
curl -sS https://starship.rs/install.sh | sh
```

Add this line to the end of your `~/.zshrc` file
- **Mine didn't exist so I had to create it**
```bash
eval "$(starship init zsh)"
```

# Change default config file location
Configuration changes are normally applied to the `~/.config/starship.toml` file, but since I have my file in github, I changed the default config file so that I can easily clone the repo to a new machine

I'll keep all my github repos in the `github` repo so I can just clone stuff in there. After cloning the repo there just run the following command so that the starship points to the cloned configuration
- **Add this line at the end of your `~/.bashrc` or `~/.zshrc` file**

Check your type of shell
```bash
echo $SHELL
```

If you're using `~/.bashrc`
```bash
echo "export STARSHIP_CONFIG=~/github/dotfiles-latest/starship-config/starship.toml" >> ~/.bashrc
```

If you're using `~/.zshrc`
```bash
echo "export STARSHIP_CONFIG=~/github/dotfiles-latest/starship-config/starship.toml" >> ~/.zshrc
```
