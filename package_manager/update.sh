#!/usr/bin/env bash

arch_update() {
	for update in {pip,volta,dropbox,beekeeper,pacman,yay}_update; do
		$update
	done
	unset -v update
}

pkg_update() {
	if is_arch; then
		log "Updating packages on Arch"
		arch_update
	fi
}
