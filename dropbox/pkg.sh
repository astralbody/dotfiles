#!/usr/bin/env bash

dropbox_install() {
	log "Installing Dropbox"
	home
	xh --download https://www.dropbox.com/download?plat=lnx.x86_64 --output dropbox-dist
	tar xzf dropbox-dist
	rm -rf dropbox-dist
	xh --download https://www.dropbox.com/download?dl=packages/dropbox.py --output "$DOTFILES"/vendor/dropbox.py
	log "Dropbox installed."
}

dropbox_update() {
	DROPBOX="$HOME"/.dropbox-dist
	AUTOSTART="$HOME"/.config/autostart

	log "Updating Dropbox"

	gotodot

	./vendor/dropbox.py update
	./vendor/dropbox.py autostart y

	bat -p ./dropbox/dropbox.desktop.template |
		sd -s 'Version=' Version="$(bat -p "$DROPBOX"/VERSION)" |
		sd -s 'Exec=' Exec="$DROPBOX"/dropboxd \
			>"$AUTOSTART"/dropbox.desktop

	back
}
