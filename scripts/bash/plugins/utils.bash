clean_flash_drive() {
	local flash_drive="${1:-/dev/sda}"

	umount "$flash_drive"
	sudo dd if=/dev/zero of="$flash_drive" bs=4096 status=progress
	sudo mkfs.vfat -v "$flash_drive"
	sudo fsck "$flash_drive"
	mount "$flash_drive"
}

save_system_logs() {
	local LOGS_DIR="/shared_disk/system_logs"
	local time=${1-$(date +'%H:%M')}
	local date
	date=$(date +'%Y-%m-%d')
	journalctl -p err..alert --since today >"$LOGS_DIR"/freeze--"$date"--"$time"
}

convert_webp_to_gif() {
	local input=$1
	local output=$2
	local codec=${3-"libwebp"}
	ffmpeg -i "$input" -vcodec "$codec" -loop 0 "$output"
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

finish_feature() {
	local feature_branch
	feature_branch=$(git branch | rg '\*' | choose 1)

	git checkout master
	git pull origin master
	git branch -D "$feature_branch"
}

generate_ssh() {
	local email=${1}
	local ssh_key=${2}

	ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/"$ssh_key" -N ""
	ssh-add ~/.ssh/"$ssh_key"
	xclip -sel clip ~/.ssh/"$ssh_key".pub
}

make_package_explicit() {
	sudo pacman -D --asexplicit "$1"
}
