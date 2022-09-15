#!/usr/bin/env bash

set -e

export DOTFILES=$HOME/Projects/dotfiles

err() {
	local message=$1
	echo "$message" >&2
}

log() {
	local message=$1
	echo "$message" >&1
}

gotodot() {
	cd "$DOTFILES" || exit
}

back() {
	cd - >/dev/null || exit
}

install_git() {
	log "Installing Git"

	local OS_RELEASE_ID
	OS_RELEASE_ID=$(rg '^ID' /etc/os-release | sd 'ID=' '')
	local ARCH_ID="arch"

	if [ "$OS_RELEASE_ID" = "$ARCH_ID" ]; then
		pacman -S --noconfirm git
	fi
}

clone_dotfiles() {
	log "Cloning Dotfiles"

	mkdir -p "$DOTFILES"
	# git clone REPO
}

intall_local_packages() {
	log "Installing local packages"

	pipenv install
	npm install
}

install_git
clone_dotfiles

gotodot

. ./lib/utils.sh
. ./package_manager/launcher.sh
. ./dotfiles/launcher.sh

pkg install
intall_local_packages
dot instal

back

unset -v DOTFILES
unset -f install_git clone_dotfiles err log gotodot back
