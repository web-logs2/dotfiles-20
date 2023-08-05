#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to node install" && exit 0

echo "node package install start"

if ! has_command node; then
  export NVM_DIR="$HOME/.config/nvm"
  if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  fi
  # shellcheck disable=1091
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  if ! has_command node; then
    nvm install node --lts # install latest node
    nvm use --lts          # use latest node

    # shellcheck disable=2016
    echo $'\n'"set -gx PATH '$NVM_BIN' "'$PATH'$'\n' >>~/.config/fish/custom.fish # add nvm to fish
  fi

fi

! has_command nc2mp3 && cd ~/workspace/js/nc2mp3/ && npm link
has_command pnpm || npm install -g pnpm
has_command http-server || pnpm install -g http-server

echo "node package install done"