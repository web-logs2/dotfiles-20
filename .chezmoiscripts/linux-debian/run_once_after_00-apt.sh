#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to apt install" && exit 0

os="$CHEZMOI_OS"
arch="$CHEZMOI_ARCH"

echo "apt package install start"

sudo apt install -y \
  fzf \
  cmake \
  translate-shell \
  ca-certificates \
  software-properties-common

if ! has_command go; then
  curl -Ls "https://dl.google.com/go/go1.20.7.${os}-${arch}.tar.gz" |
      sudo tar -zxvf - -C "/usr/local"
fi

echo "apt package install done"
