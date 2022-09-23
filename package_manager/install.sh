#!/usr/bin/env bash

arch_install() {
	local install
	for install in {yay,pacman,volta,pip,dropbox}_install; do
		$install
	done
}

debian_install() {
	local install
	for install in {nodejs,pyenv,apt}_install; do
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
