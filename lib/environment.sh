#!/usr/bin/env bash

export PS1='[\u@\h \W]\$ '

export DOTDOTFILES=$HOME/.dotfiles
export DOTFILES_TMP=$DOTDOTFILES/tmp
export DOTFILES_BACKUP=$DOTDOTFILES/backup

export USER_CONFIG=$HOME/.config

export PC_DOTLETS=(
	'package_manager'
	'arch'
	'dotfiles'
	'bash'
	'beekeeper'
	'captify.privat'
	'git'
	'js'
	'lib'
	'ssh'
	'xdg_user_dirs'
	'zoxide'
	'broot'
	'chromium'
	'dropbox'
	'kitty'
	'mcfly'
	'python'
	'vscode'
	'xfce4'
)

export RPI_DOTLETS=(
	'package_manager'
	'debian'
	'dotfiles'
	'bash'
	'lib'
	'js'
	'python'
	'xdg_user_dirs'
)

export USER_BIN="$HOME/.local/bin"
export USER_PATHS=(
	"$USER_BIN"
)
