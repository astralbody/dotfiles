#!/usr/bin/env bash

arch_refresh() {
	for refresh in {pacman,volta,pip,vscode}_refresh; do
		log "Refreshing $refresh"
		$refresh
	done
	unset -v refresh
}

pkg_refresh() {
	if is_arch; then
		log "Refreshing packages on Arch"
		arch_refresh
	fi
}
