#!/usr/bin/env bash

generate_ssh() {
	local email="${1:-"door2cosmos@gmail.com"}"
	local ssh_key="${2:-"astralbody"}"

	ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/"$ssh_key" -N ""
	ssh-add ~/.ssh/"$ssh_key"
	xclip -sel clip ~/.ssh/"$ssh_key".pub
}
