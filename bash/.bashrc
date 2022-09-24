#!/usr/bin/env bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# If set, the pattern ** used in a pathname expansion context will match all files and zero or more directories
# and subdirectories.  If the pattern is followed by a /, only directories and subdirectories match
shopt -s globstar

# Bash replaces directory names with the results of word expansion when performing filename completion
# Otherwise, It will escape `$` in variable names when pressing tab
shopt -s direxpand

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
