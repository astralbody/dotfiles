#!/usr/bin/env bash

set -e
trap 'err "Checks failed!"' ERR

# bash
bash_scripts="$(fd --glob \*.sh --exclude vendor) ./bash/.bashrc ./bash/.bash_logout ./bash/.bash_profile"
echo "$bash_scripts" | xargs shellcheck
echo "$bash_scripts" | xargs shfmt --language-dialect bash --diff
unset -v bash_scripts

# js
fd --glob \*.js --exclude vendor | xargs npx eslint
npx prettier --check .

# python
python_scripts=$(fd --glob \*.py --exclude vendor)
echo "$python_scripts" | xargs pipenv run pylint
echo "$python_scripts" | xargs pipenv run black --check
unset -v python_scripts

log "Dotfiles checked."
