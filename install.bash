#!/usr/bin/env bash

GITHUB_USERNAME='astralbody'

if [ ! -e /etc/os-release ]; then
    echo "Unable to determine the distribution. os-release file not found." >&2
    exit 1
fi

get_os_release_id() {
	OS_RELEASE_ID=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
    echo $OS_RELEASE_ID
}

install_brew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

OS_RELEASE_ID=$(get_os_release_id)
if [ "$OS_RELEASE_ID" == "arch" ]; then
    echo "Arch Linux detected"
    sudo pacman -S chezmoi
elif [ "$OS_RELEASE_ID" == "ubuntu" ]; then
    echo "Ubuntu detected"
    install_brew
    brew install chezmoi
else
    echo "Unsupported distribution: $OS_RELEASE_ID" >&2
    exit 1
fi

chezmoi init --apply $GITHUB_USERNAME
