#!/usr/bin/env bash

export DOTFILES_ZIP="https://codeload.github.com/astralbody/dotfiles/zip/refs/heads/main"
export PYTHON_VER="3.10.6"

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
	create_dotfiles_dirs
	cd "$DOTFILES"

	if [ "$(ls "$DOTFILES")" ]; then
		echo "$DOTFILES is not empty. It won't load dotfiles."
		return
	fi

	echo "Dofiles is loading..."
	curl $DOTFILES_ZIP --output "$DOTFILES_TMP/dotfiles-main.zip"
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

install_paths() {
	log "Installing paths..."
	mkdir -p "$USER_BIN"
	set_paths
}

install_system_packages() {
	log "Installing system packages..."

	gotodot
	. ./package_manager/launcher.sh
	pkg install
}

install_dotfiles_packages() {
	if is_rpi; then
		return
	fi

	log "Installing dotfiles packages..."

	gotodot
	pyenv install $PYTHON_VER
	pyenv local $PYTHON_VER
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
	unset -v DOTFILES_ZIP
	unset -v PYTHON_VER
	unset -f create_dotfiles_dirs
	unset -f load_dotfiles
	unset -f source_lib
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
	install_paths
	install_system_packages
	install_dotfiles_packages
	link_dotfiles
	clean_up
	echo "Dotfiles installed!"
}

install_dotfiles
