#!/usr/bin/env bash

pip_install() {
	gotodot
	xargs pip install --user --isolated <./pip/packages.txt
}

pip_update() {
	log "Pip is updating packages"
	xargs pip install --user --isolated --upgrade <./pip/packages.txt
}

pip_refresh() {
	goto "${BASH_SOURCE[0]}"

	pip list --user --not-required --format freeze | sd '==.+' '' >./packages.txt

	back
}

pyenv_install() {
	curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
	reload
}
