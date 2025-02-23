#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh

# Source the colorscheme file
source "$HOME/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh"

### Sonokai
# export BLACK=0xff181819
# export WHITE=0xffe2e2e3
# export RED=0xfffc5d7c
# export GREEN=0xff9ed072
# export BLUE=0xff76cce0
# export YELLOW=0xffe7c664
# export ORANGE=0xfff39660
# export MAGENTA=0xffb39df3
# export GREY=0xff7f8490
# export TRANSPARENT=0x00000000
# export BG0=0xff2c2e34
# export BG1=0xff363944
# export BG2=0xff414550

#### Catppuccin
#export BLACK=0xff181926
#export WHITE=0xffcad3f5
#export RED=0xffed8796
#export GREEN=0xffa6da95
#export BLUE=0xff8aadf4
#export YELLOW=0xffeed49f
#export ORANGE=0xfff5a97f
#export MAGENTA=0xffc6a0f6
#export GREY=0xff939ab7
#export TRANSPARENT=0x00000000
#export BG0=0xff1e1e2e
#export BG0O50=0x801e1e2e
#export BG0O60=0x991e1e2e
#export BG0O70=0xB21e1e2e
#export BG0O80=0xCC1e1e2e
#export BG0O85=0xD91e1e2e
#export BG1=0x603c3e4f
#export BG2=0x60494d64

# # Eldritch Theme
# # https://github.com/eldritch-theme
# export BLACK=0xff181926
# export WHITE=0xffebfafa
# export RED=0xfff16c75
# export GREEN=0xff37f499
# export BLUE=0xff04d1f9
# export YELLOW=0xfff1fc79
# export ORANGE=0xfff7c67f
# export MAGENTA=0xffa48cf2
# export GREY=0xff323449
# export TRANSPARENT=0x00000000
# export BG0=0xff1e1e2e
# export BG0O50=0x801e1e2e
# export BG0O60=0x991e1e2e
# export BG0O70=0xB21e1e2e
# export BG0O80=0xCC1e1e2e
# # export BG0O85=0xD91e1e2e
# # export BG0O85=0xD9212337
# # This sets the color of the bar
# # Eldritch dark
# export BG0O85=0xCF0D1116
# # Eldritch light
# # export BG0O85=0xCF212337
# export BG1=0x603c3e4f
# export BG2=0x60494d64

# Linkarzu Theme
export BLACK=0xff${linkarzu_color10#\#}
export WHITE=0xff${linkarzu_color14#\#}
export RED=0xff${linkarzu_color11#\#}
export GREEN=0xff${linkarzu_color02#\#}
export BLUE=0xff${linkarzu_color03#\#}
export YELLOW=0xff${linkarzu_color12#\#}
export ORANGE=0xff${linkarzu_color04#\#}
export MAGENTA=0xff${linkarzu_color01#\#}
export GREY=0xff${linkarzu_color09#\#}
export TRANSPARENT=0x00000000
export BG0=0xff${linkarzu_color10#\#}
export BG0O50=0x80${linkarzu_color10#\#}
export BG0O60=0x99${linkarzu_color10#\#}
export BG0O70=0xb2${linkarzu_color10#\#}
export BG0O80=0xcc${linkarzu_color10#\#}
# export BG0O85=0xD91e1e2e
# export BG0O85=0xD9212337
# This sets the color of the bar
# Eldritch dark
export BG0O85=0x55${linkarzu_color10#\#}
# Eldritch light
# export BG0O85=0xCF212337
export BG1=0x60${linkarzu_color13#\#}
export BG2=0x60${linkarzu_color07#\#}

# General bar colors
export BAR_COLOR=$BG0O85
export BAR_BORDER_COLOR=$BG2
export BACKGROUND_1=$BG1
export BACKGROUND_2=$BG2
export ICON_COLOR=$WHITE  # Color of all icons
export LABEL_COLOR=$WHITE # Color of all labels
export POPUP_BACKGROUND_COLOR=$BAR_COLOR
export POPUP_BORDER_COLOR=$WHITE
export SHADOW_COLOR=$BLACK
