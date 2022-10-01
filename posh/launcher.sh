#!/usr/bin/env bash

download_theme() {
	mkdir "$HOME"/.poshthemes
	wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O "$HOME"/.poshthemes/themes.zip
	unzip "$HOME"/.poshthemes/themes.zip -d "$HOME"/.poshthemes
	chmod u+rw "$HOME"/.poshthemes/*.omp.*
	rm "$HOME"/.poshthemes/themes.zip
}

posh_launcher() {
	eval "$(oh-my-posh init bash --config "$DOTFILES/posh/capr4n.omp.json")"
}

posh_launcher
