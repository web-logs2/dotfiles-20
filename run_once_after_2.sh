#!/usr/bin/env bash

ssh_config_inject() {
  [ ! -d ~/.ssh ] && mkdir ~/.ssh
  cd ~/.ssh || exit 1
  [ ! -f config ] && touch config
  if ! grep 'chezmoi injection' config >/dev/null; then
    cat <<EOF >config.new
# -- chezmoi injection begin --
Include "$HOME/.ssh/myconfig"
# -- chezmoi injection end --

EOF
    cat config >>config.new
    mv -f config.new config
    echo 'ssh config inject done'
  fi
}

fish_config_inject() {
  cd ~/.config/fish/ || exit 1
  [ ! -f config.fish ] && touch config.fish
  if ! grep 'chezmoi injection' config.fish >/dev/null; then
    cat <<EOF >>config.fish
# -- chezmoi injection begin --
source ~/.config/fish/inject_by_chezmoi.fish
# -- chezmoi injection end --

EOF

  fi
}

ssh_config_inject
fish_config_inject
