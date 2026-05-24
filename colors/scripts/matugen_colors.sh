#!/bin/bash

set -e

# Paths
WALLPAPER_DIR="${HOME}/.config/colors/wallpapers"
ACTIVE_DIR="${WALLPAPER_DIR}/active"
ACTIVE_WALLPAPER="${ACTIVE_DIR}/active.jpg"

# Select wallpaper
WALLPAPER_NAME=$(
    find "$WALLPAPER_DIR" \
        -maxdepth 1 \
        -type f \
        -exec basename {} \; | \
    rofi -dmenu -p "Enter wallpaper name:"
)

[ -z "$WALLPAPER_NAME" ] && exit 0

WALLPAPER="${WALLPAPER_DIR}/${WALLPAPER_NAME}"

echo "Selected wallpaper: $WALLPAPER"

# Save active wallpaper
mkdir -p "$ACTIVE_DIR"
cp "$WALLPAPER" "$ACTIVE_WALLPAPER"

# Generate colors with matugen
matugen image "$WALLPAPER"

# Smooth transition
niri msg action do-screen-transition --delay-ms 300

# Restart swaybg
pkill -x swaybg || true
nohup swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &

# Reload swaync
swaync-client -rs

# Restart Waybar
pkill -x waybar || true
nohup waybar -c ~/.config/waybar/waybar.conf >/dev/null 2>&1 &

echo "Wallpaper and colors updated."
