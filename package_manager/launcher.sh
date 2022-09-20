#!/usr/bin/env bash

source_pkg() {
	gotodot

	for pkg in $(fd -a --no-ignore-vcs --exclude package_manager --base-directory "$DOTFILES" pkg.sh); do
		. "$pkg"
	done
	unset -v pkg

	. ./package_manager/update.sh
	. ./package_manager/install.sh
	. ./package_manager/refresh.sh
	. ./package_manager/clean.sh
	. ./package_manager/pkg.sh

	back
}

is_arch() {
	local arch_id="arch"
	local os_release_id
	os_release_id=$(grep ^ID= /etc/os-release | sed -r 's/ID=//g')

	if [ "$os_release_id" = "$arch_id" ]; then
		return 0
	else
		return 1
	fi
}

source_pkg
