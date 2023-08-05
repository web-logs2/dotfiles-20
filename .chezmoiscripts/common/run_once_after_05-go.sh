#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to go install" && exit 0

echo "go package install start"

if ! has_command go; then
  echo has no go, skip install go pkg
  return 0
fi
! has_command ncmdump && cd ~/workspace/go/ncmdump/ && go mod tidy && go install
has_command lazygit || go install github.com/jesseduffield/lazygit@latest
has_command lazydocker || go install github.com/jesseduffield/lazydocker@latest
has_command lego || go install github.com/go-acme/lego/v4/cmd/lego@latest
has_command checkmake || go install github.com/mrtazz/checkmake/cmd/checkmake@latest

echo "go package install done"