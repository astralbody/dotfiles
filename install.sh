#!/usr/bin/env bash

set -e

export REPO="https://github.com/astralbody/dotfiles"
export RAW_REPO="https://raw.githubusercontent.com/astralbody/dotfiles/main"
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

get_os_release_id() {
	grep ^ID= /etc/os-release | sed -r 's/ID=//g'
}

is_arch() {
	if [ "$OS_RELEASE_ID" = "$ARCH_ID" ]; then
		return 0
	else
		return 1
	fi
}

install_deps() {
	log "Installing dependencies"

	local OS_RELEASE_ID
	OS_RELEASE_ID=$(get_os_release_id)
	local ARCH_ID="arch"

	if is_arch; then
		pacman -Sy --needed --noconfirm git base-devel fd
	fi
}

clone_dotfiles() {
	log "Cloning Dotfiles"

	mkdir "$PROJECTS"
	git clone $REPO.git "$DOTFILES"
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
