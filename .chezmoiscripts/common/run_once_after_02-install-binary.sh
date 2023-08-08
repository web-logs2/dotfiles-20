#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

os="$CHEZMOI_OS"
arch="$CHEZMOI_ARCH"

go_version="1.20.7"
gh_version="2.32.1"

# use `tar -ztvf -` to preview files

if ! has_command go; then
  curl -Ls "https://dl.google.com/go/go${version}.${os}-${arch}.tar.gz" |
    sudo tar -zxvf - -C "/usr/local"
  if ! has_command go; then
    export PATH="/usr/local/go/bin:$PATH"
    echo 'should export PATH="/usr/local/go/bin:$PATH"'
  fi
  go version
  go env -w GO111MODULE=on
  go env -w GOPROXY=https://goproxy.cn/,direct
fi

if ! has_command gh; then
  curl -Ls "https://github.com/cli/cli/releases/download/v${gh_version}/gh_${gh_version}_${os}_${arch}.tar.gz" |
    tar -zxvf - -C "$HOME/.local/bin" --strip-components 2 "gh_${gh_version}_${os}_${arch}/bin/gh"
  gh --version
fi

exit 0