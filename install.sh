#!/usr/bin/env bash

set -e

export PROJECTS=$HOME/Projects
export DOTFILES=$PROJECTS/dotfiles

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

install_deps() {
	log "Installing dependencies"

	local OS_RELEASE_ID
	OS_RELEASE_ID=$(grep ^ID= /etc/os-release | sed -r 's/ID=//g')
	local ARCH_ID="arch"

	if [ "$OS_RELEASE_ID" = "$ARCH_ID" ]; then
		pacman -Sy --noconfirm git
	fi
}

clone_dotfiles() {
	log "Cloning Dotfiles"

	cd "$PROJECTS"
	git clone https://github.com/astralbody/dotfiles.git
}

intall_local_packages() {
	log "Installing local packages"

	pipenv install
	npm install
}

install_deps
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
unset -f install_deps clone_dotfiles err log gotodot back
