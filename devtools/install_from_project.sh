#!/usr/bin/env bash

rm -rf ~/.dotfiles
mkdir -p ~/.dotfiles
ln -sf ~/Projects/dotfiles ~/.dotfiles
~/.dotfiles/dotfiles/install.sh
