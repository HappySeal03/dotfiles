#!/bin/bash

dirs=(
	colors
	matugen
	rofi
	waybar
	niri
	swaync
	wlogout
	simple-mpris-controls
)

for dir in "${dirs[@]}"; do
	ln -sfn "$HOME/dotfiles/$dir" "$HOME/.config/$dir"
done
