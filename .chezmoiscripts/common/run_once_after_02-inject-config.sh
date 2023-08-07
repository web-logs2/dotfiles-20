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

inject_to_file_bottom() {
  local file_path="$1"
  local inject_content="$2"
  [ ! -f "$file_path" ] && touch "$file_path"
  if ! grep 'chezmoi injection' "$file_path" >/dev/null; then
    cat <<EOF >>"$file_path"
    
# -- chezmoi injection begin --
$inject_content
# -- chezmoi injection end --

EOF
  fi
}

fish_config_inject() {
  inject_to_file_bottom "${HOME}/.config/fish/config.fish" "source ~/.config/fish/inject_by_chezmoi.fish"
}

zsh_config_inject() {
  inject_to_file_bottom "${HOME}/.zshrc" "source ~/.zsh/inject_by_chezmoi.zshrc"
  inject_to_file_bottom "${HOME}/.zshenv" "source ~/.zsh/inject_by_chezmoi.zshenv"
}

ssh_config_inject
fish_config_inject
zsh_config_inject