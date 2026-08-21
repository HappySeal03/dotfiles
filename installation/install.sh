#!/bin/bash

set -euo pipefail

PACKAGES_DIR="./packages"
LINKS_FILE="./links.txt"
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

packages=()
links=()

# Read package groups and ask whether to include them
for file in "$PACKAGES_DIR"/*; do
	[[ -f "$file" ]] || continue

	# Extract group title
	title=$(head -n 1 "$file")

	# Ask wether to include
	read -rp "Install ${title#\# }? [Y/n] " answer
	
	if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
		while IFS= read -r package; do
			# Skip comments and empty lines
			[[ -z "$package" || "$package" == \#* ]] && continue
			if ! pacman -Qq "$package" &>/dev/null; then
				packages+=("$package")
			fi
		done < "$file"
	fi
done


# Read links
while IFS= read -r link; do
	# Skip comments and empty lines
	[[ -z "$link" || "$link" == \#* ]] && continue
	links+=("$link")
done < "$LINKS_FILE"


# Recap and confirmation
echo
echo "Packages to install:"
printf ' %s\n' "${packages[@]}"

echo
echo "Links to create:"
if ((${#links[@]})); then
	for link in "${links[@]}"; do
		printf ' %s -> %s\n' \
			"$CONFIG_DIR/$link" \
			"$DOTFILES_DIR/$link"
	done
else
	echo " (none)"
fi

echo
read -rp "Proceed with installation and linking? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 0
fi


# Install packages
if ((${#packages[@]})); then
	sudo pacman -S --needed "${packages[@]}"
fi

# Link configs
for link in "${links[@]}"; do
	ln -sfn "$DOTFILES_DIR/$link" "$CONFIG_DIR/$link"
done

echo "Done."
