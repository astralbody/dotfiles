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
export -f goto

gotodot() {
	cd "$DOTFILES" || exit
}
export -f gotodot

home() {
	cd || exit
}
export -f home

back() {
	cd - >/dev/null || exit
}
export -f back

err() {
	local message=$1
	echo "$message" >&2
}
export -f err

log() {
	local message=$1
	echo "$message" >&1
}
export -f log

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
export -f get_os_release_id

is_os_release_id() {
	local id="$1"
	local os_release_id
	os_release_id=$(get_os_release_id)

	if [ "$os_release_id" = "$id" ]; then
		return 0
	else
		return 1
	fi
}

is_arch() {
	return $(is_os_release_id "arch")
}
export -f is_arch

is_ubuntu() {
	return $(is_os_release_id "ubuntu")
}
export -f is_ubuntu

is_debian() {
	return $(is_os_release_id "debian")
}
export -f is_debian

is_rpi() {
	if is_debian && [ "$(uname -m)" == "aarch64" ]; then
		return 0
	else
		return 1
	fi
}
export -f is_rpi

reload() {
	exec $SHELL
}

set_path() {
	for i in "$@"; do
		# Check if the directory exists
		[ -d "$i" ] || continue

		# Check if it is not already in your $PATH.
		echo "$PATH" | grep -Eq "(^|:)$i(:|$)" && continue

		# Then append it to $PATH and export it
		export PATH="${PATH}:$i"
	done
}
export -f set_path

set_user_paths() {
	local USER_PATHS=("$BIN_HOME")
	set_path "${USER_PATHS[@]}"
}
export -f set_user_paths

create_xdg_base_dirs() {
	local xdg_base_dirs=(
		"$XDG_CONFIG_HOME"
		"$XDG_CACHE_HOME"
		"$XDG_DATA_HOME"
		"$XDG_STATE_HOME"
		"$BIN_HOME"
	)
	local base_dir

	for base_dir in "${xdg_base_dirs[@]}"; do
		mkdir -pv "${base_dir}"
	done
}
export -f create_xdg_base_dirs

convert_webp_to_gif() {
	local input=$1
	local output=$2
	local codec=${3-"libwebp"}
	ffmpeg -i "$input" -vcodec "$codec" -loop 0 "$output"
}

finish_feature() {
	local feature_branch
	feature_branch=$(git branch | rg '\*' | choose 1)

	git checkout master
	git pull origin master
	git branch -D "$feature_branch"
}
