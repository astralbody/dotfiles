#!/usr/bin/env bash

alias upd='pkg update'
alias vs='code'
alias d='kitty +kitten diff'
alias s="kitty +kitten ssh"
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias ls='ls --color=auto'
alias gip='curl -w "\n" ifconfig.me'
alias lip='ip addr show dev enp6s0'
alias lk='dotfiles link'
alias tb="template bash"
alias ee="exa -l"
alias el="exa -la"
alias et="exa --git-ignore --tree"
alias rd="rustup doc"
alias irun="j insight-api && nx serve insight-api"

# Git
alias gca="git commit --amend"
alias gr="git reset --hard HEAD~1"
alias gc="git checkout"
alias gpc="git push -u origin HEAD"
alias gpcf="gpc --force"
alias gclear="git branch | grep -v "master" | xargs git branch -D"
