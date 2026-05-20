#!/bin/bash

set -e

PROFILE=$(
    printf "power-saver\nbalanced\nperformance" | \
    rofi -dmenu -p "Power profile"
)

# Exit silently if nothing selected
[ -z "$PROFILE" ] && exit 0

powerprofilesctl set "$PROFILE"
