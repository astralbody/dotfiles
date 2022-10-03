#!/usr/bin/env bash

export DOTDOTFILES=$HOME/.dotfiles
export DOTFILES=$DOTDOTFILES/dotfiles
export DOTFILES_TMP=$DOTDOTFILES/tmp
export DOTFILES_BACKUP=$DOTDOTFILES/backup

shopt -s globstar
set -e
set -o pipefail
# set -u

create_dotfiles_dirs() {
	echo "Creating dotfiles dirs..."

	dirs=("$DOTDOTFILES" "$DOTFILES" "$DOTFILES_TMP" "$DOTFILES_BACKUP")
	for dir in "${dirs[@]}"; do
		mkdir -p "$dir"
	done
}

load_dotfiles() {
	local dotfiles_zip="https://codeload.github.com/astralbody/dotfiles/zip/refs/heads/main"
	create_dotfiles_dirs
	cd "$DOTFILES"

	if [ "$(ls "$DOTFILES")" ]; then
		echo "$DOTFILES is not empty. It won't load dotfiles."
		return
	fi

	echo "Dofiles is loading..."
	curl "$dotfiles_zip" --output "$DOTFILES_TMP/dotfiles-main.zip"
	unzip "$DOTFILES_TMP/dotfiles-main.zip" -d "$DOTFILES_TMP"
	rm -v "$DOTFILES_TMP"/dotfiles-main.zip
	cd "$DOTFILES_TMP"/dotfiles-main
	cp -rv . "$DOTFILES"
	cd "$DOTFILES"
	rm -rfv "$DOTFILES_TMP"/dotfiles-main
}

source_lib() {
	echo "Sourcing lib..."
	local lib
	for lib in ./lib/{environment,utils}.sh; do
		. "$lib"
	done
}

install_user_paths() {
	log "Installing user paths..."
	set_user_paths
}

install_system_packages() {
	log "Installing system packages..."

	gotodot
	. ./package_manager/launcher.sh
	pkg install
}

install_dotfiles_packages() {
	local python_ver="3.10.6"

	if is_rpi; then
		return
	fi

	log "Installing dotfiles packages..."

	gotodot
	pyenv install "$python_ver"
	pyenv local "$python_ver"
	pipenv install
	npm install
}

link_dotfiles() {
	gotodot
	. ./dotfiles/launcher.sh
	dot install
}

clean_up() {
	echo "Cleaning up..."
	unset -f create_dotfiles_dirs
	unset -f load_dotfiles
	unset -f source_lib
	unset -f install_user_paths
	unset -f install_system_packages
	unset -f install_dotfiles_packages
	unset -f link_dotfiles
	unset -f clean_env
	unset -f install_dotfiles
}

install_dotfiles() {
	echo "Dotfiles is installing..."
	load_dotfiles
	source_lib
	create_xdg_base_dirs
	install_user_paths
	install_system_packages
	install_dotfiles_packages
	link_dotfiles
	clean_up
	echo "Dotfiles installed!"
}

install_dotfiles
