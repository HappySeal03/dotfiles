#!/usr/bin/env bash

SCRIPT_DIR="$HOME/dotfiles/scripts/replay_buffer"
"$SCRIPT_DIR/.venv/bin/python" "$SCRIPT_DIR/obs_control.py" save
