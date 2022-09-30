#!/usr/bin/env bash

gotodot
. ./.env

sshpass -p "$RPI_PASS" ssh "$RPI_DEST" 'rm -rf .bash_history  .bash_logout  .bash_profile  .bashrc  .config  .dotfiles  .inputrc  .local  .parallel  .profile  Projects'
sshpass -p "$RPI_PASS" rsync -av --exclude={node_modules,vendor,sandbox} --mkpath "$DOTFILES" "$RPI_DEST":~/.dotfiles/
sshpass -p "$RPI_PASS" ssh "$RPI_DEST" "$HOME/.dotfiles/dotfiles/install.sh"
