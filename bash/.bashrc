#!/usr/bin/env bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# If set, the pattern ** used in a pathname expansion context will match all files and zero or more directories
# and subdirectories.  If the pattern is followed by a /, only directories and subdirectories match
shopt -s globstar

# Bash replaces directory names with the results of word expansion when performing filename completion
# Otherwise, It will escape `$` in variable names when pressing tab
shopt -s direxpand

DOTFILES=$(readlink "$HOME"/.dotfiles/dotfiles)
export DOTFILES

source_lib() {
	local lib
	for lib in "$DOTFILES"/lib/{environment,utils,aliases}.sh; do
		. "$lib"
	done
}

source_droplet_launchers() {
	local droplet
	for droplet in "$@"; do
		local launcher=$DOTFILES/$droplet/launcher.sh

		if [ ! -f "$launcher" ]; then
			continue
		fi

		. "$launcher"
	done
}

source_launchers() {
	if is_ubuntu; then
		source_droplet_launchers "${UBUNTU_DOTLETS[@]}"
	elif is_rpi; then
		source_droplet_launchers "${RPI_DOTLETS[@]}"
	else
		source_droplet_launchers "${PC_DOTLETS[@]}"
	fi
}

upgrade_command_not_found() {
	# Automatically seach repositories when "Command not found"
	if is_arch; then
		. /usr/share/doc/pkgfile/command-not-found.bash
	fi
}

source_lib
set_user_paths
source_launchers
upgrade_command_not_found
