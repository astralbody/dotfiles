#!/usr/bin/env bash

GITHUB_USERNAME='astralbody'

if [ ! -e /etc/os-release ]; then
    echo "Unable to determine the distribution. os-release file not found." >&2
    exit 1
fi

. /etc/os-release

if [ "$ID" == "arch" ]; then
    echo "Arch Linux detected"
    sudo pacman -S chezmoi
elif [ "$ID" == "ubuntu" ]; then
    echo "Ubuntu detected"
    sudo snap install chezmoi --classic
else
    echo "Unsupported distribution: $ID" >&2
    exit 1
fi

chezmoi init --verbose --apply $GITHUB_USERNAME
