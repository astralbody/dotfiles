#!/usr/bin/env bash

arch_install() {
	local install
	for install in {pacman,yay,python,js,dropbox,xdg_user_dirs}_install; do
		$install
	done
}

debian_install() {
	local install
	for install in {js,apt,python,xdg_user_dirs}_install; do
		$install
	done
}

pkg_install() {
	if is_arch; then
		log "Installing packages on Arch"
		arch_install
	fi
	if is_debian; then
		log "Installing packages on Debian"
		debian_install
	fi
}
