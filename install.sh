#!/usr/bin/env bash

set -e

export REPO="https://github.com/astralbody/dotfiles"
export RAW_REPO="https://raw.githubusercontent.com/astralbody/dotfiles/main"
export PROJECTS=$HOME/Projects
export DOTFILES=$PROJECTS/dotfiles
export DOTFILES_TMP=$HOME/.dotfiles.tmp
export DOWNLOADS="$HOME"/Downloads

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
	local arch_id="arch"
	local os_release_id
	os_release_id=$(get_os_release_id)

	if [ "$os_release_id" = "$arch_id" ]; then
		return 0
	else
		return 1
	fi
}

is_debian() {
	local debian_id="debian"
	local os_release_id
	os_release_id=$(get_os_release_id)

	if [ "$os_release_id" = "$debian_id" ]; then
		return 0
	else
		return 1
	fi
}

install_deps() {
	log "Installing dependencies"

	if is_arch; then
		sudo pacman -Syu --noconfirm
		sudo pacman -S --needed --noconfirm git base-devel fd
	fi
	if is_debian; then
		sudo apt update
		sudo apt full-upgrade
		sudo apt clean
		sudo apt install git -y
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

intall_local_packages() {
	log "Installing local packages"

	pipenv install
	npm install
}

mkdir -p "$DOWNLOADS"
mkdir -p "$PROJECTS"

install_deps
clone_dotfiles

gotodot

if is_arch; then
	. ./lib/utils.sh
	. ./package_manager/launcher.sh
	. ./dotfiles/launcher.sh

	pkg install
	intall_local_packages
	dot install

	back
fi
log "Dotfiles installed!"

unset -v DOTFILES
unset -f install_deps clone_dotfiles err log gotodot back
