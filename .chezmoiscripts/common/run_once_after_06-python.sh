#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to pipx install" && exit 0

echo "python package install start"

install_conda() {
  pyenv install miniconda3-latest
  CONDA_SUBDIR=osx-arm64 conda create -n d2l python=3.9 -y
}

if ! has_command python; then
  if has_command python3; then
    python3_path="$(which python3)"
    echo "link python to python3"
    sudo ln -s "$python3_path" "${python3_path%?}"
  else
    echo has no python, skip install python pkg
    return 0
  fi
fi

if ! has_command pyenv; then
  curl https://pyenv.run | bash
fi

if ! python -m pip >/dev/null; then
  echo "pip installing..."
  curl -s 'https://bootstrap.pypa.io/get-pip.py' | python
fi

if ! has_command pipx; then
  python -m pip install --user pipx
  python -m pipx ensurepath
fi

has_command pipenv || python -m pip install --user pipenv
has_command mycli || pipx install mycli
has_command tldr || pipx install tldr
has_command jupyter-nbconvert || pipx install nbconvert
has_command black || pipx install "black[jupyter,d]"
has_command isort || pipx install isort
has_command nginxfmt || pipx install nginxfmt
has_command aws || pipx install awscli

echo "python package install done"
