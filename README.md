# Contents

<!-- toc -->

- [Repo overview](#repo-overview)
- [How can you apply my dotfiles?](#how-can-you-apply-my-dotfiles)
- [In case you want to test out my Neobean config](#in-case-you-want-to-test-out-my-neobean-config)
- [Join the Discord server](#join-the-discord-server)
- [Follow me on social media](#follow-me-on-social-media)
- [You like my content and want to support me?](#you-like-my-content-and-want-to-support-me)
- [How do you manage your passwords?](#how-do-you-manage-your-passwords)
- [Some of my YouTube videos](#some-of-my-youtube-videos)
- [Point my `~/.zshrc` file to the desired repo](#point-my-zshrc-file-to-the-desired-repo)

<!-- tocstop -->

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
  macOS computer, you can, I have a
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

- This is the Neovim config you see me using on each one of my videos
- In case you want to test it out without modifying or changing your existing
  neovim config, run the `git clone` commands below to clone my dotfiles in your
  .config directory and we will run my config below

```bash
mkdir -p ~/.config
git clone git@github.com:linkarzu/dotfiles-latest ~/.config/linkarzu/dotfiles-latest
```

- Open the newly downloaded `neobean` config with:

```sh
NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim
```

- You can create an alias in your `.bashrc` or `.zshrc` file to run my config

```bash
alias neobean='NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim'
```

- Then to run this config, just run `neobean`

---

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

## Join the Discord server

- My discord server is now open to the public, feel free to join and hang out
  with others
- join the [discord server in this link](https://discord.gg/NgqMgwwtMH)

<div align="left">
    <a href="https://discord.gg/NgqMgwwtMH">
        <img
          src="./assets/img/imgs/250210-discord-free.avif"
          alt=" Join the discord server"
          width="400"
        />
    </a>
</div>

## Follow me on social media

- [Twitter (or "X")](https://x.com/link_arzu)
- [LinkedIn](https://www.linkedin.com/in/christianarzu)
- [TikTok](https://www.tiktok.com/@linkarzu)
- [Instagram](https://www.instagram.com/link_arzu)
- [GitHub](https://github.com/linkarzu)
- [Threads](https://www.threads.net/@link_arzu)
- [OnlyFans 🍆](https://linkarzu.com/assets/img/imgs/250126-whyugae.avif)
- [YouTube (subscribe MF, subscribe)](https://www.youtube.com/@linkarzu)
- [Ko-Fi](https://ko-fi.com/linkarzu/goal?g=6)

## You like my content and want to support me?

- I have a Ko-Fi page, you can
  [donate here](https://ko-fi.com/linkarzu/goal?g=6)

<div align="left">
    <a href="https://ko-fi.com/linkarzu/goal?g=6">
        <img
          src="./assets/img/imgs/250103-ko-fi-donate.avif"
          alt=" Support me in Ko-Fi "
          width="400"
        />
    </a>
</div>

## How do you manage your passwords?

- In case you want to support me, but don't want to donate, I have a 1password
  referral link, in which (in theory) I get a small amount in case you use it
- This helps me keep my blogpost ad free and helps me keep creating content
- I've tried many different password managers in the past, I've switched from
  `LastPass` to `Dashlane` and finally ended up in `1password`
- You want to find out why? More info in my article:
  - [How I use 1password to keep all my accounts safe](https://linkarzu.com/posts/1password/1password/)
- **`CLICK ON THE IMAGE BELOW TO START YOUR 14 DAY FREE TRIAL`**

<div align="left">
    <a href="https://www.dpbolvw.net/click-101327218-15917064">
        <img
          src="./assets/img/imgs/250124-1password-banner.avif"
          alt=" Start your 14 day free 1password trial "
          width="400"
        />
    </a>
</div>

## Some of my YouTube videos

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

[Advanced MINI.FILES Keymaps for Neovim – System Clipboard Integration and More](https://youtu.be/BzblG2eV8dU)

<div align="left">
    <a href=" https://youtu.be/BzblG2eV8dU ">
        <img
          src="./assets/img/imgs/minifiles-yazi.png"
          alt=" Advanced MINI.FILES Keymaps for Neovim – System Clipboard Integration and More "
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
