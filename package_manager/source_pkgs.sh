#!/usr/bin/env bash

source_pkgs() {
	gotodot

	local pkg
	for pkg in **/pkg.sh; do
		if [[ $pkg == *"package_manager"* ]]; then
			continue
		fi

		. "$pkg"
	done

	local pkg_file
	for pkg_file in ./package_manager/*.sh; do
		if [[ $pkg_file == *"launcher"* || $pkg_file == *"source_pkgs"* ]]; then
			continue
		fi

		. "$pkg_file"
	done

	back
}
