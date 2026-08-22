#!/bin/bash

### Add Go install directory to $PATH

set -euo pipefail

# Skip if Go is not installed.
if ! command -v go &>/dev/null; then
	echo "Go is not installed. Skipping."
	exit 0
fi

# Determine where `go install` puts binaries.
if [[ -n "${GOBIN:-}" ]]; then
	go_bin="$GOBIN"
else
	go_bin="$(go env GOPATH)/bin"
fi

shell_config="$HOME/.bashrc"

# Don't add the directory if it is already present.
if grep -Fqx "export PATH=\"\$PATH:$go_bin\"" "$shell_config" 2>/dev/null; then
	echo "$go_bin is already in PATH."
	exit 0
fi

# Check whether PATH already contains the directory.
case ":$PATH:" in
	*":$go_bin:"*)
		echo "$go_bin is already in PATH."
		exit 0
		;;
esac

echo "Adding $go_bin to PATH..."

printf '\n# Go binaries\nexport PATH="$PATH:%s"\n' "$go_bin" >> "$shell_config"

# Make the change available to the current installer process.
export PATH="$PATH:$go_bin"

echo "$go_bin added to PATH."
