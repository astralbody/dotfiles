#!/usr/bin/env bash

pkg_install() {
	if is_arch; then
		log "Installing arch packages..."
		arch_install
	fi
	if is_debian; then
		log "Installing debian packages..."
		debian_install
	fi
}
