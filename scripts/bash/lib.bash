#!/usr/bin/env bash

err() {
	local message=$1
	echo "$message" >&2
}

log() {
	local message=$1
	echo "$message" >&1
}

prepend_to_path() {
	export PATH="${1}:${PATH}"
}

append_to_path() {
	export PATH="${PATH}:${1}"
}

set_path() {
	for i in "$@"; do
		# Check if the directory exists
		[ -d "$i" ] || continue

		# Check if it is not already in your $PATH.
		echo "$PATH" | grep -Eq "(^|:)$i(:|$)" && continue

		# Then append it to $PATH and export it
		append_to_path "$i"
	done
}

set_bin_home() {
	set_path $BIN_HOME
}

upgrade_command_not_found() {
	# Automatically seach repositories when "Command not found"
	. /usr/share/doc/pkgfile/command-not-found.bash
}

reload_shell() {
	exec $SHELL
}
