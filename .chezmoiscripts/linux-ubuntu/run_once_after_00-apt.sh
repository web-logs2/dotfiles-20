#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to apt install" && exit 0

echo "apt package install start"

sudo apt install -y \
  bat \
  fzf \
  fd-find \
  ripgrep \
  cmake \
  translate-shell \
  ca-certificates \
  software-properties-common

if has_command fdfind && ! has_command fd; then
  sudo ln -s "$(which fdfind)" /usr/local/bin/fd
fi

if has_command batcat && ! has_command bat; then
  sudo ln -s "$(which batcat)" /usr/local/bin/bat
fi

if ! has_command nvim; then
  mkdir -p ~/install
  git clone https://github.com/neovim/neovim.git --depth 1
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
fi

if ! has_command go; then
  sudo add-apt-repository -y ppa:longsleep/golang-backports
  sudo apt-get install -y golang-go
  go version
  go env -w GO111MODULE=on
  go env -w GOPROXY=https://goproxy.cn/,direct
fi

echo "apt package install done"
