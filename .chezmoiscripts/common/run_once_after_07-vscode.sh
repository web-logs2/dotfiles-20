#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

if ! has_command code; then
  exit
fi

! confirm "Confirm to install VS Code extension" && exit 0

needed_extension=(
  bmalehorn.vscode-fish
  DavidAnson.vscode-markdownlint
  dbaeumer.vscode-eslint
  eamodio.gitlens
  esbenp.prettier-vscode
  golang.go
  humao.rest-client
  intellsmi.comment-translate
  labuladong.leetcode-helper
  mechatroner.rainbow-csv
  mhutchie.git-graph
  mrkou47.thrift-syntax-support
  MS-CEINTL.vscode-language-pack-zh-hans
  ms-python.python
  ms-python.vscode-pylance
  ms-toolsai.jupyter
  ms-toolsai.jupyter-keymap
  ms-toolsai.jupyter-renderers
  ms-toolsai.vscode-jupyter-cell-tags
  ms-toolsai.vscode-jupyter-slideshow
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  ms-vscode.remote-explorer
  rust-lang.rust-analyzer
  urie.yrtool
  VisualStudioExptTeam.intellicode-api-usage-examples
  VisualStudioExptTeam.vscodeintellicode
  Vue.volar
  zxh404.vscode-proto3
)

for ext in "${needed_extension[@]}"; do
  code --install-extension "$ext"
done