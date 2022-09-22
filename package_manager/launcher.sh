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

source_pkg
