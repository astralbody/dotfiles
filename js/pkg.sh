#!/usr/bin/env bash

volta_install() {
	goto "$HOME"

	curl https://get.volta.sh | bash
	. "$DOTFILES"/volta/launcher.sh
	volta setup
	volta install node@latest yarn@latest
	xargs volta install <"$DOTFILES"/volta/packages.txt

	back
}

volta_update() {
	log "Npm is updating packages"
	npm update --global <./volta/packages.txt
}

volta_refresh() {
	volta list --format plain | rg package | choose 1 | tail -n +3 | sd '@.+' '' >./volta/packages.txt
}

nodejs_install() {
	curl -fsSL https://deb.nodesource.com/setup_current.x | sudo bash -
}
