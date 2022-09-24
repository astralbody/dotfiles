#!/usr/bin/env bash

volta_install() {
	home

	curl https://get.volta.sh | bash
	. "$DOTFILES"/js/launcher.sh
	volta setup
	volta install node@latest yarn@latest
	xargs volta install <"$DOTFILES"/js/packages.txt

	back
}

volta_update() {
	log "Npm is updating packages"
	npm update --global <./js/packages.txt
}

volta_refresh() {
	volta list --format plain | rg package | choose 1 | tail -n +3 | sd '@.+' '' >./js/packages.txt
}

nodejs_install() {
	curl -fsSL https://deb.nodesource.com/setup_current.x | sudo bash -
}
