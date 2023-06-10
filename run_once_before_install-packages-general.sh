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
        zoxide
}

install_vim_plug() {
    VIM_PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share/nvim/site/autoload/plug.vim}"
    if [ ! -f "$VIM_PLUG_PATH" ]; then
        sh -c "curl -fLo '$VIM_PLUG_PATH' --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && echo 'vim-plug installed'"
    fi
}

main() {
    install_vim_plug
    if [ "$(uname)" == "Darwin" ]; then
        install_for_darwin
    elif [ "$(uname)" == "Linux" ]; then
        is_os_name "Arch Linux" && install_for_arch
    else
        echo "Your platform ($(uname)) is not supported."
    fi
}

main
