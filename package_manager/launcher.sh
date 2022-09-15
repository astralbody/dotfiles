#!/usr/bin/env bash

OS_RELEASE_ID=$(rg '^ID' /etc/os-release | sd 'ID=' '')
export OS_RELEASE_ID
export ARCH_ID="arch"

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
	if [ "$OS_RELEASE_ID" = "$ARCH_ID" ]; then
		return 0
	else
		return 1
	fi
}

source_pkg
