#!/usr/bin/env bash

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta_completion() {
	volta completions bash >"$DOTFILES_TMP/volta_completion.sh"
	. "$DOTFILES_TMP/volta_completion.sh"
}
