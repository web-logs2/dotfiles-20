#!/bin/bash

is_os_name() {
    grep "$*" /etc/issue || grep "$*" /etc/*-release
}

hasCommand() {
    command -v $* >/dev/null 2>&1
}

install_for_darwin() {
    brew bundle --no-lock --file=/dev/stdin <<EOF
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"
tap "homebrew/services"
tap "homebrew/cask-fonts"
tap "dteoh/sqa"

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
brew "pyenv"
brew "tmux"
brew "go"
brew "ripgrep"
brew "gum"
brew "zoxide"
brew "lego"

cask "font-fira-mono-nerd-font"
cask "alacritty"
cask "slowquitapps"
cask "google-chrome"
cask "android-platform-tools"
cask "telegram"
cask "raycast"
cask "wechat"
cask "neteasemusic"
cask "visual-studio-code"

EOF

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
        tmux \
        translate-shell \
        tree \
        otf-firamono-nerd \
        unzip \
        wget \
        ripgrep \
        openssl \
        gum \
        lego \
        zoxide

    if ! hasCommand yay; then
        mkdir -p ~/install && cd ~/install
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        yay -Y --gendb
        yay
    fi

    if hasCommand yay; then
        hasCommand joshuto || yay -S joshuto
        hasCommand lazydocker || yay -S lazydocker
    fi
}

install_for_debian() {
    sudo apt install -y \
        bat \
        fzf \
        cmake \
        software-properties-common

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
        export G_MIRROR=https://golang.google.cn/dl/
        # TODO
        # install golang complete
        go version
        go env -w GO111MODULE=on
        go env -w GOPROXY=https://goproxy.cn/,direct
    fi
}

install_cargo_pkg() {
    hasCommand joshuto || cargo install --git https://github.com/kamiyaa/joshuto.git
    hasCommand git-delta || cargo install git-delta
    hasCommand zoxide || cargo install zoxide --locked
}

install_vim_plug() {
    VIM_PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share/nvim/site/autoload/plug.vim}"
    if [ ! -f "$VIM_PLUG_PATH" ]; then
        sh -c "curl -fLo '$VIM_PLUG_PATH' --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && echo 'vim-plug installed'"
    fi
}

install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    export PATH="$PATH:/home/urie/.cargo/bin"
    source "$HOME/.cargo/env"
}

install_cargo_pkg() {
    hasCommand joshuto || cargo install --git https://github.com/kamiyaa/joshuto.git --force
    hasCommand delta || cargo install git-delta
    hasCommand btm || cargo install bottom --locked
}

install_go_pkg() {
    hasCommand lazygit || go install github.com/jesseduffield/lazygit@latest
    hasCommand lazydocker || go install github.com/jesseduffield/lazydocker@latest
    hasCommand lego || go install github.com/go-acme/lego/v4/cmd/lego@latest
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

    if ! hasCommand cargo; then
        install_rust
    else
        install_cargo_pkg
    fi

    hasCommand go && install_go_pkg

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
