#!/usr/bin/env bash

pip_install() {
	gotodot
	xargs pip install --user --isolated <./python/packages.txt
}

pip_update() {
	log "Pip is updating packages"
	xargs pip install --user --isolated --upgrade <./python/packages.txt
}

pip_refresh() {
	goto "${BASH_SOURCE[0]}"

	pip list --user --not-required --format freeze | sd '==.+' '' >./packages.txt

	back
}

pyenv_install() {
	home
	curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
	# git clone https://github.com/pyenv/pyenv-virtualenv.git "$HOME/.pyenv/plugins/pyenv-virtualenv"
}

python_install() {
	pyenv_install
	pip_install
	gotodot
	. ./python/launcher.sh
}
