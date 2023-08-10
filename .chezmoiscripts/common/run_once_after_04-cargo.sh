#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to cargo install" && exit 0

echo "cargo package install start"

if ! has_command cargo; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source "$HOME/.cargo/env"
fi

rustup default stable

has_command joshuto || cargo install --git https://github.com/kamiyaa/joshuto.git --force
has_command delta || cargo install git-delta
has_command btm || cargo install bottom --locked
has_command zoxide || cargo install zoxide --locked
has_command zellij || cargo install --locked zellij
has_command bat || cargo install --locked bat
has_command fd || cargo install fd-find
has_command rg || cargo install ripgrep
has_command viu || cargo install viu
has_command rg || cargo install ripgrep

echo "cargo package install done"