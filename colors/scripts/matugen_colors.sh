#!/bin/bash

set -e

# Paths
WALLPAPER_DIR="${HOME}/.config/colors/wallpapers"
ACTIVE_DIR="${WALLPAPER_DIR}/active"
ACTIVE_WALLPAPER="${ACTIVE_DIR}/active.jpg"
ROFI_THEME="$HOME/.config/rofi/wallpaper_picker_config.rasi"

WALLPAPER=$(
	find "$WALLPAPER_DIR" -maxdepth 1 -type f | while read -r img; do
    [[ "$img" =~ \.(jpg|jpeg|png|webp|JPG|JPEG|PNG|WEBP)$ ]] || continue


    REL_PATH="${img#$WALLPAPER_DIR/}"
	printf "%s\0icon\x1f%s\n" "$REL_PATH" "$img"
    done | rofi \
        -dmenu \
        -i \
        -show-icons \
        -theme "$ROFI_THEME" \
        -p ""
)


[ -z "$WALLPAPER" ] && exit 0

echo "Selected wallpaper: $WALLPAPER"

WP_PATH="$WALLPAPER_DIR/$WALLPAPER"

# Save active wallpaper
mkdir -p "$ACTIVE_DIR"
cp "$WP_PATH" "$ACTIVE_WALLPAPER"

# Generate colors with matugen
matugen image "$WP_PATH"

# Smooth transition
niri msg action do-screen-transition --delay-ms 300

# Restart swaybg
pkill -x swaybg || true
nohup swaybg -i "$WP_PATH" -m fill >/dev/null 2>&1 &

# Reload swaync
swaync-client -rs

# Restart Waybar
pkill -x waybar || true
nohup waybar -c ~/.config/waybar/waybar.conf >/dev/null 2>&1 &

echo "Wallpaper and colors updated."
