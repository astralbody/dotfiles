#!/usr/bin/env bash

dot_help() {
	bat --plain <<EOF
dot
	A tool to manage Dotfiles.

USAGE:
	dot [COMMAND]

COMMANDS:
	install
		Link configs from Dotfiles to \$HOME.
	publish
		Publish a local version.
	upgrade
		Upgrade Dotfiles with last remote version.
	check
		Run linters and formatters for Dotfiles.
EOF
}

dot() {
	if [[ -z $1 ]]; then
		dot_help
		return
	fi

	gotodot
	case $1 in
	install)
		log "Linking configs"
		./dotfiles/install.sh
		;;
	publish)
		log "Publishing configs"
		./dotfiles/publish.sh
		;;
	upgrade)
		log "Upgrading configs"
		./dotfiles/upgrade.sh
		;;
	check)
		log "Checking configs"
		./dotfiles/check.sh
		;;
	esac
	back
}

DOT_COMPLETIONS="install link update sync check"
_dot_completions() {
	COMPREPLY=($(compgen -W "${DOT_COMPLETIONS}" "${COMP_WORDS[1]}"))
}

complete -F _dot_completions dot
