#!/usr/bin/env bash

set -e

export REPO="https://github.com/astralbody/dotfiles"
export RAW_REPO="https://raw.githubusercontent.com/astralbody/dotfiles/main"
export PROJECTS=$HOME/Projects
export DOTFILES=$PROJECTS/dotfiles
export DOTFILES_TMP=$HOME/.dotfiles.tmp
export DOWNLOADS="$HOME"/Downloads
export BIN=$HOME/.local/bin
export PATH=$PATH:"$HOME"/.local/bin

import_utils() {
	mkdir -p "$DOTFILES_TMP"
	curl $RAW_REPO/lib/utils.sh -o "$DOTFILES_TMP"/utils.sh
	. "$DOTFILES_TMP"/utils.sh
}

install_deps() {
	log "Installing dependencies"

	if is_arch; then
		sudo pacman -Syu --noconfirm
		sudo pacman -S --needed --noconfirm git base-devel fd
	fi
	if is_debian; then
		curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
		sudo apt update -y
		sudo apt full-upgrade -y
		sudo apt clean
		sudo apt install git fd-find build-essential nodejs -y
		mkdir -p "$BIN"
		sudo ln -s "$(which fdfind)" "$BIN"/fd
	fi
}

clone_dotfiles() {
	log "Cloning Dotfiles"

	if [ "$(ls "$DOTFILES")" ]; then
		log "$DOTFILES is not empty. It won't clone dotfiles."
		return
	fi

	git clone $REPO.git "$DOTFILES"
}

install_local_packages() {
	log "Installing local packages"

	pipenv install
	npm install
}

mkdir -p "$DOWNLOADS"
mkdir -p "$PROJECTS"

import_utils
install_deps
clone_dotfiles

gotodot

. ./package_manager/launcher.sh
. ./dotfiles/launcher.sh

pkg install
install_local_packages

if is_arch; then
	dot install
fi

back
log "Dotfiles installed!"

unset -v DOTFILES
unset -f install_deps clone_dotfiles err log gotodot back
