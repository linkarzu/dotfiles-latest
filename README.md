# Contents

<!-- toc -->

- [Contributing](#contributing)
- [Repo overview](#repo-overview)
- [How can you apply my dotfiles?](#how-can-you-apply-my-dotfiles)
- [In case you want to test out my Neobean config](#in-case-you-want-to-test-out-my-neobean-config)
  * [Install Neobean config](#install-neobean-config)
  * [Remove Neobean config](#remove-neobean-config)
  * [Video to set up multiple distros](#video-to-set-up-multiple-distros)
- [You're a fraud, why do you ask for money, isn't YouTube Ads enough?](#youre-a-fraud-why-do-you-ask-for-money-isnt-youtube-ads-enough)
- [Some of my YouTube videos](#some-of-my-youtube-videos)
- [Point my `~/.zshrc` file to the desired repo](#point-my-zshrc-file-to-the-desired-repo)

<!-- tocstop -->

## Contributing

<!-- markdownlint-disable -->
<!-- prettier-ignore-start -->

<!-- tip=green, info=blue, warning=yellow, danger=red -->

<br>

> [!IMPORTANT]
> - Please. Do not submit PRs, they won't be reviewed or accepted.

<!-- prettier-ignore-end -->
<!-- markdownlint-restore -->

- I have accepted a single PR in the past, it was literally to fix a typo and I
  thought I would be OK with PRs, but that no longer will be the case.
- Link, but why are you being such a bitch? We're just trying to help
  - I'm busy enough already with my day job, family, scheduling interviews,
    creating content, thumbnails, editing videos, sharing stuff, doom scrolling,
    and don't want to deal with reviewing PRs, testing stuff, understanding it,
    etc.
  - Keep in mind that these are my personal dotfiles, so if something stops
    working for me, I'll review it and fix it when I have the time.
  - So my advise is, grab the bits and pieces you like about my dots, and fix
    whatever does not work, in your own dots.
- Having said all that, I do agree to discussions, because they not only help
  me, but help others as well. I don't promise I will accept the suggestions
  though, but I'll try to read them.

## Repo overview

- This repo is where I keep the dotfiles I'm currently using
- My daily driver OS is macOS and my editor of choice is Neovim.
- My OS is highly customized and adapted to my workflow, I use several open
  source and non open source tools, including Ghostty, tmux, Karabiner-Elements,
  CleanShot X, etc, etc
- If you don't understand something found in my dotfiles, I probably have
  detailed YouTube video explaining everything, just search in my
  [YouTube channel](https://www.youtube.com/@linkarzu)
- Sneak peek of my setup below

<div align="left">
  <img
    src="./assets/img/imgs/250221-macos-looks-feb25.avif"
    alt="How my macOS looks as of Feb 2025 "
    width="800"
  />
</div>

<!-- markdownlint-disable -->
<!-- prettier-ignore-start -->
 
<!-- tip=green, info=blue, warning=yellow, danger=red -->
 
<br>

> [!WARNING]
> - There is an old repo: [linkarzu/dotfiles-public](https://github.com/linkarzu/dotfiles-public)
>   - That is referenced in my youtube [2024 macos workflow video series](https://youtube.com/playlist?list=PLZWMav2s1MZTanWwNKYvS8qgwl0HBH9J-&si=q6ByPmN8I7SOBKmX)
>   - **That old repo is still valid for that playlist, but is no longer
>     maintained, so for the latest updates, use this current repo instead**

<!-- prettier-ignore-end -->
<!-- markdownlint-restore -->

## How can you apply my dotfiles?

- The idea is that you to scavenge around, find the things that are useful to
  you, and apply them to your own config
- In case you actually want to apply my entire dotfiles settings on your own
  macOS computer, you can. I have a
  [blogpost article](https://linkarzu.com/posts/2024-macos-workflow/clone-dotfiles/)
  in which I describe the process and a video as well (This is one of my first
  videos, but it still works)

<div align="left">
     <a href="https://youtu.be/XBjfzySpGdE">
         <img
           src="https://res.cloudinary.com/daqwsgmx6/image/upload/v1706358848/youtube/2024-macos-workflow/04-dotfiles-playback"
           alt="04 - What are dotfiles and how to clone them"
           width="400"
         />
     </a>
 </div>

## In case you want to test out my Neobean config

### Install Neobean config

- This is the Neovim config you see me using on each one of my videos
- In case you want to test it out without modifying or changing your existing
  neovim config, run the `git clone` commands below to clone my dotfiles in your
  `.config` directory and we will run my config below

```bash
mkdir -p ~/.config
git clone git@github.com:linkarzu/dotfiles-latest ~/.config/linkarzu/dotfiles-latest
```

- Open the newly downloaded `neobean` config with:

```sh
NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim
```

- When you open this, you will see everything red as seen on the image below
- Don't panic, this is normal, just press enter several times when you see the
  `-- More --` at the bottom
- Then restart Neovim a couple of times and you'll be good

<div align="left">
  <img
    src="./assets/img/imgs/250813-open-neobean.avif"
    alt="How my macOS looks as of Feb 2025 "
    width="800"
  />
</div>

- When you open a file, Mason is probably going to install several packages the
  first time, that's also normal

---

- You can create an alias in your `.bashrc` or `.zshrc` file to run my config

```bash
alias neobean='NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim'
```

- Then to run this config, just run `neobean`

### Remove Neobean config

- In case you want to clean up the config after testing it

```bash
rm -rf ~/.config/linkarzu
rm -rf ~/.local/share/linkarzu
rm -rf ~/.local/state/linkarzu
rm -rf ~/.cache/linkarzu
```

### Video to set up multiple distros

- I have a video in which I show you how to download and setup my `neobean`
  config, but also other neovim distributions, so I highly recommend you check
  it out:
  - [Download and test multiple Neovim distros and configurations - Without affecting your current config](https://youtu.be/xN1hdY1cc3E)

<div align="left">
    <a href="https://youtu.be/xN1hdY1cc3E">
        <img
          src="./assets/img/imgs/250220-thux-multiple-neovim-distros.avif"
          alt=" Download and test multiple Neovim distros and configurations - Without affecting your current config "
          width="400"
        />
    </a>
</div>

## You're a fraud, why do you ask for money, isn't YouTube Ads enough?

- I explain all of this in the "about me page" link below:
  - [youre-a-fraud-why-do-you-ask-for-money-isnt-youtube-ads-enough](https://linkarzu.com/about/#youre-a-fraud-why-do-you-ask-for-money-isnt-youtube-ads-enough){:target="\_blank"}
  - Above you'll also find links to my discord, social media, etc

## Some of my YouTube videos

[Neovim vs Emacs | Roundtable w/ TJ DeVries, DistroTube, Greg Anders & Joshua Blais](https://youtu.be/SnhcXR9CKno)

<div align="left">
    <a href=" https://youtu.be/SnhcXR9CKno ">
        <img
          src="./assets/img/imgs/250813-neovim-vs-emacs.avif"
          alt=" Neovim vs Emacs | Roundtable w/ TJ DeVries, DistroTube, Greg Anders & Joshua Blais "
          width="400"
        />
    </a>
</div>

---

[The Power User's 2025 Guide to macOS ricing - Yabai, Simple-bar, SketchyBar, Fastfetch, Btop & More](https://youtu.be/8pqFtkQip4I)

<div align="left">
    <a href=" https://youtu.be/8pqFtkQip4I ">
        <img
          src="./assets/img/imgs/250120-macos-ricing-link.avif"
          alt=" The Power User's 2025 Guide to macOS ricing | Yabai, Simple-bar, SketchyBar, Fastfetch, Btop & More "
          width="400"
        />
    </a>
</div>

---

[How I Recreated (and Improved) My Obsidian Note-Taking Workflow in Neovim](https://youtu.be/k_g8q5JeisY)

<div align="left">
    <a href=" https://youtu.be/k_g8q5JeisY ">
        <img
          src="./assets/img/imgs/250220-thux-neovim-like-obsidian.avif"
          alt=" How I Recreated (and Improved) My Obsidian Note-Taking Workflow in Neovim "
          width="400"
        />
    </a>
</div>

---

[Images in Neovim - Setting up Snacks Image and Comparing it to Image.nvim](https://youtu.be/G27MHyT-u2I)

<div align="left">
    <a href=" https://youtu.be/G27MHyT-u2I ">
        <img
          src="./assets/img/imgs/250218-thux-snacks-image.avif"
          alt=" Images in Neovim | Setting up Snacks Image and Comparing it to Image.nvim "
          width="400"
        />
    </a>
</div>

---

[Why I'm Moving from Telescope to Snacks Picker - Why I'm not Using fzf-lua - Frecency feature](https://youtu.be/7hEWG3GP6m0)

<div align="left">
    <a href=" https://youtu.be/7hEWG3GP6m0 ">
        <img
          src="./assets/img/imgs/250210-thux-snacks-picker.avif"
          alt=" Why I'm Moving from Telescope to Snacks Picker | Why I'm not Using fzf-lua | Frecency feature "
          width="400"
        />
    </a>
</div>

---

[From macOS Chaos to Primeagen Workflow | Neovim, Tmux, Yabai](https://youtu.be/ckBs1Z9KCT4)

<div align="left">
    <a href=" https://youtu.be/ckBs1Z9KCT4 ">
        <img
          src="./assets/img/imgs/250813-primeagen-workflow.avif"
          alt=" From macOS Chaos to Primeagen Workflow | Neovim, Tmux, Yabai "
          width="400"
        />
    </a>
</div>

---

[My complete Neovim markdown setup and workflow in 2025](https://youtu.be/1YEbKDlxfss)

<div align="left">
    <a href=" https://youtu.be/1YEbKDlxfss ">
        <img
          src="./assets/img/imgs/250220-neovim-workflow-2025.avif"
          alt=" My complete Neovim markdown setup and workflow in 2025 "
          width="400"
        />
    </a>
</div>

---

[Ghostty Shaders - Ghostty config file syntax highlighting - glsl treesitter - glsl_analyzer](https://youtu.be/yJDn__NhOqI)

<div align="left">
    <a href=" https://youtu.be/yJDn__NhOqI ">
        <img
          src="./assets/img/imgs/250220-thux-ghostty-shaders.avif"
          alt=" Ghostty Shaders | Ghostty config file syntax highlighting | glsl treesitter | glsl_analyzer "
          width="400"
        />
    </a>
</div>

---

[Neovim or Neovide, what is the difference?](https://youtu.be/cY1KSeIkQCs)

<div align="left">
    <a href="https://youtu.be/cY1KSeIkQCs">
        <img
          src="https://res.cloudinary.com/daqwsgmx6/image/upload/q_75/v1717456413/youtube/neovim/neovim-vs-neovide.avif"
          alt="Neovim or Neovide, what is the difference?"
          width="400"
        />
    </a>
</div>

---

[Why I switched from Alacritty to kitty, and how to configure kitty](https://youtu.be/MZNvjclifD8)

<div align="left">
    <a href="https://youtu.be/MZNvjclifD8">
        <img
          src="https://res.cloudinary.com/daqwsgmx6/image/upload/q_75/v1719362711/youtube/macos/alacritty-to-kitty.avif"
          alt="Why I switched from Alacritty to kitty, and how to configure kitty"
          width="400"
        />
    </a>
</div>

## Point my `~/.zshrc` file to the desired repo

<!-- prettier-ignore -->
> [!NOTE]
> These instructions are for me, GTFO

- Commands below will create all the files if they don't yet exist, if they do,
  it will update them.
- `-n` allows the link to be treated as a normal file if it is a symlink to a
  directory
- `-f` "force" overwrites without warning if it already exists

```bash
ln -snf ~/github/dotfiles-latest/zshrc/zshrc-file.sh ~/.zshrc >/dev/null 2>&1
source ~/.zshrc
```

```bash
# This is on the other repo where I keep my ssh config files
ln -snf ~/github/dotfiles/sshconfig-pers ~/.ssh/config >/dev/null 2>&1
```
