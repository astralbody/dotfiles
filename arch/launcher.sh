make_package_explicit() {
	sudo pacman -D --asexplicit "$1"
}
