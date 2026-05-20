#!/bin/sh

profile=$(powerprofilesctl get)

case "$profile" in
    power-saver)
        icon="󰌪" # low power
        ;;
    balanced)
        icon="󰾅" # balanced
        ;;
    performance)
        icon="󰓅" # performance
        ;;
    *)
        icon="?"
        ;;
esac

echo "$icon"
