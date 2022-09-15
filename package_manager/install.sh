#!/usr/bin/env bash

arch_install() {
	for install in {pip,volta,dropbox,pacman,yay}_install; do
		$install
	done
	unset -v install
}

pkg_install() {
	if is_arch; then
		log "Installing packages on Arch"
		arch_install
	fi
}
