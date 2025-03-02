# Yabai settings

<!--toc:start-->

- [Yabai settings](#yabai-settings)
  - [disable SIP for yabai](#disable-sip-for-yabai)
  <!--toc:end-->

## Video related to this

- [Script to set up a Mac and Install Everything - Configure all the macOS System Settings via script](https://youtu.be/ZSLkyB-XYYQ)

<div align="left">
    <a href="https://youtu.be/ZSLkyB-XYYQ">
        <img
          src="../../../../assets/img/imgs/250301-thux-macos-install-script.avif"
          alt=" Script to set up a Mac and Install Everything - Configure all the macOS System Settings via script "
          width="400"
        />
    </a>
</div>

## Pre-requisites

- First disable SIP for yabai as instructed below
- You will be asked for your private SSH keys at some point to get access to
  your repos, so install 1password as the keys are there
- After these 2, run the
  `~/Library/Mobile Documents/com~apple~CloudDocs/github/macos-setup/mac/setup/010-firstTimeSetup.sh`
  file
  - Just go to it in finder, copy it's path, paste the path in a terminal with
    nothing else, and that's it

## disable SIP for yabai

System Integrity Protection protects some files and directories from being
modified — even from the root user. yabai needs System Integrity Protection to
be (partially) disabled so that it can ==inject a scripting addition into
Dock.app==, which owns the sole connection to the macOS window server. Many
features of yabai require this scripting addition to be running such that yabai
can modify windows, spaces and displays in a way that otherwise only Dock.app
could.

The following features of yabai require System Integrity Protection to be
**(partially)** disabled:

- focus/move/swap/create/destroy space
- remove window shadows
- enable window transparency
- enable window animations
- control window layers (make windows appear topmost or on the desktop)
- sticky windows (make windows appear on all spaces on the display that contains
  the window)
- toggle picture-in-picture for any given window

I'm on macos 14 at the moment, and have an Apple silicon computer, so will do
the following:

1. Turn off the computer
2. Turn it back on, but leave the power button pressed until you see "Loading
   startup options"
3. Then select `Options`
4. If you see a macOS Recovery screen asking you to enter the password, do that
5. Go to **Utilities - terminal** and type:

```bash
csrutil enable --without fs --without debug --without nvram
```

- You will see a message about an unsupported configuration and could break your
  machine so type `y`
- After this, reboot the computer for the changes to take effect

```bash
reboot
```

When the machine comes back up, in normal mode, you don't need to load startup
options, since mine is an apple silicon machine, enable non apple signed
binaries. Run the following in terminal:

```bash
sudo nvram boot-args=-arm64e_preview_abi
```

Then Reboot again

- When back, up, you can verify that System Integrity Protection is turned off
  by running `csrutil status`
- It may show `unknown` for newer versions of macOS when disabling SIP partially

```bash
csrutil status
```

```bash
krishna@chris-m1-mini~/github/dotfiles-latest on  main [!]
[06:45:20] $ csrutil status
System Integrity Protection status: unknown (Custom Configuration).

Configuration:
        Apple Internal: disabled
        Kext Signing: enabled
        Filesystem Protections: disabled
        Debugging Restrictions: disabled
        DTrace Restrictions: enabled
        NVRAM Protections: disabled
        BaseSystem Verification: enabled
        Boot-arg Restrictions: disabled
        Kernel Integrity Protections: enabled
        Authenticated Root Requirement: enabled

This is an unsupported configuration, likely to break in the future and leave your machine in an unknown state.
```

- If you ever want to re–enable System Integrity Protection after uninstalling
  yabai; repeat the steps above, but run `csrutil enable` at step 5
