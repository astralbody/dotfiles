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

xdg_user_dirs_install() {
	echo "Creating user dirs..."
	gotodot

	mkdir -p "$USER_CONFIG"
	ln -s ./xdg_user_dirs/.config/user-dirs.dirs "$USER_CONFIG/user-dirs.dirs"

	xdg-user-dirs-update
	rm "$USER_CONFIG/user-dirs.dirs"
	move_dotfiles_to_projects
}
