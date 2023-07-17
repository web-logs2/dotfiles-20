#!/usr/bin/env bash

ssh_config_inject() {
	if ! grep 'chezmoi injection' ~/.ssh/config; then
		cat <<EOF >>~/.ssh/config
# -- chezmoi injection begin --
Include "$HOME/.ssh/myconfig"
# -- chezmoi injection end --
EOF
	fi
	echo a
}

ssh_config_inject
