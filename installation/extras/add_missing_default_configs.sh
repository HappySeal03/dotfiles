#!/bin/bash

### Add missing niri monitor and colors configs

set -euo pipefail

COLORS_FILE="$HOME/dotfiles/niri/config.d/colors.kdl"
OUTPUTS_FILE="$HOME/dotfiles/niri/config.d/output.kdl"
DEFAULT_COLOR="#6750A4"

# -------------------------------------------------------------------
# Requirements
# -------------------------------------------------------------------

if ! command -v matugen &>/dev/null; then
	echo "Error: matugen is not installed."
	exit 1
fi

if ! command -v niri &>/dev/null; then
	echo "Error: niri is not installed."
	exit 1
fi


# -------------------------------------------------------------------
# Generate colors config
# -------------------------------------------------------------------

if [[ -e "$COLORS_FILE" ]]; then
	echo "Colors config already exist. Skipping."
else
	if ! command -v matugen &>/dev/null; then
		echo "Error: matugen is not installed."
		exit 1
	fi

	echo "Generating colors..."
	echo "Using default color: $DEFAULT_COLOR"

	matugen color hex "$DEFAULT_COLOR"
fi

# -------------------------------------------------------------------
# Generate Niri outputs
# -------------------------------------------------------------------

if [[ -e "$OUTPUTS_FILE" ]]; then
	echo "Niri output config already exist. Skipping."
else
	if ! command -v niri &>/dev/null; then
		echo "Error: niri is not installed."
		exit 1
	fi

	echo "Generating Niri outputs..."

	niri_outputs="$(niri msg outputs)" || {
		echo "Error: unable to query Niri outputs."
		exit 1
	}

	mkdir -p "$(dirname "$OUTPUTS_FILE")"

	{
		output_name=""

        output_regex='^Output.* \(([^)]+)\)$'
        mode_regex='^[[:space:]]+Current mode: ([0-9]+x[0-9]+) @ ([0-9]+(\.[0-9]+)?) Hz'

        while IFS= read -r line; do
            if [[ "$line" =~ $output_regex ]]; then
                output_name="${BASH_REMATCH[1]}"
                continue
            fi

            if [[ "$line" =~ $mode_regex ]]; then
                resolution="${BASH_REMATCH[1]}"
                refresh_rate="${BASH_REMATCH[2]}"

                printf 'output "%s" {\n' "$output_name"
                printf '    mode "%s@%s"\n' "$resolution" "$refresh_rate"
                printf '    scale 1.0\n'
                printf '    position x=0 y=0\n'
                printf '}\n\n'

                output_name=""
            fi
        done <<< "$niri_outputs"
    } > "$OUTPUTS_FILE"

	if [[ ! -s "$OUTPUTS_FILE" ]]; then
		rm -f "$OUTPUTS_FILE"
		echo "Error: no Niri outputs were detected."
		exit 1
	fi
fi

echo
echo "Niri dynamic configuration complete."
