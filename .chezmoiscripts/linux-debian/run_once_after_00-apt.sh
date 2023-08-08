#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to apt install" && exit 0

echo "apt package install start"

sudo apt install -y \
  fzf \
  cmake \
  translate-shell \
  ca-certificates \
  software-properties-common

echo "apt package install done"