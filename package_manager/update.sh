#!/usr/bin/env bash

ubuntu_update() {
	sudo apt update -y
	sudo apt upgrade -y
	sudo apt autoclean
	sudo apt autoremove
	sudo snap refresh
}

pkg_update() {
	if is_ubuntu; then
		log "Updating ubuntu packages..."
		ubuntu_update
	fi
	if is_rpi; then
		log "Updating debian packages..."
		debian_update
	fi
	if is_arch; then
		log "Updating arch packages..."
		arch_update
	fi
}
