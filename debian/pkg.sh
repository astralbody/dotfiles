#!/usr/bin/env bash

apt_install() {
	log "Apt is installing packages"
	apt_update
	xargs sudo apt -y install <./debian/packages.txt
}

apt_update() {
	sudo apt update -y
	sudo apt full-upgrade -y
	sudo apt clean
}

debian_install() {
	local install
	for install in {apt,rust,xdg}_install; do
		$install
	done
}

debian_update() {
	apt_update
	rust_update
}
