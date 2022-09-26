#!/usr/bin/env bash

export VOLTA_HOME="$HOME/.volta"
set_path "$VOLTA_HOME/bin"

volta_completion() {
	if [ ! -f "$DOTFILES_TMP/volta_completion.sh" ]; then
		volta completions bash -o "$DOTFILES_TMP/volta_completion.sh"
	fi

	. "$DOTFILES_TMP/volta_completion.sh"
}

volta_completion
