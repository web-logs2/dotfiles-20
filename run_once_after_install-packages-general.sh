#!/bin/bash
# shellcheck disable=1091

is_os_name() {
	grep "$*" /etc/issue || grep "$*" /etc/*-release
}

hasCommand() {
	command -v "$@" >/dev/null 2>&1
}

install_for_darwin() {
	brew bundle --no-lock --file=/dev/stdin <<EOF
tap "homebrew/bundle"
tap "homebrew/services"
tap "homebrew/cask-fonts"
tap "dteoh/sqa"
tap "daipeihust/tap"

brew "git"
brew "git-delta"
brew "bat"
brew "chezmoi"
brew "fd"
brew "fish"
brew "fzf"
brew "iperf3"
brew "lazygit"
brew "neovim"
brew "python"
brew "pipx"
brew "pyenv"
brew "zellij"
brew "cmake"
brew "go"
brew "ripgrep"
brew "gum"
brew "zoxide"
brew "lego"
brew "dsq"
brew "koekeishiya/formulae/yabai"
brew "koekeishiya/formulae/skhd"
brew "pngpaste"
brew "ffmpeg"
brew "gh"
brew "im-select"
brew "m-cli"
brew "scrcpy"
brew "node"

cask "font-fira-mono-nerd-font"
cask "alacritty"
cask "google-chrome"
cask "android-platform-tools"
cask "telegram"
cask "raycast"
cask "wechat"
cask "neteasemusic"
cask "visual-studio-code"
cask "rar"

EOF

	# for fish shell
	# echo \n"$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 (which yabai)) --load-sa"|sudo tee -a /private/etc/sudoers.d/yabai

	# for bash shell
	# if sudo cat /private/etc/sudoers.d/yabai | grep yabai; then
	#     echo add yabai to sudo...
	#     echo \n"$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai)) --load-sa" | sudo tee -a /private/etc/sudoers.d/yabai
	# fi
}

install_for_arch() {
	sudo pacman -Syyu
	sudo pacman --needed -Sy \
		bat \
		android-tools \
		bottom \
		chezmoi \
		docker \
		docker-compose \
		fish \
		fzf \
		git \
		base-devel \
		git-delta \
		go \
		iperf3 \
		jq \
		lazygit \
		lsof \
		neovim \
		nmap \
		nodejs \
		npm \
		openbsd-netcat \
		openssh \
		p7zip \
		samba \
		zellij \
		python \
		translate-shell \
		tree \
		otf-firamono-nerd \
		unzip \
		wget \
		ripgrep \
		openssl \
		gum \
		lego \
		unrar \
		dsq \
		rsync \
		github-cli \
		zoxide

	if ! hasCommand yay; then
		mkdir -p ~/install && cd ~/install || exit 1
		git clone https://aur.archlinux.org/yay.git
		cd yay || exit 1
		makepkg -si
		yay -Y --gendb
		yay
	fi

	if hasCommand yay; then
		yay -S --answerclean None --answerdiff None --needed \
			joshuto-git \
			lazydocker
	fi
}

install_for_debian() {
	sudo apt install -y \
		bat \
		fzf \
		fd-find \
		ripgrep \
		cmake \
		software-properties-common

	if hasCommand fdfind && ! hasCommand fd; then
		sudo ln -s "$(which fdfind)" /usr/local/bin/fd
	fi

	if hasCommand batcat && ! hasCommand bat; then
		sudo ln -s "$(which batcat)" /usr/local/bin/bat
	fi

	if ! hasCommand nvim; then
		mkdir -p ~/install
		git clone https://github.com/neovim/neovim.git --depth 1
		make CMAKE_BUILD_TYPE=RelWithDebInfo
		sudo make install
	fi

	if ! hasCommand go; then
		sudo add-apt-repository -y ppa:longsleep/golang-backports
		sudo apt-get install -y golang-go
		# curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash
		# unalias g
		# source "$HOME/.g/env"
		# export G_MIRROR=https://golang.google.cn/dl/
		# TODO
		# install golang complete
		go version
		go env -w GO111MODULE=on
		go env -w GOPROXY=https://goproxy.cn/,direct
	fi
}

install_vim_plug() {
	VIM_PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share/nvim/site/autoload/plug.vim}"
	if [ ! -f "$VIM_PLUG_PATH" ]; then
		sh -c "curl -fLo '$VIM_PLUG_PATH' --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && echo 'vim-plug installed'"
	fi
}

install_cargo_pkg() {
	if ! hasCommand cargo; then
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
		source "$HOME/.cargo/env"
	fi
	rustup default stable

	hasCommand joshuto || cargo install --git https://github.com/kamiyaa/joshuto.git --force
	hasCommand delta || cargo install git-delta
	hasCommand btm || cargo install bottom --locked
	hasCommand zoxide || cargo install zoxide --locked
	hasCommand zellij || cargo install --locked zellij
	hasCommand viu || cargo install viu
	# hasCommand rg || cargo install ripgrep
}

install_go_pkg() {
	if ! hasCommand go; then
		echo has no go, skip install go pkg
		return 0
	fi
	hasCommand lazygit || go install github.com/jesseduffield/lazygit@latest
	hasCommand lazydocker || go install github.com/jesseduffield/lazydocker@latest
	hasCommand lego || go install github.com/go-acme/lego/v4/cmd/lego@latest
}

install_python_pkg() {
	if ! hasCommand python; then
		echo has no python, skip install python pkg
		return 0
	fi

	if ! hasCommand pyenv; then
		curl https://pyenv.run | bash
	fi

	if ! hasCommand pip; then
		curl -s 'https://bootstrap.pypa.io/get-pip.py' | python
	fi

	if ! hasCommand pipx; then
		python -m pip install --user pipx
		python -m pipx ensurepath
	fi

	hasCommand pipenv || pip install --user pipenv
	hasCommand mycli || pipx install mycli
	hasCommand tldr || pipx install tldr
}

install_node_pkg() {
	if ! hasCommand node; then
		export NVM_DIR="$HOME/.config/nvm"
		if [ ! -d "$NVM_DIR" ]; then
			curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
		fi
		# shellcheck disable=1091
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
		if ! hasCommand node; then
			nvm install node --lts # install latest node
			nvm use --lts          # use latest node

			# shellcheck disable=2016
			echo $'\n'"set -gx PATH '$NVM_BIN' "'$PATH'$'\n' >>~/.config/fish/custom.fish # add nvm to fish
		fi

	fi

	hasCommand pnpm || npm install -g pnpm
	hasCommand http-server || pnpm install -g http-server
}

main() {
	# install_vim_plug
	if [ "$(uname)" == "Darwin" ]; then
		install_for_darwin
	elif [ "$(uname)" == "Linux" ]; then
		is_os_name "Arch Linux" && install_for_arch
		is_os_name "Ubuntu" && install_for_debian
	else
		echo "Your platform ($(uname)) is not supported."
		exit 1
	fi

	install_cargo_pkg

	install_go_pkg

	install_python_pkg

	install_node_pkg

	echo "pre_init done"
}

read -r -p "Whether to install packages? [Y/n] " input

case $input in
[yY][eE][sS] | [yY] | '')
	main
	;;

[nN][oO] | [nN])
	echo "Packages installation skipped..."
	exit 0
	;;

*)
	echo "Invalid input..."
	exit 1
	;;
esac
