#!/bin/bash

hasCommand() {
	command -v "$@" >/dev/null 2>&1
}

genPrivateKey() {
	age --decrypt --output "${HOME}/key.txt" "$(chezmoi source-path)/key.txt.age"
	chmod 600 "${HOME}/key.txt"
}

is_os_name() {
	grep "$*" /etc/issue || grep "$*" /etc/*-release
}

installAge() {
	if [ "$(uname)" == "Darwin" ]; then
		brew install age
	elif [ "$(uname)" == "Linux" ]; then
		is_os_name "Arch Linux" && sudo pacman -Sy age
		is_os_name "Ubuntu" && (sudo apt install age || go install filippo.io/age/cmd/...@latest)
	else
		echo "Your platform ($(uname)) is not supported."
		exit 1
	fi
}

if [ ! -f "${HOME}/key.txt" ]; then
	if ! hasCommand age; then
		read -r -p "Whether to install age? [Y/n] " input

		case $input in
		[yY][eE][sS] | [yY] | '')
			installAge
			;;

		[nN][oO] | [nN])
			echo "skip generating private key file"
			exit 0
			;;

		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	fi

	if hasCommand age; then
		genPrivateKey
	fi
fi
