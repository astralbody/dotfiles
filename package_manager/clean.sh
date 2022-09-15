#!/usr/bin/env bash

pkg_clean() {
	log "Cleaning package managers"

	if is_arch; then
		yay_clean
	fi
}
