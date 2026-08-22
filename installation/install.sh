#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

PACKAGES_DIR="$DOTFILES_DIR/installation/packages"
AUR_DIR="$DOTFILES_DIR/installation/AUR"
FLATPAKS_DIR="$DOTFILES_DIR/installation/flatpaks"
EXTRAS_DIR="$DOTFILES_DIR/installation/extras"

LINKS_FILE="$DOTFILES_DIR/installation/links.txt"

# -------------------------------------------------------------------
# Requirements
# -------------------------------------------------------------------

if ! command -v pacman &>/dev/null; then
    echo "Error: pacman is not installed. This script is meant to only work on Arch-based distributions"
    exit 1
fi

if ! command -v fzf &>/dev/null; then
    read -rp "This installer requires fzf, would you like to install it? [Y/n] " answer
	if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
	    sudo pacman -S --needed "fzf"
    else 
        echo "Aborted."
        exit 0
    fi
fi

if ! pacman -Qq base-devel &>/dev/null; then
	read -rp "AUR packages require base-devel. Install it? [Y/n] " answer

	if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
		sudo pacman -S --needed base-devel
	else
		echo "Aborted."
		exit 0
	fi
fi

# -------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------

select_files() {
	local directory="$1"
	local title="$2"

	[[ -d "$directory" ]] || return 0

	local files=()

	while IFS= read -r file; do
		files+=("$file")
	done < <(find "$directory" -maxdepth 1 -type f -print | sort)

	((${#files[@]})) || return 0

	local selected

	selected=$(
		for file in "${files[@]}"; do
			printf '%s\t%s\n' \
				"$file" \
				"$(head -n 1 "$file" | sed 's/^# *//')"
		done |
			fzf \
				--multi \
                --sync \
				--height=80% \
				--border \
				--reverse \
				--delimiter=$'\t' \
				--with-nth=2 \
				--header="$title - TAB: toggle • CTRL-A: select all • CTRL-D: deselect all • ENTER: confirm" \
				--prompt="  " \
				--bind 'start:select-all,ctrl-a:select-all,ctrl-d:deselect-all'
	) || return 0

	while IFS=$'\t' read -r file _; do
		printf '%s\n' "$file"
	done <<< "$selected"
}

read_packages_from_files() {
	local file

	while IFS= read -r file; do
		while IFS= read -r package; do
			[[ -z "$package" || "$package" == \#* ]] && continue

			if ! pacman -Qq "$package" &>/dev/null; then
				printf '%s\n' "$package"
			fi
		done < "$file"
	done
}

read_all_from_files() {
	local file

	while IFS= read -r file; do
		while IFS= read -r item; do
			[[ -z "$item" || "$item" == \#* ]] && continue
			printf '%s\n' "$item"
		done < "$file"
	done
}

install_yay() {
	echo
	echo "Installing yay..."

	sudo pacman -S --needed git base-devel

	local build_dir
	build_dir="$(mktemp -d)"

	trap 'rm -rf "$build_dir"' RETURN

	git clone \
		"https://aur.archlinux.org/yay.git" \
		"$build_dir/yay"

	(
		cd "$build_dir/yay"
		makepkg -si
	)
}

get_description() {
	local file="$1"

	sed -n 's/^###[[:space:]]*//p' "$file" | head -n 1
}

select_extras() {
	local directory="$1"
	local title="$2"

	[[ -d "$directory" ]] || return 0

	local scripts=()

	while IFS= read -r script; do
		scripts+=("$script")
	done < <(find "$directory" -maxdepth 1 -type f -print | sort)

	((${#scripts[@]})) || return 0

	local selected

	selected=$(
		for script in "${scripts[@]}"; do
			local description

			description="$(get_description "$script")"
			[[ -n "$description" ]] || description="$(basename "$script")"

			printf '%s\t%s\n' \
				"$script" \
				"$description"
		done |
			fzf \
				--multi \
				--sync \
				--height=80% \
				--border \
				--reverse \
				--delimiter=$'\t' \
				--with-nth=2 \
				--header="$title - TAB: toggle • CTRL-A: select all • CTRL-D: deselect all • ENTER: confirm" \
				--prompt="  " \
				--bind 'start:select-all,ctrl-a:select-all,ctrl-d:deselect-all'
	) || return 0

	while IFS=$'\t' read -r script _; do
		printf '%s\n' "$script"
	done <<< "$selected"
}

# -------------------------------------------------------------------
# Main selection
# -------------------------------------------------------------------

sections=(
	"Pacman packages"
	"AUR packages"
	"Flatpak packages"
	"Config links"
    "Extras"
)

selected_sections=$(
	printf '%s\n' "${sections[@]}" |
		fzf \
			--multi \
            --sync \
			--height=50% \
			--border \
			--reverse \
            --header="TAB: toggle • CTRL-A: select all • CTRL-D: deselect all • ENTER: confirm" \
			--prompt="  " \
            --bind 'start:select-all,ctrl-a:select-all,ctrl-d:deselect-all'
) || {
	echo "Aborted."
	exit 0
}

# -------------------------------------------------------------------
# Arrays
# -------------------------------------------------------------------

pacman_packages=()
aur_packages=()
flatpaks=()
links=()

# -------------------------------------------------------------------
# Pacman
# -------------------------------------------------------------------

if grep -Fxq "Pacman packages" <<< "$selected_sections"; then
	echo
	echo "Select Pacman package groups..."

	mapfile -t selected_files < <(
		select_files "$PACKAGES_DIR" "Pacman package groups"
	)

	if ((${#selected_files[@]})); then
		mapfile -t pacman_packages < <(
			printf '%s\n' "${selected_files[@]}" |
				read_packages_from_files
		)
	fi
fi

# -------------------------------------------------------------------
# AUR
# -------------------------------------------------------------------

if grep -Fxq "AUR packages" <<< "$selected_sections"; then
	echo
	echo "Select AUR package groups..."

	mapfile -t selected_files < <(
		select_files "$AUR_DIR" "AUR package groups"
	)

	if ((${#selected_files[@]})); then
		while IFS= read -r package; do
			[[ -z "$package" ]] && continue

			# Skip packages that are already installed
			if ! pacman -Qq "$package" &>/dev/null; then
				aur_packages+=("$package")
			fi
		done < <(
			printf '%s\n' "${selected_files[@]}" |
				read_all_from_files
		)
	fi
fi

# -------------------------------------------------------------------
# Flatpak
# -------------------------------------------------------------------

if grep -Fxq "Flatpak packages" <<< "$selected_sections"; then
	echo
	echo "Select Flatpak package groups..."

	if ! command -v flatpak &>/dev/null; then
		echo
		echo "Error: flatpak is not installed."
		exit 1
	fi

	mapfile -t selected_files < <(
		select_files "$FLATPAKS_DIR" "Flatpak package groups"
	)

	if ((${#selected_files[@]})); then
		while IFS= read -r flatpak; do
			[[ -z "$flatpak" ]] && continue

			if ! flatpak info "$flatpak" &>/dev/null; then
				flatpaks+=("$flatpak")
			fi
		done < <(
			printf '%s\n' "${selected_files[@]}" |
				read_all_from_files
		)
	fi
fi

# -------------------------------------------------------------------
# Config links
# -------------------------------------------------------------------

if grep -Fxq "Config links" <<< "$selected_sections"; then
	echo
	echo "Select config links..."

	link_options=()

	while IFS= read -r link; do
		[[ -z "$link" || "$link" == \#* ]] && continue
		link_options+=("$link")
	done < "$LINKS_FILE"

	if ((${#link_options[@]})); then
		selected_links=$(
			printf '%s\n' "${link_options[@]}" |
				fzf \
					--multi \
                    --sync \
					--height=80% \
					--border \
					--reverse \
                    --header="Select config links - TAB: toggle • CTRL-A: select all • CTRL-D: deselect all • ENTER: confirm" \
					--prompt="  " \
                    --bind 'start:select-all,ctrl-a:select-all,ctrl-d:deselect-all'
		) || true

		if [[ -n "${selected_links:-}" ]]; then
			while IFS= read -r link; do
				links+=("$link")
			done <<< "$selected_links"
		fi
	fi
fi

# -------------------------------------------------------------------
# Extras
# -------------------------------------------------------------------

if grep -Fxq "Extras" <<< "$selected_sections"; then
	echo
	echo "Select extras..."

	mapfile -t selected_extras < <(
		select_extras "$EXTRAS_DIR" "Extras"
	)

	if ((${#selected_extras[@]})); then
		extras=("${selected_extras[@]}")
	fi
fi

# -------------------------------------------------------------------
# AUR helper
# -------------------------------------------------------------------

if ((${#aur_packages[@]})); then
	if ! command -v yay &>/dev/null; then
		echo
		read -rp "AUR packages were selected, but yay is not installed. Install yay? [Y/n] " answer

		if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
			install_yay
		else
			echo "Aborted."
			exit 0
		fi
	fi
fi

# -------------------------------------------------------------------
# Recap
# -------------------------------------------------------------------

echo
echo "========================================"
echo " Installation recap"
echo "========================================"

echo
echo "Pacman packages:"
if ((${#pacman_packages[@]})); then
	printf '  %s\n' "${pacman_packages[@]}"
else
	echo "  (none)"
fi

echo
echo "AUR packages:"
if ((${#aur_packages[@]})); then
	printf '  %s\n' "${aur_packages[@]}"
else
	echo "  (none)"
fi

echo
echo "Flatpaks:"
if ((${#flatpaks[@]})); then
	printf '  %s\n' "${flatpaks[@]}"
else
	echo "  (none)"
fi

echo
echo "Config links:"
if ((${#links[@]})); then
	for link in "${links[@]}"; do
		printf '  %s -> %s\n' \
			"$CONFIG_DIR/$link" \
			"$DOTFILES_DIR/$link"
	done
else
	echo "  (none)"
fi

echo
echo "Extras:"
if ((${#extras[@]})); then
	for extra in "${extras[@]}"; do
		description="$(get_description "$extra")"
		[[ -n "$description" ]] || description="$(basename "$extra")"

		printf '  %s\n' "$description"
	done
else
	echo "  (none)"
fi

# -------------------------------------------------------------------
# Confirmation
# -------------------------------------------------------------------

echo
read -rp "Proceed with installation and linking? [y/N] " answer

if [[ ! "$answer" =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 0
fi

# -------------------------------------------------------------------
# Logging
# -------------------------------------------------------------------

LOG_DIR="$DOTFILES_DIR/installation/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/$(date '+%Y-%m-%d_%H-%M-%S').log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo
echo "Installation started: $(date)"
echo "Log file: $LOG_FILE"
echo

# -------------------------------------------------------------------
# Install Pacman packages
# -------------------------------------------------------------------

if ((${#pacman_packages[@]})); then
	echo
    echo "========================================"
	echo "Installing Pacman packages..."
    echo "========================================"
	sudo pacman -S --needed "${pacman_packages[@]}"
fi

# -------------------------------------------------------------------
# Install AUR packages
# -------------------------------------------------------------------

if ((${#aur_packages[@]})); then
	echo
    echo "========================================"
	echo "Installing AUR packages..."
    echo "========================================"
	yay -S --needed --noconfirm "${aur_packages[@]}"
fi

# -------------------------------------------------------------------
# Install Flatpaks
# -------------------------------------------------------------------

if ((${#flatpaks[@]})); then
	echo
    echo "========================================"
	echo "Installing Flatpaks..."
    echo "========================================"

	flatpak install -y flathub "${flatpaks[@]}"
fi

# -------------------------------------------------------------------
# Create config links
# -------------------------------------------------------------------

if ((${#links[@]})); then
	echo
    echo "========================================"
	echo "Creating config links..."
    echo "========================================"

	mkdir -p "$CONFIG_DIR"

	for link in "${links[@]}"; do
		target="$DOTFILES_DIR/$link"
		destination="$CONFIG_DIR/$link"

		mkdir -p "$(dirname "$destination")"

		ln -sfn "$target" "$destination"
	done
fi

# -------------------------------------------------------------------
# Run Extras
# -------------------------------------------------------------------

if ((${#extras[@]})); then
	echo
    echo "========================================"
	echo "Running extras..."
    echo "========================================"

	for extra in "${extras[@]}"; do
		description="$(get_description "$extra")"
		[[ -n "$description" ]] || description="$(basename "$extra")"

		echo
		echo "==> $description"

		bash "$extra"
	done
fi

echo "========================================"
echo "Done."
