#!/bin/bash

set -e

WALLPAPER_DIR="${HOME}/.config/colors/wallpapers"

WALLPAPER_PATH=$(
    find "$WALLPAPER_DIR" \
        -maxdepth 1 \
        -type f \
        -exec basename {} \; | \
    rofi -dmenu -p "Enter wallpaper name:"
)

if [ -z "$WALLPAPER_PATH" ]; then
    exit 1
fi

PAPER="${WALLPAPER_DIR}/${WALLPAPER_PATH}"

# Save active wallpaper
cp "$PAPER" "${WALLPAPER_DIR}/active/active.jpg"

# Generate colors
"$HOME/.config/colors/scripts/colors.sh" "$PAPER"

niri msg action do-screen-transition --delay-ms 300

# Restart swaybg
pkill -x swaybg || true
nohup swaybg -i "$PAPER" -m fill >/dev/null 2>&1 &

# Reload notifications
swaync-client -rs

# Restart waybar
pkill -x waybar || true
nohup waybar -c ~/.config/waybar/waybar.conf >/dev/null 2>&1 &
