#!/usr/bin/env bash

# The max number of lines in the history file
export HISTFILESIZE=-1
# The max number of lines in memory
export HISTSIZE=-1
# Ignore commands
# export HISTIGNORE='exit'
# Stop logging of repeated identical commands
# export HISTCONTROL=ignoredups:erasedups
# Append commands to the end of the history file
# shopt -s histappend
# Append commands on the fly instead of the end of each session
# export PROMPT_COMMAND="history -a;history -n;$PROMPT_COMMAND"
# export HISTTIMEFORMAT='%F %T '

export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_INTERFACE_VIEW=BOTTOM

eval "$(mcfly init bash)"
