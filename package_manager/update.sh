#!/usr/bin/env bash

pkg_update() {
	if is_rpi; then
		log "Updating debian packages..."
		debian_update
	fi
	if is_arch; then
		log "Updating arch packages..."
		arch_update
	fi
}
