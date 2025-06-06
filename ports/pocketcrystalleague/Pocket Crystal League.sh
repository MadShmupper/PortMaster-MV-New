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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/pocketcrystalleague"
BIG_SCALE=4000
BIG_DELAY=8
SMALL_SCALE=6000
SMALL_DELAY=16

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Apply mouse scaling according to screen size
if [ $DISPLAY_WIDTH -gt 720 ]; then
    sed -i "s/^mouse_scale *= *[0-9]\+/mouse_scale = $BIG_SCALE/" "$GAMEDIR/pcl.gptk"
    sed -i "s/^mouse_delay *= *[0-9]\+/mouse_delay = $BIG_DELAY/" "$GAMEDIR/pcl.gptk"
else
    sed -i "s/^mouse_scale *= *[0-9]\+/mouse_scale = $SMALL_SCALE/" "$GAMEDIR/pcl.gptk"
    sed -i "s/^mouse_delay *= *[0-9]\+/mouse_delay = $SMALL_DELAY/" "$GAMEDIR/pcl.gptk"
fi

# If we have analog sticks for mouse controls then we can use the dpad for something else
if [ $ANALOG_STICKS -gt 1 ]; then
    sed -i -E 's/^up *= *.*/up = up/' "$GAMEDIR/pcl.gptk"
    sed -i -E 's/^down *= *.*/down = down/' "$GAMEDIR/pcl.gptk"
    sed -i -E 's/^left *= *.*/left = left/' "$GAMEDIR/pcl.gptk"
    sed -i -E 's/^right *= *.*/right = right/' "$GAMEDIR/pcl.gptk"
else
    sed -i -E 's/^up *= *.*/up = mouse_movement_up/' "$GAMEDIR/pcl.gptk"
    sed -i -E 's/^down *= *.*/down = mouse_movement_down/' "$GAMEDIR/pcl.gptk"
    sed -i -E 's/^left *= *.*/left = mouse_movement_left/' "$GAMEDIR/pcl.gptk"
    sed -i -E 's/^right *= *.*/right = mouse_movement_right/' "$GAMEDIR/pcl.gptk"
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "pcl.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish
