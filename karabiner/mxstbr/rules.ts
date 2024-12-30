import fs from "fs";
import { KarabinerRules } from "./types";
import { createHyperSubLayers, app, open } from "./utils";

const rules: KarabinerRules[] = [
  // I've been using my pinky way too often for all they keyboard
  // shortcuts and after months, my hand is starting to hurt, moving the
  // hyper key from caps_lock to my thumb
  //
  // I tried using spacebar as the hyper key but cannot type well
  {
    description: "Hyper Key (⌃⌥⇧⌘)",
    manipulators: [
      {
        description: "right_command -> Hyper Key",
        from: {
          key_code: "right_command",
        },
        to: [
          {
            key_code: "left_shift",
            modifiers: ["left_command", "left_control", "left_option"],
          },
        ],
        // If right_command is pressed by itself, homerow will show up
        // Homerow configured under `Clicking - Shorctut`
        to_if_alone: [
          {
            key_code: "6",
            modifiers: [
              "left_command",
              "left_control",
              "left_option",
              "left_shift",
            ],
          },
          // {
          //   key_code: "escape",
          // },
        ],
        type: "basic",
      },
    ],
  },

  // // In case you want to use caps_lock as hyper
  // // This is the way I did it before
  // {
  //   description: "Caps Lock -> Hyper Key",
  //   manipulators: [
  //     {
  //       from: {
  //         key_code: "caps_lock",
  //       },
  //       to: [
  //         {
  //           key_code: "left_shift",
  //           modifiers: ["left_command", "left_control", "left_option"],
  //         },
  //       ],
  //       to_if_alone: [
  //         {
  //           key_code: "escape",
  //         },
  //       ],
  //       type: "basic",
  //     },
  //   ],
  // },

  // When I press caps_lock I want it to hit escape, but if I leave it
  // pressed, it will be used as shift
  {
    description: "caps_lock -> shift and escape",
    manipulators: [
      {
        from: {
          key_code: "caps_lock",
        },
        to: [
          {
            key_code: "left_shift",
          },
        ],
        to_if_alone: [
          {
            key_code: "escape",
          },
        ],
        type: "basic",
      },
    ],
  },

  // sometimes I press right_command+caps_lock by mistake and caps lock turn on,
  // and I don't want that
  // Notice that I set the modifier keys to all the keys that right_command
  // represents, tried using right_command and it never worked, even if I
  // put this above the hyper declaration
  {
    description: "right_command+caps_lock -> null",
    manipulators: [
      {
        from: {
          key_code: "caps_lock",
          modifiers: {
            // All of these are right_command
            mandatory: [
              "left_command",
              "left_control",
              "left_option",
              "left_shift",
            ],
          },
        },
        to: [],
        // to: [
        //   {
        //     key_code: "escape",
        //   },
        // ],
        type: "basic",
      },
    ],
  },

  {
    description: "right_option+caps_lock -> null",
    manipulators: [
      {
        from: {
          key_code: "caps_lock",
          modifiers: {
            mandatory: ["right_option"],
          },
        },
        to: [],
        // to: [
        //   {
        //     key_code: "escape",
        //   },
        // ],
        type: "basic",
      },
    ],
  },

  {
    description: "left_shift+caps_lock -> null",
    manipulators: [
      {
        from: {
          key_code: "caps_lock",
          modifiers: {
            mandatory: ["left_shift"],
          },
        },
        to: [],
        // to: [
        //   {
        //     key_code: "escape",
        //   },
        // ],
        type: "basic",
      },
    ],
  },

  {
    description: "left_command+caps_lock -> null",
    manipulators: [
      {
        from: {
          key_code: "caps_lock",
          modifiers: {
            mandatory: ["left_command"],
          },
        },
        to: [],
        // to: [
        //   {
        //     key_code: "escape",
        //   },
        // ],
        type: "basic",
      },
    ],
  },

  {
    description: "left_command -> cmd+c if pressed alone",
    manipulators: [
      {
        from: {
          key_code: "left_command",
        },
        to: [
          {
            key_code: "left_command",
          },
        ],
        to_if_alone: [
          {
            key_code: "c",
            modifiers: ["command"],
            // or if instead you want to execute a script or command
            // shell_command: `/opt/homebrew/bin/SwitchAudioSource -s "AirPods Pro"; /opt/homebrew/bin/SwitchAudioSource -t input -s "AirPods Pro"`,
            //
            // You could also call a betterTouchTool action
          },
        ],
        type: "basic",
      },
    ],
  },

  {
    description: "left_shift -> prefix+space in tmux for alternate session",
    manipulators: [
      {
        from: {
          key_code: "left_shift",
        },
        to: [
          {
            key_code: "left_shift",
          },
        ],
        to_if_alone: [
          {
            shell_command:
              "open btt://execute_assigned_actions_for_trigger/?uuid=F35EF770-FAA5-448A-957D-70BB449DEB0F",
          },
        ],
        type: "basic",
      },
    ],
  },

  {
    description: "right_shift -> Mute microphone",
    manipulators: [
      {
        from: {
          key_code: "right_shift",
        },
        to: [
          {
            key_code: "right_shift",
          },
        ],
        to_if_alone: [
          {
            shell_command: `~/github/dotfiles-latest/scripts/macos/mac/200-micMute.sh`,
          },
        ],
        type: "basic",
      },
    ],
  },

  {
    description: "left_option -> cmd+v if pressed alone",
    manipulators: [
      {
        from: {
          key_code: "left_option",
        },
        to: [
          {
            key_code: "left_option",
          },
        ],
        to_if_alone: [
          {
            key_code: "v",
            modifiers: ["command"],
          },
        ],
        type: "basic",
      },
    ],
  },

  {
    description: "left_ctrl -> cmd+tab if pressed alone",
    manipulators: [
      {
        from: {
          key_code: "left_control",
        },
        to: [
          {
            key_code: "left_control",
          },
        ],
        to_if_alone: [
          {
            key_code: "tab",
            modifiers: ["command"],
          },
        ],
        type: "basic",
      },
    ],
  },

  // This is fucking genius, I'm always switching between the last 3 apps
  // I have a glove80 and I never use the left or right arrows
  {
    description: "left_arrow -> cmd+tab+tab",
    manipulators: [
      {
        from: {
          key_code: "left_arrow",
        },
        to: [
          {
            key_code: "tab",
            modifiers: ["command"],
          },
          {
            key_code: "tab",
            modifiers: ["command"],
          },
        ],
        type: "basic",
      },
    ],
  },

  {
    description: "down_arrow -> tmux 3rd session",
    manipulators: [
      {
        from: {
          key_code: "down_arrow",
        },
        to: [
          {
            shell_command:
              "open btt://execute_assigned_actions_for_trigger/?uuid=79CE855A-4DEA-4340-9878-4C33328B6B85",
          },
        ],
        type: "basic",
      },
    ],
  },

  {
    description: "up_arrow -> tmux visual mode",
    manipulators: [
      {
        from: {
          key_code: "up_arrow",
        },
        to: [
          {
            shell_command:
              "open btt://execute_assigned_actions_for_trigger/?uuid=F789C9F8-0F29-4922-9179-BFE03D226176",
          },
        ],
        type: "basic",
      },
    ],
  },

  {
    description: "right_arrow -> sticky notes",
    manipulators: [
      {
        from: {
          key_code: "right_arrow",
        },
        to: [
          {
            shell_command: "open -a 'kitty.app'",
          },
        ],
        type: "basic",
      },
    ],
  },

  // this is useful to hit enter after pasting text using the left hand
  {
    description: "left_option + spacebar -> enter",
    manipulators: [
      {
        from: {
          key_code: "spacebar",
          modifiers: {
            mandatory: ["left_option"],
          },
        },
        to: [
          {
            key_code: "return_or_enter",
          },
        ],
        type: "basic",
      },
    ],
  },

  // // This is used as a homerow app shortcut
  // {
  //   description: "right_control -> homerow 2",
  //   manipulators: [
  //     {
  //       from: {
  //         key_code: "right_control",
  //       },
  //       to: [
  //         {
  //           key_code: "right_control",
  //         },
  //       ],
  //       to_if_alone: [
  //         {
  //           key_code: "spacebar",
  //           modifiers: ["left_command", "left_option"],
  //         },
  //       ],
  //       type: "basic",
  //     },
  //   ],
  // },

  // // This is used as a homerow app shortcut
  // {
  //   description: "right_option -> homerow 3",
  //   manipulators: [
  //     {
  //       from: {
  //         key_code: "right_option",
  //       },
  //       to: [
  //         {
  //           key_code: "right_option",
  //         },
  //       ],
  //       to_if_alone: [
  //         {
  //           key_code: "delete_or_backspace",
  //           modifiers: ["left_command", "left_option"],
  //         },
  //       ],
  //       type: "basic",
  //     },
  //   ],
  // },

  // I couldn't get this work with the magic mouse because it only detects button1 in the karabiner event viewer
  // You need to enable pro mode in karabiner for the work with the apple mouse
  // It works with the logitech mouse tough
  // {
  //   description: "Simultaneous Left and Right Click to Cmd+Shift+S",
  //   manipulators: [
  //     {
  //       type: "basic",
  //       parameters: {
  //         "basic.simultaneous_threshold_milliseconds": 500
  //       },
  //       from: {
  //         simultaneous: [
  //           { "pointing_button": "button1" },
  //           { "pointing_button": "button2" }
  //         ],
  //         simultaneous_options: {
  //           detect_key_down_uninterruptedly: true,
  //           key_down_order: "strict",
  //           key_up_order: "strict",
  //           key_up_when: "all"
  //         }
  //       },
  //       to: [
  //         {
  //           key_code: "s",
  //           modifiers: ["left_command", "left_shift"]
  //         },
  //       ],
  //     },
  //   ],
  // },

  ...createHyperSubLayers({
    // All the following combinations require the "hyper" key as well
    a: {
      h: app("Spotify"),
      // j: app("Alacritty"),
      // j: app("WezTerm"),
      j: app("Ghostty"),
      k: app("Zen Browser"),
      // k: app("Google Chrome"),
      // l: app("Obsidian"),
      // semicolon: app("ChatGPT"),
      semicolon: app("Claude"),
      quote: app("System Settings"),
      y: app("YouTube"),
      u: app("WhatsApp Web"),
      i: app("Slack"),
      // o: app("Preview"),
      o: app("OBS"),
      b: app("Brave Browser"),
      open_bracket: app("Reminders"),
      n: app("Neovide"),
      m: app("Mail"),
      s: app("Udemy Business"),
      d: app("Discord"),
      p: app("1Password"),
      // f: app("Finder"),
      f: app("ForkLift"),
      g: app("Udemy"),
      q: app("Setapp"),
      w: app("Microsoft Word"),
      e: app("Microsoft Excel"),
      r: app("Recut"),
      6: app("Windows App"),
      // r: app("Windows App"),
      // t: app("Claude"),
      5: app("DaVinci Resolve"),
      x: app("GoTo"),
      c: app("Microsoft Outlook"),
      v: app("zoom.us"),

      // Below I'm just leaving comments of the shortcuts I specifically use on
      // apps in case I need to configure them on a new computer
      // hyper+w - paste - activate paste
      // hyper+p - cleanshot x OCR capture text
      // hyper+` - cleanshot x record screen
      // hyper+1 - paste - activate paste stack
      // hyper+2 - betterdisplay fav res 1
      // hyper+3 - betterdisplay fav res 2
      // hyper+4 - betterdisplay input hdmi
      // hyper+5 - betterdisplay input usbc
      // hyper+6 - homerow clicking shortcut
      // hyper+7 - cleanshot x close all overlays
      // hyper+8 - hand mirror
      // hyper+9 - cleanshot x capture previous area
      // hyper+0 - cleanshot x capture area
      // hyper+- - cleanshot x capture window
      // hyper+= - cleanshot x capture area & annotate
      // hyper+tab - cleanshot capture history
      // hyper+] - keycastr toggle casting
    },

    // t = "tmux" - I use these to navigate to my different tmux sessions
    // video that explains how this works using prime's tmux-sessionizer script
    // https://youtu.be/MCbEPylDEWU
    t: {
      // home
      h: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=F431526A-E836-451C-BD36-67AB7DF7CAC2"
      ),
      // dotfiles-latest
      j: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=E2BEB425-38A3-46D8-AAF8-067CA979D4FB"
      ),
      // watusy
      k: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=7B386F00-BDBD-448F-A413-E37952E219A7"
      ),
      // linkarzu.github.io
      l: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=1893BEBE-DC99-41CC-9BE6-74B66E3BBB2C"
      ),
      // scripts
      semicolon: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=9E98F83C-C4C4-4B9B-AFF7-03AAAF2939A5"
      ),
      // containerdata
      y: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=27E17BF8-1B16-41BF-A7C1-3DAF6B706340"
      ),
      // containerdata_nfs
      p: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=55A10BEE-B776-4D93-B5ED-024A58595D93"
      ),
      // obsidian_main
      u: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=2FF1FD5D-72C2-42CA-B6AD-05A4DC3CEE0C"
      ),
      // php
      i: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=03F1E256-FF80-43BA-873C-195628FA5996"
      ),
      // containerdata-public
      o: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=13ED33CA-99DF-4782-BDA6-E01BF3FF0DCC"
      ),
      // Find
      n: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=92398D5C-B95F-4E31-9CB9-1E3E732AF1C0"
      ),
      // Find goto
      m: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=88FB8FF9-6237-45FE-8717-675540891749"
      ),
      // daily note
      r: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=9B82DF9D-2DE2-4872-903A-D3C17EE9D555"
      ),
      // // I tried to replace BetterTouchTool by directly calling the script,
      // // but couldn't make it work
      // r: {
      //   to: [
      //     {
      //       shell_command: `~/github/dotfiles-latest/scripts/macos/mac/300-dailyNote.sh`,
      //     },
      //   ],
      // },
      // open karabiner rules.ts file
      e: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=3DEAE844-CD5B-4695-A58D-AC7CFA935D46"
      ),
      // Golang dir
      open_bracket: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=70963A3C-7982-4BB4-A8E0-5181EC216383"
      ),
    },

    // e = "etmux" - This is to SSH to devices
    // video that explains how this works below
    // https://youtu.be/MCbEPylDEWU
    e: {
      // xocli3
      h: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=96CE1FAA-A4BF-417B-A84F-E9F3F2001A8D"
      ),
      // docker3
      j: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=665FFAF0-6D73-4AB4-BFC3-B04E898EC780"
      ),
      // storage3
      k: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=540F20B2-E003-4614-B3EE-8E5B4A350AF9"
      ),
      // prodkubecp3
      l: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=DD15014A-15E2-40BF-995D-7B620B96029C"
      ),
      // prodkubew3
      semicolon: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=445A9DDB-7484-45D5-AD9D-9933FAFD5BAC"
      ),
      // dns3
      i: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=8F06BCEE-5333-4D3E-8E8F-7863C5346C75"
      ),
      // lb3
      u: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=37BA1985-1C6B-43E3-BB2C-ADBA3B581929"
      ),
      // Find
      n: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=6C578F42-B350-46B1-A7BE-D1869A081B86"
      ),
      // ~/.ssh/config find
      r: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=B649548D-C750-408D-97E8-74F58B7F504D"
      ),
    },

    // r = "Raycast"
    r: {
      j: open("raycast://extensions/lardissone/raindrop-io/search"),
      k: open("raycast://extensions/mblode/google-search/index"),
      l: open("raycast://extensions/raycast/navigation/switch-windows"),
      semicolon: open("raycast://extensions/vishaltelangre/google-drive/index"),
      quote: open("raycast://extensions/mathieudutour/wolfram-alpha/index"),
      y: open(
        "raycast://extensions/tonka3000/youtube/search-videos?arguments=%7B%22query%22%3A%22%22%7D"
      ),
      u: open("raycast://extensions/raycast/apple-reminders/create-reminder"),
      i: open("raycast://extensions/raycast/apple-reminders/my-reminders"),
      o: open("raycast://extensions/raycast/github/search-repositories"),
      p: open("raycast://extensions/nhojb/brew/search"),
      h: open("raycast://extensions/mattisssa/spotify-player/search"),
    },

    // s = "System" or "Service"
    s: {
      j: {
        to: [
          {
            key_code: "volume_decrement",
          },
        ],
      },
      k: {
        to: [
          {
            key_code: "volume_increment",
          },
        ],
      },
      // Move to left (or up) tab in browsers
      h: {
        to: [
          {
            key_code: "open_bracket",
            modifiers: ["left_command", "left_shift"],
          },
        ],
      },
      // Move to right (or down) tab in browsers
      l: {
        to: [
          {
            key_code: "close_bracket",
            modifiers: ["left_command", "left_shift"],
          },
        ],
      },
      u: {
        to: [
          {
            key_code: "display_brightness_decrement",
          },
        ],
      },
      i: {
        to: [
          {
            key_code: "display_brightness_increment",
          },
        ],
      },
      // Previous song
      y: {
        to: [
          {
            key_code: "rewind",
          },
        ],
      },
      // Next song
      o: {
        to: [
          {
            key_code: "fastforward",
          },
        ],
      },
      p: {
        to: [
          {
            key_code: "play_or_pause",
          },
        ],
      },
      // Close browser tab
      e: {
        to: [
          {
            key_code: "w",
            modifiers: ["left_command"],
          },
        ],
      },
      // BetterTouchTool, connect airpods via bluetooth
      n: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=9A1CFA49-416C-480E-9430-184D2DAEE1CA"
      ),
      // Change audio source to airpods
      m: {
        to: [
          {
            shell_command: `/opt/homebrew/bin/SwitchAudioSource -s "AirPods Pro"; /opt/homebrew/bin/SwitchAudioSource -t input -s "AirPods Pro"`,
          },
        ],
      },
      // Start video recording
      8: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=24E07831-252B-4EB6-B6C4-5E1CDB742BF9"
      ),
      // Stop video recording
      9: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=762AF6E2-41EE-4B74-A2D3-9B96C3D777B5"
      ),
      // Tmux Banner on
      open_bracket: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=4A96B03E-D791-46AD-9B02-7FC9E75B208C"
      ),
      // Tmux Banner off
      close_bracket: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=93EDAFA4-0043-4945-8242-082DCC7788BC"
      ),
      // comma: {
      //   to: [
      //     {
      //       shell_command: `/opt/homebrew/bin/SwitchAudioSource -s "LG TV"; /opt/homebrew/bin/SwitchAudioSource -t input -s "C922 Pro Stream Webcam"`,
      //     },
      //   ],
      // },
      // Change audio source to mac mini
      comma: {
        to: [
          {
            shell_command: `/opt/homebrew/bin/SwitchAudioSource -s "Mac mini Speakers"; /opt/homebrew/bin/SwitchAudioSource -t input -s "C922 Pro Stream Webcam"`,
          },
        ],
      },
      // Change audio source to macbook pro Speakers
      period: {
        to: [
          {
            shell_command: `/opt/homebrew/bin/SwitchAudioSource -s "MacBook Pro Speakers"; /opt/homebrew/bin/SwitchAudioSource -t input -s "MacBook Pro Microphone"`,
          },
        ],
      },
      // n: open(
      //   "raycast://extensions/VladCuciureanu/toothpick/connect-favorite-device-1"
      // ),
    },

    u: {
      // Lock screen
      i: {
        to: [
          {
            key_code: "q",
            modifiers: ["right_control", "right_command"],
          },
        ],
      },
      // Restart yabai
      // 0: open(
      //   "btt://execute_assigned_actions_for_trigger/?uuid=5EC0D2D3-869C-4284-B063-B53A17BF7C4C"
      // ),
      // Restart yabai
      o: {
        to: [
          {
            // shell_command: `/opt/homebrew/bin/yabai --restart-service`,
            shell_command: `~/github/dotfiles-latest/yabai/yabai_restart.sh`,
          },
        ],
      },
      // Dismiss notifications on macos
      k: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=92B63395-5930-463A-9301-57BA344D6981"
      ),
    },

    // c = "colorscheme selector"
    c: {
      // execute the colorscheme selector script
      n: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=6793CE15-C70A-43E7-ADA9-479DF1539A39"
      ),
    },

    // For betterTouchTool
    d: {
      // Terminal select last command
      j: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=5A708885-4D65-465C-B87A-996BA6C23B86"
      ),
      // Paste alacritty text and go down
      k: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=5AF2559D-E6C9-4665-8D06-2CAF35B1AB07"
      ),
      // Paste alacritty text and go up
      l: open(
        // This one is working great
        // paste alacritty go up LESS DELAY
        "btt://execute_assigned_actions_for_trigger/?uuid=E46BB0D5-F67F-46D5-850C-197337EB26E3"
      ),
      // Reboot router
      u: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=EA461EE0-4C15-4113-93B6-07C12086FF1F"
      ),
      // Test ping
      hyphen: open(
        "btt://execute_assigned_actions_for_trigger/?uuid=EADC365D-0747-4E8F-ACB6-79564FEF1410"
      ),
    },

    // shift+arrows to select stuff
    v: {
      h: {
        to: [{ key_code: "left_arrow", modifiers: ["left_shift"] }],
      },
      j: {
        to: [{ key_code: "down_arrow", modifiers: ["left_shift"] }],
      },
      k: {
        to: [{ key_code: "up_arrow", modifiers: ["left_shift"] }],
      },
      l: {
        to: [{ key_code: "right_arrow", modifiers: ["left_shift"] }],
      },
      y: {
        to: [
          { key_code: "left_arrow", modifiers: ["left_shift", "left_option"] },
        ],
      },
      u: {
        to: [
          { key_code: "down_arrow", modifiers: ["left_shift", "left_option"] },
        ],
      },
      i: {
        to: [
          { key_code: "up_arrow", modifiers: ["left_shift", "left_option"] },
        ],
      },
      o: {
        to: [
          { key_code: "right_arrow", modifiers: ["left_shift", "left_option"] },
        ],
      },
      // // Magicmove via homerow.app
      // m: {
      //   to: [{ key_code: "f", modifiers: ["right_control"] }],
      // },
      // // Scroll mode via homerow.app
      // s: {
      //   to: [{ key_code: "j", modifiers: ["right_control"] }],
      // },
    },

    left_command: {
      // Change MX Vertical mouse to mac mini
      4: {
        to: [
          {
            shell_command: `~/github/dotfiles-latest/hidapitester/hidapitester --vidpid 046D:B020 --usagePage 0xFF43 --usage 0x0202 --open --length 20 --send-output 0x11,0x00,0x0C,0x1C,0x00`,
          },
        ],
      },
      // Change MX Vertical  mouse to macbook pro
      5: {
        to: [
          {
            shell_command: `~/github/dotfiles-latest/hidapitester/hidapitester --vidpid 046D:B020 --usagePage 0xFF43 --usage 0x0202 --open --length 20 --send-output 0x11,0x00,0x0C,0x1C,0x01`,
          },
        ],
      },
      // Pull github repos
      // I tried with the number 6 instead of "J" but didn't work, seems to have been a
      // conflict maybe with another app
      j: {
        to: [
          {
            shell_command: `~/github/scripts/macos/mac/360-pullGitRepos.sh`,
          },
        ],
      },
    },

    // // copy, paste and other stuff
    // g: {
    //   // // I use this for fzf
    //   // r: {
    //   //   to: [{ key_code: "r", modifiers: ["left_control"] }],
    //   // },
    //   // t: {
    //   //   to: [{ key_code: "t", modifiers: ["left_control"] }],
    //   // },
    //   // Slack go to all unreads
    //   a: {
    //     to: [{ key_code: "a", modifiers: ["left_command", "left_shift"] }],
    //   },
    //   h: {
    //     to: [{ key_code: "delete_or_backspace" }],
    //   },
    //   l: {
    //     to: [{ key_code: "delete_forward" }],
    //   },
    //   // Switch between windows of same app, normally cmd+~
    //   spacebar: {
    //     to: [
    //       { key_code: "grave_accent_and_tilde", modifiers: ["left_command"] },
    //     ],
    //   },
    // },

    // // 'e' for extra tools
    // e: {
    //   // To edit the contents of an excel cell
    //   u: {
    //     to: [{ key_code: "f2" }],
    //   },
    //   // Focus outline in obsidian
    //   o: {
    //     to: [{ key_code: "x", modifiers: ["left_command", "left_shift"] }],
    //   },
    //   // Increase LG TV volume
    //   k: {
    //     to: [
    //       {
    //         shell_command: `~/opt/lgtv/bin/python3 ~/opt/lgtv/bin/lgtv MyTV volumeUp ssl`,
    //       },
    //     ],
    //   },
    //   // Decrease LG TV volume
    //   j: {
    //     to: [
    //       {
    //         shell_command: `~/opt/lgtv/bin/python3 ~/opt/lgtv/bin/lgtv MyTV volumeDown ssl`,
    //       },
    //     ],
    //   },
    // },

    // ALWAYS LEAVE THE ONES WITHOUT ANY SUBLAYERS AT THE BOTTOM
    // Vim nagivation
    h: {
      to: [{ key_code: "left_arrow" }],
    },
    j: {
      to: [{ key_code: "down_arrow" }],
    },
    k: {
      to: [{ key_code: "up_arrow" }],
    },
    l: {
      to: [{ key_code: "right_arrow" }],
    },
    // Map hyper+f to ctrl+b for tmux
    f: {
      to: [{ key_code: "b", modifiers: ["left_control"] }],
    },
    // copy, paste and other stuff
    // y: {
    //   // Switch between windows of same app, normally cmd+~
    //   to: [{ key_code: "tab", modifiers: ["left_command"] }],
    // },
    // 6: {
    //   // Switch between windows of same app, normally cmd+~
    //   to: [{ key_code: "grave_accent_and_tilde", modifiers: ["left_command"] }],
    // },
  }),
];

fs.writeFileSync(
  "karabiner.json",
  JSON.stringify(
    {
      global: {
        show_in_menu_bar: false,
      },
      profiles: [
        {
          complex_modifications: {
            rules,
          },
          fn_function_keys: [
            {
              from: { key_code: "f6" },
              to: [{ consumer_key_code: "rewind" }],
            },
            {
              from: { key_code: "f7" },
              to: [{ consumer_key_code: "play_or_pause" }],
            },
            {
              from: { key_code: "f8" },
              to: [{ consumer_key_code: "fast_forward" }],
            },
            {
              from: { key_code: "f9" },
              to: [{ consumer_key_code: "volume_decrement" }],
            },
            {
              from: { key_code: "f10" },
              to: [{ consumer_key_code: "volume_increment" }],
            },
            {
              from: { key_code: "f11" },
              to: [{ key_code: "f11" }],
            },
            {
              from: { key_code: "f12" },
              to: [{ key_code: "f12" }],
            },
          ],
          name: "Default",
          selected: true,
          virtual_hid_keyboard: { keyboard_type_v2: "ansi" },
        },
      ],
    },
    null,
    2
  )
);
