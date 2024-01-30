<h3 align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/logos/exports/1544x1544_circle.png" width="100" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	Catppuccin for <a href="https://github.com/alacritty/alacritty">Alacritty</a>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h3>

<p align="center">
    <a href="https://github.com/catppuccin/alacritty/stargazers"><img src="https://img.shields.io/github/stars/catppuccin/alacritty?colorA=363a4f&colorB=b7bdf8&style=for-the-badge"></a>
    <a href="https://github.com/catppuccin/alacritty/issues"><img src="https://img.shields.io/github/issues/catppuccin/alacritty?colorA=363a4f&colorB=f5a97f&style=for-the-badge"></a>
    <a href="https://github.com/catppuccin/alacritty/contributors"><img src="https://img.shields.io/github/contributors/catppuccin/alacritty?colorA=363a4f&colorB=a6da95&style=for-the-badge"></a>
</p>

<p align="center">
  <img src="assets/screenshot.webp"/>
</p>


## Usage

1. Clone this repository next to your Alacritty config file (usually stored at `~/.config/alacritty/alacritty.toml`), with e.g.
```
git clone https://github.com/catppuccin/alacritty.git ~/.config/alacritty/catppuccin
```

2. Import the desired flavour config in your `alacritty.yml`:
```yaml
import:
  # uncomment the flavour you want below:
  - ~/.config/alacritty/catppuccin/catppuccin-mocha.yml
#  - ~/.config/alacritty/catppuccin/catppuccin-macchiato.yml
#  - ~/.config/alacritty/catppuccin/catppuccin-frappe.yml
#  - ~/.config/alacritty/catppuccin/catppuccin-latte.yml
```

## 🙋 FAQ

- Q: **_"Help! the colors don't look like in the demo while I'm on Tmux. What do I do?"_**
  A: The solution is two-fold. First, make sure you have the following set in `alacritty.yml`:

```yml
env:
  TERM: xterm-256color
```

Second, make sure you have the following in your `tmux.conf`:

```
set -g default-terminal "xterm-256color"
set-option -ga terminal-overrides ",xterm-256color:Tc"
```

Now you should be all set!

## 💝 Thanks to

- [VictorTennekes](https://github.com/VictorTennekes)
- [Andreas Grafen](https://github.com/andreasgrafen)

&nbsp;

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>
<p align="center">Copyright &copy; 2021-present <a href="https://github.com/catppuccin" target="_blank">Catppuccin Org</a>
<p align="center"><a href="https://github.com/catppuccin/catppuccin/blob/main/LICENSE"><img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=d9e0ee&colorA=363a4f&colorB=b7bdf8"/></a></p>
