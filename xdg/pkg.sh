#!/usr/bin/env bash

move_dotfiles_to_projects() {
	echo "Move dotfiles to Projects..."
	gotodot

	local projects
	projects=$(xdg-user-dir PROJECTS)
	local projects_dotfiles="$projects/dotfiles"

	mv "$DOTFILES" "$projects/"
	ln -sf "$projects_dotfiles" "$DOTFILES"

	DOTFILES=$projects_dotfiles
}

xdg_install() {
	echo "Creating user dirs..."
	gotodot

	sudo rm /etc/xdg/user-dirs.defaults
	sudo cp ./xdg/user-dirs.defaults "$XDG_CONFIG_DIRS"
	xdg-user-dirs-update
	move_dotfiles_to_projects
}
