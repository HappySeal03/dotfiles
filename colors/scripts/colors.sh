#!/bin/bash

set -e

WALLPAPER="$1"

# =========================================================
# Paths
# =========================================================

COLORS_CSS="$HOME/.config/colors/colors.css"
COLORS_RASI="$HOME/.config/colors/colors.rasi"

NIRI_COLORS="$HOME/.config/niri/config.d/colors.kdl"

WAL_COLORS="$HOME/.cache/wal/colors.json"

# =========================================================
# Generate pywal palette
# =========================================================

wal -q -i "$WALLPAPER"

if [ ! -f "$WAL_COLORS" ]; then
    echo "Error: $WAL_COLORS not found."
    exit 1
fi

# =========================================================
# Read pywal colors
# =========================================================

foreground=$(jq -r '.special.foreground' "$WAL_COLORS")
background=$(jq -r '.special.background' "$WAL_COLORS")

accent=$(jq -r '.colors.color4' "$WAL_COLORS")
accent_alt=$(jq -r '.colors.color6' "$WAL_COLORS")

urgent=$(jq -r '.colors.color1' "$WAL_COLORS")

# =========================================================
# Stable semantic surfaces
# =========================================================

# Neutral dark surfaces.
# These stay readable regardless of wallpaper.

bg="#111318"
surface="#1a1d24"
surface_alt="#242934"

# =========================================================
# Utils
# =========================================================

hex_to_dec() {
    printf "%d" "0x$1"
}

# =========================================================
# Foreground readability correction
# =========================================================

r=$(hex_to_dec "${foreground:1:2}")
g=$(hex_to_dec "${foreground:3:2}")
b=$(hex_to_dec "${foreground:5:2}")

# Relative luminance approximation
luminance=$(( (r * 299 + g * 587 + b * 114) / 1000 ))

# If pywal foreground is too dark,
# replace with stable light text.

if [ "$luminance" -lt 140 ]; then
    foreground="#e5e9f0"
fi

# =========================================================
# Border colors
# =========================================================

border="rgba(255,255,255,0.08)"
text_muted="rgba(220,220,220,0.72)"

# =========================================================
# Generate shared CSS
# =========================================================

cat > "$COLORS_CSS" <<EOF
@define-color bg $bg;
@define-color surface $surface;
@define-color surface-alt $surface_alt;

@define-color text $foreground;
@define-color text-muted $text_muted;

@define-color accent $accent;
@define-color accent-alt $accent_alt;

@define-color border $border;

@define-color urgent $urgent;

@define-color black #111111;
EOF

echo "Generated semantic CSS colors."

# =========================================================
# Generate Rofi variables
# =========================================================

cat > "$COLORS_RASI" <<EOF
* {
    bg:             $bg;
    surface:        $surface;
    surface-alt:    $surface_alt;

    text:           $foreground;
    text-muted:     $text_muted;

    accent:         $accent;
    accent-alt:     $accent_alt;

    border:         $border;

    urgent:         $urgent;

    black:          #111111;
}
EOF

echo "Generated semantic Rofi colors."

# =========================================================
# Generate Niri colors
# =========================================================

inactive="rgba(255,255,255,0.12)"

cat > "$NIRI_COLORS" <<EOF
layout {
    border {
        active-color "$accent"
        inactive-color "$inactive"
    }

    focus-ring {
        active-color "$accent"
        inactive-color "$inactive"
    }
}
EOF

echo "Generated Niri colors."
