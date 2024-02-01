#!/usr/bin/env bash

init_base() {
	local base
	for base in "$BASH_SCRIPTS"/{env,lib}.bash; do
		. "$base"
	done
}

init_plugins() {
	local plugin
	for plugin in "$BASH_SCRIPTS"/plugins/*.bash; do
		. "$plugin"
	done
}

init_base
init_plugins
set_bin_home
