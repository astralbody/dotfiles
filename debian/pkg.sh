#!/usr/bin/env bash

apt_install() {
	log "Apt is installing packages"
	apt_update
	xargs sudo apt -y install <./debian/packages.txt
	sudo ln -sf "$(which fdfind)" "$USER_BIN"/fd
}

apt_update() {
	sudo apt update -y
	sudo apt full-upgrade -y
	sudo apt clean
}
