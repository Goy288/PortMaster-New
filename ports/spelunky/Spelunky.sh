#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
export PORT_32BIT="Y"


[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/spelunky"
LIBDIR="$GAMEDIR/lib32"
BINDIR="$GAMEDIR/box86"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export DEVICE_ARCH="${DEVICE_ARCH:-armhf}"

# gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.armhf/libGL.so.1"
fi 

# system
export LD_LIBRARY_PATH="$LIBDIR:/usr/lib32:/usr/local/lib/arm-linux-gnueabihf/"

# box86
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_LD_LIBRARY_PATH="$LIBDIR"
export BOX86_PATH="$BINDIR"



$ESUDO chmod 666 /dev/uinput

$ESUDO sudo rm -rf ~/.config/SpelunkyClassicHD
ln -sfv $GAMEDIR/.config/SpelunkyClassicHD/ ~/.config

$GPTOKEYB "box86" -c "spelunky.gptk" & 

echo "Loading, please wait... (might take a while!)" > /dev/tty0
$BINDIR/box86 $GAMEDIR/spelunky

$ESUDO kill -9 $(pidof gptokeyb) & 
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
