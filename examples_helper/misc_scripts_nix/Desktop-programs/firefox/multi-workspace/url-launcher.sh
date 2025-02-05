#! /usr/bin/env bash
desktop=$(xprop -root -notype _NET_CURRENT_DESKTOP | cut -d\  -f3)
ff_raw=$(wmctrl -lp | grep "  $desktop " | grep Firefox | head -n1)
[ -z "$ff_raw" ] && xdg-open "$1"
echo $ff_raw
ff_wid=$(echo $ff_raw | awk '{print $1}')

wmctrl -i -a $ff_wid
xdotool key ctrl+t
xdotool getwindowfocus windowfocus --sync type "$1"
xdotool key KP_Enter
