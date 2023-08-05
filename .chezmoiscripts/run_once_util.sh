#!/usr/bin/env bash

has_command() {
  command -v "$@" >/dev/null 2>&1
}

confirm() {
  local prompt="$1"
  if has_command gum; then
    gum confirm "$prompt"
  else
    simple_confirm() {
      read -r -p "$prompt? [Y/n] " input

      case $input in
      [yY][eE][sS] | [yY] | '')
        return 0
        ;;

      [nN][oO] | [nN])
        return 1
        ;;

      *)
        echo "Invalid input..."
        simple_confirm
        ;;
      esac
    }
    simple_confirm
  fi
}

is_os_name() {
  grep "$*" /etc/issue || grep "$*" /etc/*-release
}