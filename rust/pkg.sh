#!/usr/bin/env bash

rustup_install() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
}

rustup_update() {
	rustup update
}

rust_install() {
	home
	rustup_install
	gotodot
	. ./rust/launcher.sh
	home
	if is_rpi; then
		cargo install sd choose fd-find
	fi
}

rust_update() {
	rustup_update
	# TODO: https://github.com/nabijaczleweli/cargo-update
}
