#!/usr/bin/env bash

export REPO="https://github.com/astralbody/dotfiles"
export PYTHON_VER="3.10.6"

export DOTDOTFILES=$HOME/.dotfiles
export DOTFILES=$DOTDOTFILES/dotfiles
export DOTFILES_TMP=$DOTDOTFILES/tmp
export DOTFILES_BACKUP=$DOTDOTFILES/backup

shopt -s globstar
set -e

load_dotfiles() {
	cd "$DOTFILES" || exit

	if [ "$(ls "$DOTFILES")" ]; then
		echo "$DOTFILES is not empty. It won't load dotfiles."
		return
	fi

	echo "Dofiles is loading..."
	curl "$REPO/archive/refs/heads/main.zip" --output "$DOTFILES_TMP/dotfiles-main.zip"
	unzip "$DOTFILES_TMP/dotfiles-main.zip" -d "$DOTFILES_TMP"
	rm "$DOTFILES_TMP"/dotfiles-main.zip
	mv "$DOTFILES_TMP/dotfiles-main" "$DOTFILES"
}

source_lib() {
	echo "Sourcing lib..."
	local lib
	for lib in ./lib/{environment,utils}.sh; do
		. "$lib"
	done
}

install_system_packages() {
	. ./package_manager/launcher.sh
	pkg install
}

install_dotfiles_packages() {
	log "Installing local packages..."

	pyenv install $PYTHON_VER
	pyenv local $PYTHON_VER
	pipenv install
	npm install
}

link_dotfiles() {
	. ./dotfiles/launcher.sh
	dot install
}

clean_env() {
	echo "Cleaning environment..."
	unset -v REPO DOTFILES PYTHON_VER
	unset -f load_dotfiles source_lib install_system_packages install_system_packages install_dotfiles_packages link_dotfiles
}

create_dotfiles_dirs() {
	dirs=("$DOTDOTFILES" "$DOTFILES" "$DOTFILES_TMP" "$DOTFILES_BACKUP")
	for dir in "${dirs[@]}"; do
		mkdir -p "$dir"
	done
}

create_user_dirs() {
	ln -sf ./xdg_user_dirs/.config/user-dirs.dirs "$HOME"/.config/user-dirs.dirs
	ln -sf ./xdg_user_dirs/.config/user-dirs.locale "$HOME"/.config/user-dirs.locale
	xdg-user-dirs-update
	rm "$HOME"/.config/user-dirs.dirs
	rm "$HOME"/.config/user-dirs.locale

	local projects_dotfiles
	projects_dotfiles="$(xdg-user-dir PROJECTS)/dotfiles"
	mv "$DOTFILES" "$projects_dotfiles"
	ln -sf "$projects_dotfiles" "$DOTFILES"
	DOTFILES=$projects_dotfiles
}

install_dotfiles() {
	trap 'clear_env' ERR
	echo "Dotfiles is installing..."

	create_dotfiles_dirs
	load_dotfiles
	source_lib
	install_system_packages
	install_dotfiles_packages
	create_user_dirs
	link_dotfiles
	clean_env

	echo "Dotfiles installed!"
}

install_dotfiles
