#!/usr/bin/env bash

pkg_help() {
	bat --plain <<EOF
pkg
	A tool to manage package managers.

USAGE:
	pkg [COMMAND]

COMMANDS:
	install
		Install all packages.
	update
		Update all packages.
	refresh
		Refresh package lists.
	clean
		Clean package managers.
EOF
}

pkg() {
	if [[ -z $1 ]]; then
		pkg_help
		return
	fi

	gotodot
	case $1 in
	install)
		pkg_install
		;;
	update)
		pkg_update
		;;
	refresh)
		pkg_refresh
		;;
	clean)
		pkg_clean
		;;
	esac
	back
}

_pkg_completions() {
	COMPREPLY=($(compgen -W "install update refresh clean" "${COMP_WORDS[1]}"))
}

complete -F _pkg_completions pkg
