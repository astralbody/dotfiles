#!/usr/bin/env bash

export VOLTA_HOME="$HOME/.volta"
VOLTA_BIN="$VOLTA_HOME/bin"

prepend_to_path "$VOLTA_BIN"

eval "$(volta completions bash)"
