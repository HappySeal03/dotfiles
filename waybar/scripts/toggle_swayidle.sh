#!/bin/bash

LOGFILE="$HOME/.config/waybar/logs/toggle_swayidle.log"

if pgrep -x swayidle >/dev/null; then
    pkill -x swayidle
    echo "swayidle disabled at $(date)" >> "$LOGFILE"
else
    CMD=(
        swayidle
        -w
        timeout 300 "swaylock -f"
        timeout 600 "niri msg action power-off-monitors"
        resume "niri msg action power-on-monitors"
        before-sleep "swaylock -f"
    )

    nohup "${CMD[@]}" >/dev/null 2>&1 &
    echo "swayidle dispatched at $(date)" >> "$LOGFILE"
fi

pkill -RTMIN+8 waybar
