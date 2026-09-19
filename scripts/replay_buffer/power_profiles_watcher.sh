#!/usr/bin/env bash

set -u

# Directory containing this script.
SCRIPT_DIR="$HOME/dotfiles/scripts/replay_buffer"

VENV="$SCRIPT_DIR/.venv"

OBS_SCRIPT="$SCRIPT_DIR/obs_control.py"

# Python interpreter from the virtual environment.
PYTHON="$VENV/bin/python"

# Applications that start OBS running while in balanced mode.
APPS=(
    "steam"
)

last_profile=""


start_obs() {
    echo "Starting OBS and replay buffer..."
    "$PYTHON" "$OBS_SCRIPT" start
}


stop_obs() {
    echo "Stopping OBS..."
    "$PYTHON" "$OBS_SCRIPT" stop
}


# Check whether any application in APPS is running.
any_app_running() {
    local app

    for app in "${APPS[@]}"; do
        if pgrep -x "$app" >/dev/null 2>&1; then
            echo "$app is running"
            return 0
        fi
    done

    return 1
}


handle_profile() {
    local profile="$1"

    echo "Power profile: $profile"

    case "$profile" in
        performance)
            start_obs
            ;;

        power-saver)
            stop_obs
            ;;

        balanced)
            if any_app_running; then
                start_obs
            else
                stop_obs
            fi
            ;;
    esac
}


# Check if the virtual environment exists.
if [[ ! -x "$PYTHON" ]]; then
    echo "Python virtual environment not found: $VENV" >&2
    echo "Create it with:" >&2
    echo "  python3 -m venv \"$VENV\"" >&2
    echo "  \"$PYTHON\" -m pip install obsws-python python-dotenv" >&2
    exit 1
fi


# Check if the OBS controller exists.
if [[ ! -f "$OBS_SCRIPT" ]]; then
    echo "OBS controller not found: $OBS_SCRIPT" >&2
    exit 1
fi


# Watch power profiles changes.
gdbus monitor \
    --system \
    --dest net.hadess.PowerProfiles \
    --object-path /net/hadess/PowerProfiles |
while read -r line; do

    # Extract the profile value from the D-Bus event.
    if [[ "$line" =~ ActiveProfile.*\'(power-saver|balanced|performance)\' ]]; then
        profile="${BASH_REMATCH[1]}"

        # Ignore duplicate events.
        [[ "$profile" == "$last_profile" ]] && continue
        last_profile="$profile"

        handle_profile "$profile"
    fi
done
