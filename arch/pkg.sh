pacman_install() {
	log "Pacman is installing packages"
	xargs pacman -S --needed --noconfirm <./arch/explicit_packages.txt
}

pacman_update() {
	log "Pacman is updating packages"
	sudo pacman -Syu
}

pacman_refresh() {
	goto "${BASH_SOURCE[0]}"

	log "Refreshing arch/explicit_packages.txt"
	pacman -Qqe >explicit_packages.txt

	log "Refreshing arch/foreign_packages.txt"
	pacman -Qqem >foreign_packages.txt

	sudo pkgfile -u # TODO: Why do I need it?
	back
}

yay_install() {
	local DOWNLOADS_DIR="$HOME"/Downloads

	log "Installing yay"
	pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd "$DOWNLOADS_DIR" && makepkg -si && cd .. && rm -rf yay

	log "Yay is installing packages"
	xargs yay -S <./arch/foreign_packages.txt
}

yay_update() {
	log "Yay is updating packages"
	yay -Sua --answerdiff None --answerclean All
}

yay_clean() {
	log "Yay is cleaning packages"
	yay -Yc
	yay -Ps
}
