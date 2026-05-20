#!/bin/bash

CACHED_STATE="$HOME/.cache/airplane_mode_cache_state.json"

enable_airplane_mode() {
    rfkill -J > $CACHED_STATE
    rfkill block all
    notify-send "Airplane mode" "Enabled"
}

disable_airplane_mode() {
    jq -c '.rfkilldevices[]' $CACHED_STATE | while read -r device; do
        IDX=$(echo $device | jq -r '.id')
        BLOCKED=$(echo $device | jq -r '.soft')

        if [[ $BLOCKED == "unblocked" ]]; then
            rfkill unblock $IDX
        fi
    done

    rm $CACHED_STATE
    notify-send "Airplane mode" "Disabled"
}

if [[ -f $CACHED_STATE ]]; then
    disable_airplane_mode
else
    enable_airplane_mode
fi
