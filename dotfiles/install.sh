#!/usr/bin/env bash

export DOTFILES_BACKUP=$HOME/.dotfiles.backup

list_configs() {
	exa -D . --ignore-glob 'node_modules|vendor|sandbox' |
		xargs -l fd -c never -a --exclude .gitkeep -H '^\.' --base-directory |
		parallel extract_configs {}
}

extract_configs() {
	if [ -d "$1" ]; then
		fd -c never -a --exclude .gitkeep -tf --strip-cwd-prefix --base-directory "$1"
	else
		echo "$1"
	fi
}

setup_configs() {
	local dotfiles_config=${1}
	local home_config
	home_config=$(echo "$dotfiles_config" | sd "$DOTFILES"'/\w+/' "$HOME/")
	local backup_config
	backup_config=$(echo "$dotfiles_config" | sd "$DOTFILES" "$DOTFILES_BACKUP")

	back_up_config "$home_config" "$backup_config"
	link_config "$dotfiles_config" "$home_config"

	echo "$home_config" >>"$DOTFILES_TMP"/linked_configs.txt
}

back_up_config() {
	local home_dotfile="$1"
	local backup_dotfile="$2"

	if [ ! -L "$home_dotfile" ] && [ -f "$home_dotfile" ]; then
		log "Backing up $home_dotfile"
		mkdir -p "$backup_dotfile"
		mv -f "$home_dotfile" "$backup_dotfile"
	fi
}

link_config() {
	local target="$1"
	local link="$2"

	log "Linking to $link"
	mkdir -p -v "$(dirname "$link")" | choose 3 | sd "'" "" | sort -nr >>"$DOTFILES_TMP"/created_dirs.txt
	ln -sf "$target" "$link"
}

remove_links() {
	if [ ! -e "$DOTFILES_TMP"/linked_configs.txt ]; then
		touch "$DOTFILES_TMP"/linked_configs.txt
		return
	fi

	while read -r link; do
		rm "$link"
		log "Removing $link"
	done <"$DOTFILES_TMP"/linked_configs.txt
	rm "$DOTFILES_TMP"/linked_configs.txt
}

remove_created_dirs() {
	if [ ! -e "$DOTFILES_TMP"/created_dirs.txt ]; then
		touch "$DOTFILES_TMP"/created_dirs.txt
		return
	fi

	while read -r link; do
		rm -d "$link"
		log "Removing the directory $link"
	done <"$DOTFILES_TMP"/created_dirs.txt
	rm "$DOTFILES_TMP"/created_dirs.txt
}

make_links() {
	touch "$DOTFILES_TMP"/linked_configs.txt
	list_configs | parallel setup_configs {}
}

link() {
	set -e
	mkdir -p "$DOTFILES_BACKUP"
	mkdir -p "$DOTFILES_TMP"
	remove_links
	remove_created_dirs
	make_links
}

export -f extract_configs setup_configs back_up_config link_config
link
