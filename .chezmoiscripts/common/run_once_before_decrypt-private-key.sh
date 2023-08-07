#!/bin/bash

source "$BASH_UTIL_PATH"

output_key_path="${HOME}/key.txt"

gen_private_key() {
  age --decrypt --output "${output_key_path}" "$(chezmoi source-path)/key.txt.age"
  chmod 600 "${output_key_path}"
}

install_age() {
  local os="$CHEZMOI_OS"
  local arch="$CHEZMOI_ARCH"

  if [ "${os}" == "darwin" ]; then
    brew install age
  elif has_command pacman; then
    sudo pacman -Sy age
  else
    local age_version="1.1.1"
    local age_path="~/.local/bin"
    mkdir -p "${age_path}"
    curl -Ls "https://github.com/FiloSottile/age/releases/download/v${age_version}/age-v${age_version}-${os}-${CHEZMOI_ARCH}.tar.gz" |
      tar xvf - -C "${age_path}" --strip-components 1 age/age age/age-keygen
  fi
}

if [ ! -f "${output_key_path}" ]; then
  if ! has_command age; then
    install_age
  fi

  if has_command age; then
    gen_private_key
  fi
fi