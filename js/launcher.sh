#!/usr/bin/env bash

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta_completion() {
	if [ ! -f "$DOTFILES_TMP/volta_completion.sh" ]; then
		volta completions bash -o "$DOTFILES_TMP/volta_completion.sh"
	fi

	. "$DOTFILES_TMP/volta_completion.sh"
}
