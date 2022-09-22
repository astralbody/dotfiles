#!/usr/bin/env bash

apt_install() {
	log "Apt is installing packages"
	xargs sudo apt -y install <./debian/packages.txt
}
