#!/usr/bin/env bash

export PS1='[\u@\h \W]\$ '

# XDG Base Directory
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

# User directories
# User-specific configurations should be written (analogous to /etc).
export XDG_CONFIG_HOME="$HOME/.config"
# User-specific non-essential (cached) data should be written (analogous to /var/cache).
export XDG_CACHE_HOME="$HOME/.cache"
# User-specific data files should be written (analogous to /usr/share).
export XDG_DATA_HOME="$HOME/.local/share"
# User-specific state files should be written (analogous to /var/lib).
export XDG_STATE_HOME="$HOME/.local/state"
# User-specific executable files may be stored in $BIN_HOME.
export BIN_HOME="$HOME/.local/bin"

# System directories
# List of directories separated by : (analogous to PATH).
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
# List of directories separated by : (analogous to PATH).
export XDG_CONFIG_DIRS="/etc/xdg"
