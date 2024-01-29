#!/usr/bin/env bash

kitty_run_cmd() {
	local title=${1}
	local cmd=${2}
	kitty @ send-text --exclude-active --match "title:$title" "$cmd\r"
}

kitty_new_window() {
	local title=${1}
	kitty @ launch --title "$title" --keep-focus bash
}

kitty_init() {
	if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then
		. "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
	fi

	alias kr="kitty_run_cmd"
	alias kn="kitty_new_window"
	alias kitty_list_fonts="kitty +list-fonts"
}

kitty_init
