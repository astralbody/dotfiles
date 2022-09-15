#!/usr/bin/env bash

vscode_install() {
	xargs code --install-extension <./vscode/extensions.txt
}

vscode_refresh() {
	code --list-extensions >./vscode/extensions.txt
}
