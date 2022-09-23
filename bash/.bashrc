#!/usr/bin/env bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

DOTFILES=$(readlink "$HOME"/.dotfiles)
export DOTFILES

# Automatically seach repositories when "Command not found"
. /usr/share/doc/pkgfile/command-not-found.bash

source_lib() {
	local lib
	for lib in "$DOTFILES"/lib/{environment,aliases,utils}.sh; do
		. "$lib"
	done
}

source_launcher() {
	local launcher
	for launcher in $(fd -a --no-ignore-vcs launcher.sh --base-directory "$DOTFILES"); do
		. "$launcher"
	done
}

source_lib
source_launcher

python_launcher
volta_completion

# Bash replaces directory names with the results of word expansion when performing filename completion
# Otherwise, It will escape `$` in variable names when pressing tab
shopt -s direxpand
