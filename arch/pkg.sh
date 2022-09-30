#!/usr/bin/env bash

pacman_install() {
	log "Pacman is installing packages"
	pacman_update
	xargs sudo pacman --sync --needed --noconfirm <./arch/native_packages.txt
}

pacman_update() {
	log "Pacman is updating packages"
	sudo pacman --sync --refresh --sysupgrade
}

pacman_refresh() {
	goto "${BASH_SOURCE[0]}"

	log "Refreshing arch/native_packages.txt"
	pacman --query --quiet --explicit --native >native_packages.txt

	log "Refreshing arch/foreign_packages.txt"
	pacman --query --quiet --explicit --foreign >foreign_packages.txt

	back
}

yay_install() {
	log "Installing yay"
	home
	git clone https://aur.archlinux.org/yay.git
	cd yay || exit
	makepkg --syncdeps --needed --rmdeps --install --noconfirm
	home
	rm -rf yay

	log "Yay is installing packages"
	gotodot
	xargs yay --sync --needed --noconfirm --nodiffmenu --removemake --cleanafter <./arch/foreign_packages.txt
}

yay_update() {
	log "Yay is updating packages"
	yay -Sua --noconfirm --nodiffmenu --removemake --cleanafter
}

yay_clean() {
	log "Yay is cleaning packages"
	yay -Yc
	yay -Ps
}

arch_install() {
	local install
	for install in {pacman,yay,python,js,dropbox,xdg,rust}_install; do
		$install
	done
}

arch_update() {
	pacman_update
	yay_update
	yay_clean
	beekeeper_update
	dropbox_update
	js_update
	python_update
	rust_update
}
