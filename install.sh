#!/usr/bin/env bash

set -e

export REPO="https://github.com/astralbody/dotfiles"
export REPO_BLOB="$REPO/blob/main"
export PROJECTS=$HOME/Projects
export DOTFILES=$PROJECTS/dotfiles
export DOTFILES_TMP=$HOME/.dotfiles.tmp

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
		mkdir "$DOTFILES_TMP"/arch
		cd "$DOTFILES"/arch

		for file in $REPO_BLOB/arch/{pkg.sh,foreign_packages.txt,explicit_packages.txt}; do
			curl -O $file
		done

		. ./pkg.sh
		pacman_install
		yay_install
	fi
}

clone_dotfiles() {
	log "Cloning Dotfiles"

	mkdir "$PROJECTS"
	cd "$PROJECTS"
	git clone $REPO/dotfiles.git
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
