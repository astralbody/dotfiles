#!/usr/bin/env bash

clean_flash_drive() {
	local flash_drive="${1:-/dev/sda}"

	umount "$flash_drive"
	sudo dd if=/dev/zero of="$flash_drive" bs=4096 status=progress
	sudo mkfs.vfat -v "$flash_drive"
	sudo fsck "$flash_drive"
	mount "$flash_drive"
}

save_log() {
	local LOGS_DIR="/shared_disk/logs"
	local time=${1-$(date +'%H:%M')}
	local date
	date=$(date +'%Y-%m-%d')
	journalctl -p err..alert --since today >"$LOGS_DIR"/freeze--"$date"--"$time"
}

goto() {
	cd "$(dirname "$(realpath "$1")")" || exit
}

gotodot() {
	cd "$DOTFILES" || exit
}

home() {
	cd || exit
}

back() {
	cd - >/dev/null || exit
}

err() {
	local message=$1
	echo "$message" >&2
}

log() {
	local message=$1
	echo "$message" >&1
}

clean_docker() {
	docker stop "$(docker ps -a -q)"
	docker rm -v "$(docker ps -a -q)"
	docker volume prune
	docker rmi "$(docker images -a -q)"
	docker system prune -a
}

remove_empty_dirs() {
	local base_directory=$1

	if [ -z "$base_directory" ]; then
		err "base_directory must not be empty"
		return
	fi

	fd -a -te -td --prune --base-directory "$base_directory" --exec rm -d
}

generate_ssh() {
	local email=$1
	local file_name=$2
	local password=$3
	local SSH_DIR="$HOME"/.ssh

	cd "$SSH_DIR" || exit
	printf "%s\n%s\n" "$file_name" "$password" | ssh-keygen -t rsa -b 4096 -C "$email"
	eval "$(ssh-agent -s)"
	printf "%s\n" "$password" | ssh-add "$SSH_DIR"/"$file_name"
	xclip -sel clip <"$SSH_DIR"/"$file_name".pub
	back
}

add_alias() {
	local alias=${1}
	local cmd=${2}
	local cmd2=${3}

	if command -v "$alias" &>/dev/null; then
		printf "%s exists!\n" "$alias"
		return 1
	fi

	if [ -z "$alias" ]; then
		printf "Do you have any alias to add?\nUSAGE: add_alias [ALIAS] [COMMAND]\n"
		return 1
	fi

	if [ -z "$cmd" ]; then
		printf "Do you have any command to add?\nUSAGE: add_alias %s [COMMAND]\n" "$alias"
		return 1
	fi

	if [ -n "$cmd2" ]; then
		# TODO: Concatenate arguments starting from the second one
		printf "Could you wrap a command with double quotes?\nUSAGE: add_alias %s \"%s %s\"\n" "$alias" "$cmd" "$cmd2"
		return 1
	fi

	goto "${BASH_SOURCE[0]}"
	echo "alias $alias=\"$cmd\"" >>"./aliases.sh"
	source ./aliases.sh
	back
}

is_link_broken() {
	local symlink="$1"
	if [ -n "$symlink" ]; then
		return 1
	fi
	if [ ! -e "$symlink" ]; then
		return 0
	fi
	return 1
}

get_os_release_id() {
	grep ^ID= /etc/os-release | sed -r 's/ID=//g'
}

is_arch() {
	local arch_id="arch"
	local os_release_id
	os_release_id=$(get_os_release_id)

	if [ "$os_release_id" = "$arch_id" ]; then
		return 0
	else
		return 1
	fi
}

is_debian() {
	local debian_id="debian"
	local os_release_id
	os_release_id=$(get_os_release_id)

	if [ "$os_release_id" = "$debian_id" ]; then
		return 0
	else
		return 1
	fi
}

reload() {
	exec $SHELL
}

export -f goto gotodot back log err is_link_broken is_debian is_arch reload
