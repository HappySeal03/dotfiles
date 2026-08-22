#!/bin/bash
### Install the Rust toolchain

set -euo pipefail

# Skip installation if a working Rust toolchain is already available.
if command -v rustup &>/dev/null; then
	echo "Rust is already installed. Skipping."
	exit 0
fi

echo "Installing Rust..."

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "Rust installation complete."
