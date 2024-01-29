#!/usr/bin/env bash

_pip_completion() {
	COMPREPLY=($(COMP_WORDS="${COMP_WORDS[*]}" \
		COMP_CWORD=$COMP_CWORD \
		PIP_AUTO_COMPLETE=1 $1 2>/dev/null))
}
complete -o default -F _pip_completion /usr/bin/python -m pip
